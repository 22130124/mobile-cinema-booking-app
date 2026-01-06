package nlu.fit.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "email_otp")
@Getter
@Setter
public class EmailOtp {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String email;

    private String otp;

    @Enumerated(EnumType.STRING)
    private OtpType type;

    private LocalDateTime expiredAt;

    public enum OtpType {REGISTER, FORGOT_PASSWORD}
}

