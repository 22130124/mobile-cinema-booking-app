package nlu.fit.backend.service;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.auth.request.LoginRequest;
import nlu.fit.backend.dto.auth.request.RegisterRequest;
import nlu.fit.backend.dto.auth.request.VerifyOtpRequest;
import nlu.fit.backend.model.Account;
import nlu.fit.backend.model.EmailOtp;
import nlu.fit.backend.repository.AccountRepository;
import nlu.fit.backend.repository.EmailOtpRepository;
import nlu.fit.backend.util.JwtUtil;
import nlu.fit.backend.util.OtpUtil;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;

import static nlu.fit.backend.model.Account.AccountRole.*;
import static nlu.fit.backend.model.Account.AccountStatus.*;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final AccountRepository accountRepository;
    private final EmailOtpRepository emailOtpRepository;
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

        // Xóa Otp cũ nếu có
        emailOtpRepository.deleteByEmail(email);

        // Tạo mã Otp mới
        String otp = OtpUtil.generateOtp();

        // Tạo một đối tượng Otp để lưu vào database
        EmailOtp emailOtp = new EmailOtp();
        emailOtp.setEmail(email);
        emailOtp.setOtp(otp);
        emailOtp.setExpiredAt(LocalDateTime.now().plusMinutes(5));

        // Lưu Otp vào database
        emailOtpRepository.save(emailOtp);
        // Gửi mail chứa mã otp
        mailService.sendOtp(email, otp);
    }

    // Phương thức xác thực mã Otp
    @Transactional(noRollbackFor = ResponseStatusException.class)
    public void verifyOtp(VerifyOtpRequest request) {
        // Tìm trong database dòng dữ liệu chứa email và otp như trong request
        EmailOtp emailOtp = emailOtpRepository.findByEmailAndOtp(request.getEmail(), request.getOtp())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST,
                        "Mã OTP không hợp lệ hoặc đã hết hạn"));

        try {
            // Kiểm tra mã hết hạn hay chưa
            if (emailOtp.getExpiredAt().isBefore(LocalDateTime.now())) {
                emailOtpRepository.deleteByEmail(request.getEmail());
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Mã OTP không hợp lệ hoặc đã hết hạn");
            }

            // Nếu mã hợp lệ, tìm tài khoản với email tương ứng
            Account account = accountRepository.findByEmail(request.getEmail())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST,
                            "Không tìm thấy tài khoản"));

            // Cập nhật trạng thái tài khoản là ACTIVE
            account.setStatus(ACTIVE);
            // Cập nhật lại database
            accountRepository.save(account);
        } finally {
            // Xóa dòng dữ liệu chứa mã otp này sau khi xác thực thành công
            emailOtpRepository.deleteByEmail(request.getEmail());
        }
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
}
