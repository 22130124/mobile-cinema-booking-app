package nlu.fit.backend.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.admin.user_management.request.CreateNewUserRequest;
import nlu.fit.backend.dto.admin.user_management.request.UpdateUserInfoRequest;
import nlu.fit.backend.dto.user.request.UpdateUserRequest;
import nlu.fit.backend.dto.admin.user_management.response.UserAccountResponse;
import nlu.fit.backend.dto.user.response.UserResponse;
import nlu.fit.backend.service.user.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @PutMapping
    public ResponseEntity<?> updateProfile(Authentication authentication,
                                           @Valid @RequestBody UpdateUserRequest request) {
        userService.updateProfile(authentication, request);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(Authentication authentication) {
        UserResponse user = userService.getCurrentUser(authentication);
        return ResponseEntity.ok().body(user);
    }

    @GetMapping("/admin")
    public ResponseEntity<?> getUserAccountList() {
        List<UserAccountResponse> result = userService.getUserAccountList();
        return ResponseEntity.ok().body(result);
    }

    @PostMapping("/admin")
    public ResponseEntity<?> createNewUser(@RequestBody CreateNewUserRequest request) {
        userService.createNewUser(request);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/admin")
    public ResponseEntity<?> updateUserInfo(@RequestBody UpdateUserInfoRequest request) {
        userService.updateUserInfo(request);
        return ResponseEntity.ok().build();
    }
}
