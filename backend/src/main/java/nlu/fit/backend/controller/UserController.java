package nlu.fit.backend.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.user.request.UpdateUserRequest;
import nlu.fit.backend.service.user.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @PutMapping
    public ResponseEntity<?> updateProfile(Authentication authentication,
                                           @Valid @RequestBody UpdateUserRequest request) {
        userService.updateProfile(authentication, request);
        return ResponseEntity.ok().build();
    }
}