package nlu.fit.backend.repository.auth;

import nlu.fit.backend.model.auth.EmailOtp;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface EmailOtpRepository extends JpaRepository<EmailOtp, Long> {
    Optional<EmailOtp> findByEmailAndOtp(String email, String otp);

    void deleteByEmail(String email);
}
