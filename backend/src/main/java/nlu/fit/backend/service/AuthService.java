package nlu.fit.backend.service;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.auth.request.*;
import nlu.fit.backend.model.Account;
import nlu.fit.backend.model.EmailOtp;
import nlu.fit.backend.model.PasswordResetToken;
import nlu.fit.backend.repository.AccountRepository;
import nlu.fit.backend.repository.EmailOtpRepository;
import nlu.fit.backend.repository.PasswordResetTokenRepository;
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
import java.util.UUID;

import static nlu.fit.backend.model.Account.AccountRole.*;
import static nlu.fit.backend.model.Account.AccountStatus.*;
import static nlu.fit.backend.model.EmailOtp.OtpType.*;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final AccountRepository accountRepository;
    private final EmailOtpRepository emailOtpRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwt;
    private final MailService mailService;

    public String checkHealth() {
        return "OK";
    }

    // Phương thức đăng ký tài khoản
    @Transactional
    public void register(RegisterRequest request) {
        // Lấy ra thông tin email từ request
        String email = request.getEmail();

        if (accountRepository.existsByEmail(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email đã được sử dụng");
        }

        // Mã hóa thông tin password từ request
        String hashedPassword = passwordEncoder.encode(request.getPassword());
        // Tạo tài khoản mới
        Account account = new Account();
        account.setEmail(email);
        account.setPassword(hashedPassword);
        account.setRole(USER); // Mặc định khi đăng ký là quyền USER
        account.setStatus(UNVERIFIED); // Mặc định là tài khoản chưa được xác minh email
        // Lưu vào database
        accountRepository.save(account);

        // Gửi mã OTP
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
    public String login(LoginRequest request) {
        // Tìm tài khoản theo email
        Account account = accountRepository.findByEmail(request.getEmail()).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Thông tin đăng nhập không chính xác"));
        // So khớp mật khẩu
        if (!passwordEncoder.matches(request.getPassword(), account.getPassword()))
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Thông tin đăng nhập không chính xác");
        // Trả về jwt token
        return jwt.generate(account.getEmail(), String.valueOf(account.getRole()));
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
