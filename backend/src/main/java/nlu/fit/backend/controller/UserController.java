package nlu.fit.backend.controller;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.user.UserProfileDto;
import nlu.fit.backend.model.Account;
import nlu.fit.backend.model.User;
import nlu.fit.backend.repository.AccountRepository;
import nlu.fit.backend.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class UserController {
    private final UserRepository userRepository;
    private final AccountRepository accountRepository;

    @GetMapping("/me")
    public ResponseEntity<UserProfileDto> getCurrentUser(Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String email = authentication.getName();
        User user = userRepository.findByEmail(email)
                .orElseGet(() -> createUserFromAccount(email));

        UserProfileDto profile = new UserProfileDto(
                user.getId(),
                user.getEmail(),
                user.getUsername(),
                user.getFullName()
        );
        return ResponseEntity.ok(profile);
    }

    private User createUserFromAccount(String email) {
        Account account = accountRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Account not found"));

        String username = buildUsername(email);
        User user = new User();
        user.setEmail(email);
        user.setUsername(username);
        user.setFullName(username);
        user.setPassword(account.getPassword());
        user.setPhone("0000000000");
        user.setStatus((byte) 1);
        Instant now = Instant.now();
        user.setCreatedAt(now);
        user.setUpdatedAt(now);

        return userRepository.save(user);
    }

    private String buildUsername(String email) {
        int atIndex = email.indexOf('@');
        if (atIndex > 0) {
            String username = email.substring(0, atIndex);
            return username.length() > 50 ? username.substring(0, 50) : username;
        }
        return ("user" + System.currentTimeMillis()).substring(0, 50);
    }
}
