package nlu.fit.backend.dto.user.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UpdateUserRequest {
    @NotBlank(message = "Họ và tên không được để trống")
    private String fullName;
    @NotBlank(message = "Giới tính không được để trống")
    private String gender;
    @NotBlank(message = "Số điện thoại không được để trống")
    private String phone;
    private String avatarUrl;
    private String avatarPublicId;
}
