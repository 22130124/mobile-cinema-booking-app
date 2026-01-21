package nlu.fit.backend.config;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.model.Account;
import nlu.fit.backend.repository.AccountRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import static nlu.fit.backend.model.Account.AccountRole.ADMIN;
import static nlu.fit.backend.model.Account.AccountStatus.ACTIVE;

@Component
@RequiredArgsConstructor
public class AdminAccountSeeder implements CommandLineRunner {
    private final AccountRepository accountRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${admin.seed.enabled:true}")
    private boolean enabled;

    @Value("${admin.seed.email:admin@cinema.local}")
    private String email;

    @Value("${admin.seed.password:admin123}")
    private String password;

    @Value("${admin.seed.force:false}")
    private boolean forceUpdate;

    @Override
    public void run(String... args) {
        if (!enabled) return;
        if (email == null || email.isBlank() || password == null || password.isBlank()) return;

        var existing = accountRepository.findByEmail(email).orElse(null);
        if (existing != null) {
            boolean changed = false;
            if (existing.getRole() != ADMIN) {
                existing.setRole(ADMIN);
                changed = true;
            }
            if (existing.getStatus() != ACTIVE) {
                existing.setStatus(ACTIVE);
                changed = true;
            }
            if (forceUpdate) {
                existing.setPassword(passwordEncoder.encode(password));
                changed = true;
            }
            if (changed) {
                accountRepository.save(existing);
            }
            return;
        }

        Account admin = new Account();
        admin.setEmail(email);
        admin.setPassword(passwordEncoder.encode(password));
        admin.setRole(ADMIN);
        admin.setStatus(ACTIVE);
        accountRepository.save(admin);
    }
}
