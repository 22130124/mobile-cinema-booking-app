package nlu.fit.backend.dto.auth.request;

import lombok.Data;

@Data
public class RegisterRequest {
    private String email;
    private String password;
}
