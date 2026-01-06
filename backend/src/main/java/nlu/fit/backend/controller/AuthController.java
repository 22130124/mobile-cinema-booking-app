package nlu.fit.backend.controller;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.auth.request.*;
import nlu.fit.backend.service.AuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;

    @GetMapping("/check")
    public ResponseEntity<?> checkHealth() {
        String result = authService.checkHealth();
        Map<String, String> map = Map.of("result", result);
        return ResponseEntity.ok(map);
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        authService.register(request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        String jwtToken = authService.login(request);
        return ResponseEntity.ok(jwtToken);
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestBody VerifyOtpRequest request) {
        String result = authService.verifyOtp(request);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> processForgotPassword(@RequestBody ForgotPasswordRequest request) {
        authService.processForgotPassword(request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody ChangePasswordRequest request) {
        authService.changePassword(request);

        return ResponseEntity.ok().build();
    }
}
