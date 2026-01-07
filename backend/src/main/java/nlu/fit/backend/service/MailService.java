package nlu.fit.backend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MailService {
    private final JavaMailSender mailSender;

    // Phương thức gửi mã OTP đến email
    public void sendOtp(String to, String otp) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to); // Người nhận
        message.setSubject("Xác thực email"); // Tiêu đề
        message.setText("Mã OTP của bạn là: " + otp + " (hiệu lực 5 phút)"); // Nội dung
        mailSender.send(message);
    }
}

