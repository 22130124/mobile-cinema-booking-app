package nlu.fit.backend.service.user;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.admin.user_management.request.CreateNewUserRequest;
import nlu.fit.backend.dto.admin.user_management.request.UpdateUserInfoRequest;
import nlu.fit.backend.dto.admin.user_management.response.UserAccountResponse;
import nlu.fit.backend.dto.upload.response.UploadImageResponse;
import nlu.fit.backend.dto.user.request.UpdateUserRequest;
import nlu.fit.backend.dto.user.response.UserResponse;
import nlu.fit.backend.model.User;
import nlu.fit.backend.model.auth.Account;
import nlu.fit.backend.repository.UserRepository;
import nlu.fit.backend.repository.auth.AccountRepository;
import nlu.fit.backend.service.account.AccountService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import static nlu.fit.backend.model.User.UserGender.FEMALE;
import static nlu.fit.backend.model.User.UserGender.MALE;
import static nlu.fit.backend.model.User.UserStatus.COMPLETED;
import static nlu.fit.backend.model.User.UserStatus.INCOMPLETED;

@Service
@RequiredArgsConstructor
public class UserService {
    private final AccountService accountService;
    private final UserRepository userRepository;
    private final AccountRepository accountRepository;

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
        if (userId == null)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy thông tin người dùng");

        // Tìm kiếm User theo userId
        User user = userRepository.findById(userId).orElseThrow(
                () -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy thông tin người dùng"));

        // Thực hiện cập nhật thông tin
        String fullName = user.getFullName();
        if (fullName != null && !fullName.isEmpty()) {
            user.setFullName(request.getFullName());
        }
        switch (request.getGender().toLowerCase()) {
            case "male":
                user.setGender(MALE);
                break;
            case "female":
                user.setGender(FEMALE);
                break;
        }
        // Kiểm tra số điện thoại
        String phone = request.getPhone();
        if (!phone.equalsIgnoreCase(user.getPhone())) {
            if (userRepository.existsByPhone(request.getPhone())) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Số điện thoại đã được sử dụng");
            }
            user.setPhone(request.getPhone());
        }

        // Thiết lập trạng thái hồ sơ đã hoàn thành
        user.setStatus(COMPLETED);

        // Lưu lại thông tin
        userRepository.save(user);
    }

    // Cập nhật avatar
    @Transactional
    public void updateAvatar(Long userId, UploadImageResponse response) throws IOException {
        if (userId == null)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy thông tin người dùng");
        // Tìm kiếm người dùng theo id
        User user = userRepository.findById(userId).orElseThrow(
                () -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy thông tin người dùng"));

        // Cập nhật lại thông tin ảnh mới vào database
        user.setAvatarUrl(response.getSecureUrl());
        user.setAvatarPublicId(response.getSecureUrl());
        userRepository.save(user);
    }

    // Phương thức lấy ra user hiện tại đang đăng nhập
    public UserResponse getCurrentUser(Authentication authentication) {
        // Lấy userId từ JWT token
        Long userId = (Long) authentication.getPrincipal();
        if (userId == null)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy thông tin người dùng");
        // Tìm kiếm người dùng theo id
        User user = userRepository.findById(userId).orElseThrow(
                () -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy thông tin người dùng"));
        return convertUserToDto(user);
    }

    // Phương thức lấy ra avatarPublicId của user cụ thể (phục vụ cho việc xóa ảnh)
    public String getAvatarPublicId(Long userId) {
        if (userId == null)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy thông tin người dùng");
        // Tìm kiếm người dùng theo id
        User user = userRepository.findById(userId).orElseThrow(
                () -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy thông tin người dùng"));
        return user.getAvatarPublicId();
    }

    private UserResponse convertUserToDto(User user) {
        UserResponse userResponse = new UserResponse();
        userResponse.setId(user.getId());
        userResponse.setFullName(user.getFullName());
        userResponse.setGender(String.valueOf(user.getGender()));
        userResponse.setPhone(user.getPhone());
        userResponse.setAvatarUrl(user.getAvatarUrl());
        userResponse.setAvatarPublicId(user.getAvatarPublicId());
        userResponse.setStatus(String.valueOf(user.getStatus()));
        return userResponse;
    }

    public List<UserAccountResponse> getUserAccountList() {
        List<UserAccountResponse> result = new ArrayList<>();
        List<Account> accounts = accountRepository.findAll();
        for (Account a : accounts) {
            User u = a.getUser();
            if (u == null) continue;
            UserAccountResponse userAccountResponse = new UserAccountResponse();
            userAccountResponse.setId(u.getId());
            userAccountResponse.setFullName(u.getFullName());
            userAccountResponse.setGender(String.valueOf(u.getGender()));
            userAccountResponse.setPhone(u.getPhone());
            userAccountResponse.setAvatarUrl(u.getAvatarUrl());
            userAccountResponse.setUserStatus(String.valueOf(u.getStatus()));
            userAccountResponse.setEmail(a.getEmail());
            userAccountResponse.setRole(String.valueOf(a.getRole()));
            userAccountResponse.setAccountStatus(String.valueOf(a.getStatus()));
            result.add(userAccountResponse);
        }
        return result;
    }

    // Hàm tạo user và account mới (chức năng cho admin)
    public void createNewUser(CreateNewUserRequest request) {
        // Kiểm tra email đã tồn tại chưa
        if (accountRepository.existsByEmail(request.getEmail())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email đã được sử dụng");
        }

        User user = new User();
        // Cập nhật số điện thoại
        String phone = request.getPhone();
        if (phone != null && !phone.isEmpty()) {
            // Kiểm tra số điện thoại đã tồn tại hay chưa
            if (userRepository.existsByPhone(request.getPhone())) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "Số điện thoại đã được sử dụng");
            }
            user.setPhone(phone);
        }

        // Cập nhật giới tính
        if (request.getGender().equalsIgnoreCase("female")) {
            user.setGender(FEMALE);
        } else {
            user.setGender(MALE);
        }

        // Cập nhật tên
        if (request.getFullName() != null && !request.getFullName().isEmpty()) {
            user.setFullName(request.getFullName());
        }

        // Lưu lại user
        userRepository.save(user);

        // Tạo account mới
        accountService.createNewAccount(request.getEmail(), request.getPassword(), user);
    }

    // Hàm cập nhật thông tin user/user account (chức năng cho admin)
    @Transactional
    public void updateUserInfo(UpdateUserInfoRequest request) {
        if (request.getUserId() == null)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy thông tin người dùng");
        // Tìm kiếm người dùng theo id
        User user = userRepository.findById(request.getUserId()).orElseThrow(
                () -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy thông tin người dùng"));
        // Lấy ra account của người dùng
        Account account = user.getAccount();
        if (account == null)
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Không tìm thấy thông tin tài khoản người dùng");

        // ===== XỬ LÝ CẬP NHẬT EMAIL
        String newEmail = request.getEmail();
        // So sánh email hiện tại và trong request có khác nhau hay không
        if (!account.getEmail().equalsIgnoreCase(newEmail)) {
            // Nếu là email khác thì thực hiện thay đổi email người dùng
            accountService.changeEmail(account.getId(), newEmail);
        }

        // ===== XỬ LÝ CẬP NHẬT THÔNG TIN SỐ ĐIỆN THOẠI
        String newPhone = request.getPhone();
        if (!newPhone.equalsIgnoreCase(user.getPhone())) {
            // Nếu là sdt khác thì thực hiện thay đổi
            changePhone(user, newPhone);
        }

        // ===== XỬ LÝ CẬP NHẬT CÁC THÔNG TIN FULLNAME, GENDER
        user.setFullName(request.getFullName());
        if (request.getGender().equalsIgnoreCase("female")) {
            user.setGender(FEMALE);
        } else {
            user.setGender(MALE);
        }
        userRepository.save(user);
    }

    @Transactional
    protected void changePhone(User user, String phone) {
        if (userRepository.existsByPhone(phone)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Số điện thoại đã được sử dụng");
        }
        user.setPhone(phone);
        userRepository.save(user);
    }
}
