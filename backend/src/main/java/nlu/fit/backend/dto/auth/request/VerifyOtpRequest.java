package nlu.fit.backend.dto.auth.request;

import lombok.Data;

@Data
public class VerifyOtpRequest {
    private String email;
    private String otp;
}
