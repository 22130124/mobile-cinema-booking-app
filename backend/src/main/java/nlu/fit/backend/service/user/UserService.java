package nlu.fit.backend.service.user;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.user.request.UpdateUserRequest;
import nlu.fit.backend.model.user.User;
import nlu.fit.backend.repository.user.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ResponseStatusException;

import static nlu.fit.backend.model.user.User.UserGender.*;
import static nlu.fit.backend.model.user.User.UserStatus.*;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

    // Phuơng thức tạo một user (empty) khi mới đăng ký tài khoản
    @Transactional
    public User createAndReturnEmptyUser() {
        User user = new User();
        user.setStatus(INCOMPLETED);
        userRepository.save(user);
        return user;
    }

    // Phương thức lấy ra trạng thái hoàn thiện hồ sơ của người dùng
    // Mục đích: Nếu mới đăng ký tài khoản, trạng thái sẽ là false => sau khi đăng nhập sẽ vào trang hồ sơ người dùng
    public boolean getUserStatus(User user) {
        String status = String.valueOf(user.getStatus());
        return status.equals("COMPLETED");
    }

    // Phương thức cập nhật thông tin hồ sơ người dùng
    @Transactional
    public void updateProfile(Authentication authentication, UpdateUserRequest request) {
        // Lấy userId từ JWT token
        Long userId = (Long) authentication.getPrincipal();
        if (userId == null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy thông tin người dùng");

        // Tìm kiếm User theo userId
        User user = userRepository.findById(userId).orElseThrow(
                () -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy thông tin người dùng"));

        // Thực hiện cập nhật thông tin
        user.setFullName(request.getFullName());
        switch (request.getGender().toLowerCase()) {
            case "male":
                user.setGender(MALE);
                break;
            case "female":
                user.setGender(FEMALE);
                break;
        }
        user.setPhone(request.getPhone());
        if (StringUtils.hasText(request.getAvatarUrl()) && StringUtils.hasText(request.getAvatarPublicId())) {
            user.setAvatarUrl(request.getAvatarUrl());
            user.setAvatarPublicId(request.getAvatarPublicId());
        }

        // Thiết lập trạng thái hồ sơ đã hoàn thành
        user.setStatus(COMPLETED);

        // Lưu lại thông tin
        userRepository.save(user);
    }
}
