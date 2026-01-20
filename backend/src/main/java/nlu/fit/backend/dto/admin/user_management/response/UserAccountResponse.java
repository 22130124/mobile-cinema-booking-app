package nlu.fit.backend.dto.admin.user_management.response;

import lombok.Data;

@Data
public class UserAccountResponse {
    private Long id;
    private String fullName;
    private String email;
    private String phone;
    private String gender;
    private String userStatus;
    private String role;
    private String accountStatus;
    private String avatarUrl;
}
