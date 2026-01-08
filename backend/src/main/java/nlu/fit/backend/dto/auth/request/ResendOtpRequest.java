package nlu.fit.backend.dto.auth.request;

import lombok.Data;

@Data
public class ResendOtpRequest {
    private String email;
    private String type;
}
