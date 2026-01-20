package nlu.fit.backend.dto.auth.request;

import lombok.Data;

@Data
public class CheckOldPasswordRequest {
    private String oldPassword;
}
