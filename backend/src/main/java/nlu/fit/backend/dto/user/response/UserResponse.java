package nlu.fit.backend.dto.user.response;

import lombok.Data;

@Data
public class UserResponse {
    private Long id;
    private String fullName;
    private String gender;
    private String phone;
    private String avatarUrl;
    private String avatarPublicId;
    private String status;
}
