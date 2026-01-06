package nlu.fit.backend.service;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.auth.request.LoginRequest;
import nlu.fit.backend.dto.auth.request.RegisterRequest;
import nlu.fit.backend.model.Account;
import nlu.fit.backend.repository.AccountRepository;
import nlu.fit.backend.util.JwtUtil;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import static nlu.fit.backend.model.Account.AccountRole.*;
import static nlu.fit.backend.model.Account.AccountStatus.*;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final AccountRepository accountRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwt;

    public String checkHealth() {
        return "OK";
    }

    // Phương thức đăng ký tài khoản
    @Transactional
    public void register(RegisterRequest request) {
        // Lấy ra các thông tin trong request
        String email = request.getEmail();
        String hashedPassword = passwordEncoder.encode(request.getPassword());
        // Tạo tài khoản mới
        Account account = new Account();
        account.setEmail(email);
        account.setPassword(hashedPassword);
        account.setRole(USER); // Mặc định khi đăng ký là quyền USER
        account.setStatus(UNVERIFIED);
        // Lưu vào database
        accountRepository.save(account);
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
