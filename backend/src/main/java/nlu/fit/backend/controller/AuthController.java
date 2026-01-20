package nlu.fit.backend.controller;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.auth.request.*;
import nlu.fit.backend.dto.auth.response.LoginResponse;
import nlu.fit.backend.service.account.AccountService;
import nlu.fit.backend.service.auth.AuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import static nlu.fit.backend.model.auth.Account.AccountRole.ADMIN;
import static nlu.fit.backend.model.auth.Account.AccountRole.USER;
import static nlu.fit.backend.model.auth.Account.AccountStatus.ACTIVE;
import static nlu.fit.backend.model.auth.Account.AccountStatus.INACTIVE;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;
    private final AccountService accountService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        authService.register(request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        LoginResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/google-login")
    public ResponseEntity<?> loginGoogle(@RequestBody GoogleLoginRequest request) {
        LoginResponse response = authService.loginGoogle(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/resend-otp")
    public ResponseEntity<?> resendRegisterOtp(@RequestBody ResendOtpRequest request) {
        authService.resendOtp(request);
        return ResponseEntity.ok().build();
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
        authService.resetPassword(request, null);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/reset-password-for-current")
    public ResponseEntity<?> resetPasswordForCurrentUser(@RequestBody ResetPasswordRequest request, Authentication authentication) {
        authService.resetPassword(request, authentication);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/check-old-password")
    public ResponseEntity<?> checkOldPassword(@RequestBody CheckOldPasswordRequest request, Authentication authentication) {
        authService.checkOldPassword(request, authentication);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/admin/lock")
    public ResponseEntity<?> lockAccount(@RequestBody EmailRequest request) {
        accountService.changeStatus(request, INACTIVE);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/admin/unlock")
    public ResponseEntity<?> unlockAccount(@RequestBody EmailRequest request) {
        accountService.changeStatus(request, ACTIVE);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/admin/set-admin")
    public ResponseEntity<?> setAdmin(@RequestBody EmailRequest request) {
        accountService.changeRole(request, ADMIN);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/admin/set-user")
    public ResponseEntity<?> setUser(@RequestBody EmailRequest request) {
        accountService.changeRole(request, USER);
        return ResponseEntity.ok().build();
    }
}
