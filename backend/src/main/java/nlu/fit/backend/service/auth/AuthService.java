package nlu.fit.backend.service.auth;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.auth.request.*;
import nlu.fit.backend.dto.auth.response.LoginResponse;
import nlu.fit.backend.model.auth.Account;
import nlu.fit.backend.model.auth.EmailOtp;
import nlu.fit.backend.model.auth.PasswordResetToken;
import nlu.fit.backend.model.user.User;
import nlu.fit.backend.repository.auth.AccountRepository;
import nlu.fit.backend.repository.auth.EmailOtpRepository;
import nlu.fit.backend.repository.auth.PasswordResetTokenRepository;
import nlu.fit.backend.service.MailService;
import nlu.fit.backend.service.user.UserService;
import nlu.fit.backend.util.JwtUtil;
import nlu.fit.backend.util.OtpUtil;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

import static nlu.fit.backend.model.auth.Account.AccountRole.*;
import static nlu.fit.backend.model.auth.Account.AccountStatus.*;
import static nlu.fit.backend.model.auth.EmailOtp.OtpType.*;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final AccountRepository accountRepository;
    private final EmailOtpRepository emailOtpRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwt;
    private final MailService mailService;
    private final UserService userService;

    public String checkHealth() {
        return "OK";
    }

    // Phương thức đăng ký tài khoản
    @Transactional
    public void register(RegisterRequest request) {
        // Lấy ra thông tin email từ request
        String email = request.getEmail();

        // Tìm trong database đã có tài khoản với email này chưa
        Optional<Account> accountOpt = accountRepository.findByEmail(email);

        // Nếu đã tồn tại tài khoản với email này
        if (accountOpt.isPresent()) {
            Account account = accountOpt.get();

            // Nếu tài khoản này đã được xác minh rồi thì báo lỗi email đã được sử dụng
            if (account.getStatus() != UNVERIFIED) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "Email đã được sử dụng");
            } else {
                // Nếu tài khoản này vẫn chưa xác minh email thì gửi lại mã otp để xác minh
                // Mã hóa thông tin password từ request
                String hashedPassword = passwordEncoder.encode(request.getPassword());
                account.setPassword(hashedPassword);
                sendOtp(email, REGISTER);
                return;
            }
        }

        if (accountRepository.existsByEmail(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email đã được sử dụng");
        }

        // Tạo User mới (thông tin rỗng)
        User user = userService.createAndReturnEmptyUser();

        // Tạo tài khoản mới
        Account account = new Account();
        account.setUser(user);
        account.setEmail(email);
        // Mã hóa thông tin password từ request
        String hashedPassword = passwordEncoder.encode(request.getPassword());
        account.setPassword(hashedPassword);
        account.setRole(USER); // Mặc định khi đăng ký là quyền USER
        account.setStatus(UNVERIFIED); // Mặc định là tài khoản chưa được xác minh email
        // Lưu vào database
        accountRepository.save(account);

        // Gửi mã OTP xác minh email
        sendOtp(email, REGISTER);
    }

    @Transactional
    public void sendOtp(String email, EmailOtp.OtpType type) {
        // Xóa Otp cũ nếu có
        emailOtpRepository.deleteByEmail(email);

        // Tạo mã Otp mới
        String otp = OtpUtil.generateOtp();

        // Tạo một đối tượng Otp để lưu vào database
        EmailOtp emailOtp = new EmailOtp();
        emailOtp.setEmail(email);
        emailOtp.setOtp(otp);
        emailOtp.setType(type);
        emailOtp.setExpiredAt(LocalDateTime.now().plusMinutes(5));
        // Lưu Otp vào database
        emailOtpRepository.save(emailOtp);
        // Gửi mail chứa mã otp
        mailService.sendOtp(email, otp);
    }

    // Phương thức gửi lại mã OTP
    @Transactional
    public void resendOtp(ResendOtpRequest request) {
        switch (request.getType().toLowerCase()) {
            case "register":
                sendOtp(request.getEmail(), REGISTER);
                break;
            case "forgot-password":
                sendOtp(request.getEmail(), FORGOT_PASSWORD);
                break;
        }
    }

    // Phương thức xác thực mã Otp
    @Transactional(noRollbackFor = ResponseStatusException.class)
    public String verifyOtp(VerifyOtpRequest request) {
        // Tìm trong database dòng dữ liệu chứa email và otp như trong request
        EmailOtp emailOtp = emailOtpRepository.findByEmailAndOtp(request.getEmail(), request.getOtp())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST,
                        "Mã OTP không hợp lệ hoặc đã hết hạn"));

        try {
            // Kiểm tra mã hết hạn hay chưa
            if (emailOtp.getExpiredAt().isBefore(LocalDateTime.now())) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Mã OTP không hợp lệ hoặc đã hết hạn");
            }

            // Kiểm tra loại mã OTP
            switch (emailOtp.getType()) {
                case REGISTER:
                    // Nếu mã hợp lệ, tìm tài khoản với email tương ứng
                    Account account = accountRepository.findByEmail(request.getEmail())
                            .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST,
                                    "Không tìm thấy tài khoản"));

                    // Cập nhật trạng thái tài khoản là ACTIVE
                    account.setStatus(ACTIVE);
                    // Cập nhật lại database
                    accountRepository.save(account);
                    break;
                case FORGOT_PASSWORD:
                    // Sinh reset token để phục vụ cho việc đổi mật khẩu
                    // Phòng trường hợp người dùng tự ý bỏ qua bước xác thực OTP và gọi api reset mật khẩu
                    String token = UUID.randomUUID().toString();

                    PasswordResetToken resetToken = new PasswordResetToken();
                    resetToken.setEmail(request.getEmail());
                    resetToken.setToken(token);
                    resetToken.setExpiredAt(LocalDateTime.now().plusMinutes(5));

                    passwordResetTokenRepository.save(resetToken);
                    return token;
            }
        } finally {
            // Xóa dòng dữ liệu chứa mã otp này kể cả khi thành công hoặc đã hết hạn
            emailOtpRepository.deleteByEmail(request.getEmail());
        }
        return null;
    }

    // Phương thức đăng nhập tài khoản
    public LoginResponse login(LoginRequest request) {
        // Tìm tài khoản theo email
        Account account = accountRepository.findByEmail(request.getEmail()).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Thông tin đăng nhập không chính xác"));
        // So khớp mật khẩu
        if (!passwordEncoder.matches(request.getPassword(), account.getPassword()))
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Thông tin đăng nhập không chính xác");

        // Tạo response trả về
        LoginResponse loginResponse = new LoginResponse();
        // Tạo và gán giá trị jwt token vào response
        String jwtToken = jwt.generate(account.getEmail(), String.valueOf(account.getRole()));
        loginResponse.setJwtToken(jwtToken);
        // Tìm và gán giá trị userStatus (true/false) vào response
        // Để frontend biết được hồ sơ người dùng đã hoàn thiện chưa
        // Để quyết định chuyển hướng vào trang chủ hay trang hồ sơ người dùng để cập nhật thông tin cho đầy đủ
        if (account.getRole() == USER) {
            boolean userStatus = userService.getUserStatus(account.getUser());
            loginResponse.setUserStatus(userStatus);
        }

        return loginResponse;
    }

    // Phương thức xử lý yêu cầu quên mật khẩu
    @Transactional
    public void processForgotPassword(ForgotPasswordRequest request) {
        // Gửi mã OTP đến email trong request
        // Ở đây không kiểm tra email có tồn tại hay không để tránh bị kẻ lạ check mail
        sendOtp(request.getEmail(), FORGOT_PASSWORD);
    }

    // Phương thức thay đổi mật khẩu cho tài khoản
    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        PasswordResetToken resetToken = passwordResetTokenRepository.findByToken(request.getToken())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.BAD_REQUEST, "Token không hợp lệ"));

        try {
            if (resetToken.getExpiredAt().isBefore(LocalDateTime.now())) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST, "Yêu cầu thay đổi mật khẩu đã hết hạn");
            }

            // Tìm tài khoản theo email
            Account account = accountRepository.findByEmail(request.getEmail()).orElseThrow(() ->
                    new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Thông tin đăng nhập không chính xác"));

            // Mã hóa thông tin password từ request
            String hashedPassword = passwordEncoder.encode(request.getPassword());

            // Cập nhật lại mật khẩu
            account.setPassword(hashedPassword);
            accountRepository.save(account);
        } finally {
            // Xóa token trong database
            passwordResetTokenRepository.delete(resetToken);
        }
    }

    @Transactional
    public void changePassword(ChangePasswordRequest request) {
        // Lấy email người dùng đang đăng nhập
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();

        // Lấy ra account tương ứng với email
        Account account = accountRepository.findByEmail(email).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy tài khoản"));

        // So khớp mật khẩu cũ
        if (!passwordEncoder.matches(request.getOldPassword(), account.getPassword()))
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Mật khẩu cũ không chính xác");

        // Mã hóa thông tin mật khẩu mới từ request
        String hashedPassword = passwordEncoder.encode(request.getNewPassword());

        // Cập nhật lại mật khẩu
        account.setPassword(hashedPassword);
        accountRepository.save(account);
    }
}
