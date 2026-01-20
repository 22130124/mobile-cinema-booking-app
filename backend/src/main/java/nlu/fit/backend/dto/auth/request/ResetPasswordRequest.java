package nlu.fit.backend.dto.auth.request;

import lombok.Data;

@Data
public class ResetPasswordRequest {
    private Long userId;
    private String email;
    private String password;
    private String token;
}
