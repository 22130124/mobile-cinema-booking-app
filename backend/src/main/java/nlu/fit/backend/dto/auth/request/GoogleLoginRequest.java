package nlu.fit.backend.dto.auth.request;

import lombok.Data;

@Data
public class GoogleLoginRequest {
    private String idToken;
}
