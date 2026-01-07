package nlu.fit.backend.dto.auth.response;

import lombok.Data;

@Data
public class LoginResponse {
    private String jwtToken;
    private boolean userStatus;
}
