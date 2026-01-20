package nlu.fit.backend.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.upload.response.UploadImageResponse;
import nlu.fit.backend.service.user.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class FileService {
    private final Cloudinary cloudinary;
    private final UserService userService;

    /**
     * Upload ảnh
     *
     * @param file: File ảnh cần upload
     * @param type: Thư mục chứa ảnh (vd: avatars, movies, actors,...)
     * @return kết quả trong đó bao gồm
     * public_id (id của ảnh phục vụ cho việc sau này xóa ảnh)
     * secure_url (url ảnh ở dạng https)
     */
    public UploadImageResponse uploadImage(MultipartFile file, String type) throws IOException {
        // Lấy Authentication từ SecurityContextHolder
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        // Kiểm tra authentication
        if (authentication == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED);
        }

        // Lấy ra user id
        Long userId = (Long) authentication.getPrincipal();

        if (userId == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Chưa đăng nhập vào tài khoản");
        }

        // Thực hiện upload ảnh lên Cloudinary vào thư mục /cinema
        Map result = cloudinary.uploader().upload(
                file.getBytes(),
                ObjectUtils.asMap("folder", "cinema/" + type)
        );

        // Trả về đối tượng UploadImageResponse với publicId và secureUrl
        UploadImageResponse response = new UploadImageResponse();
        response.setPublicId(result.get("public_id").toString());
        response.setSecureUrl(result.get("secure_url").toString());

        switch (type.toLowerCase()) {
            case "avatar":
                // Xóa ảnh avatar cũ (nếu có)
                String publicId = userService.getAvatarPublicId(userId);
                if (publicId != null) {
                    deleteImage(publicId);
                }

                // Cập nhật thông tin avatar mới vào database
                userService.updateAvatar(userId, response);
        }

        return response;
    }

    // Xóa ảnh
    public Map deleteImage(String publicId) throws IOException {
        return cloudinary.uploader().destroy(publicId, ObjectUtils.emptyMap());
    }
}
