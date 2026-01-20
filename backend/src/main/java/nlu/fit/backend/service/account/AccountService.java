package nlu.fit.backend.service.account;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.auth.request.EmailRequest;
import nlu.fit.backend.model.User;
import nlu.fit.backend.model.auth.Account;
import nlu.fit.backend.repository.auth.AccountRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import static nlu.fit.backend.model.auth.Account.AccountRole.USER;
import static nlu.fit.backend.model.auth.Account.AccountStatus.UNVERIFIED;

@Service
@RequiredArgsConstructor
public class AccountService {
    private final AccountRepository accountRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public void changePassword(String email, String password) {
        // Tìm tài khoản theo email
        Account account = accountRepository.findByEmail(email).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy tài khoản"));

        // Mã hóa thông tin password từ request
        String hashedPassword = passwordEncoder.encode(password);

        // Cập nhật lại mật khẩu
        account.setPassword(hashedPassword);
        accountRepository.save(account);
    }

    // Phương thức xử lý việc thay đổi email cho tài khoản
    @Transactional
    public void changeEmail(Long id, String email) {
        if (accountRepository.existsByEmail(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email đã được sử dụng");
        }

        Account account = accountRepository.findById(id).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy tài khoản"));
        account.setEmail(email);
        // Thiết lập trạng thái là email chưa được xác minh
        // Mục đích: Người dùng đăng nhập bằng email mới, một mã OTP gửi qua email mới để xác minh email
        account.setStatus(UNVERIFIED);
        accountRepository.save(account);
    }

    @Transactional
    public void changeStatus(EmailRequest request, Account.AccountStatus accountStatus) {
        // Lấy ra account tương ứng với email
        Account account = accountRepository.findByEmail(request.getEmail()).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy tài khoản"));
        account.setStatus(accountStatus);
        accountRepository.save(account);
    }

    @Transactional
    public void changeRole(EmailRequest request, Account.AccountRole accountRole) {
        // Lấy ra account tương ứng với email
        Account account = accountRepository.findByEmail(request.getEmail()).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy tài khoản"));
        account.setRole(accountRole);
        accountRepository.save(account);
    }

    public void createNewAccount(String email, String password, User user) {
        Account account = new Account();
        account.setEmail(email);
        account.setPassword(passwordEncoder.encode(password));
        account.setRole(USER);
        account.setStatus(UNVERIFIED);
        account.setUser(user);
        accountRepository.save(account);
    }
}
