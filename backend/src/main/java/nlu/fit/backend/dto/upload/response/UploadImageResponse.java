package nlu.fit.backend.dto.upload.response;

import lombok.Data;

@Data
public class UploadImageResponse {
    private String publicId;
    private String secureUrl;
}
