package nlu.fit.backend.controller;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.upload.response.UploadImageResponse;
import nlu.fit.backend.service.FileService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@RestController
@RequestMapping("/api/files")
@RequiredArgsConstructor
public class FileController {
    private final FileService uploadService;

    /**
     * Upload ảnh đại diện người dùng
     * @param file: file ảnh cần upload
     * @return public_id: id ảnh trên server; secure_url: url của ảnh ở dạng https
     */
    @PostMapping("/image/avatar")
    public ResponseEntity<?> uploadImageAvatar(@RequestParam("file") MultipartFile file) {
        try {
            UploadImageResponse result = uploadService.uploadImage(file, "avatar");
            return ResponseEntity.ok(result);
        } catch (IOException e) {
            return ResponseEntity.badRequest().body("Upload failed: " + e.getMessage());
        }
    }

    /**
     * Xóa ảnh
     * @param publicId: id của ảnh trên Cloudinary
     * @return kết quả xóa
     */
    @DeleteMapping("/image")
    public ResponseEntity<?> deleteImage(@RequestParam("publicId") String publicId) {
        try {
            Map result = uploadService.deleteImage(publicId);
            return ResponseEntity.ok(result);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().body(Map.of("error", e.getMessage()));
        }
    }
}
