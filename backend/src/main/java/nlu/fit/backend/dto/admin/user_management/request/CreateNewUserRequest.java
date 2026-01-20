package nlu.fit.backend.dto.admin.user_management.request;

import lombok.Data;

@Data
public class CreateNewUserRequest {
    private String email;
    private String fullName;
    private String phone;
    private String gender;
    private String password;
}
