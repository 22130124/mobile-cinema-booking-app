package nlu.fit.backend.dto.admin.user_management.request;

import lombok.Data;

@Data
public class UpdateUserInfoRequest {
    private Long userId;
    private String email;
    private String fullName;
    private String phone;
    private String gender;
}
