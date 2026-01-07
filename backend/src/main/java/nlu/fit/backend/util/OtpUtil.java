package nlu.fit.backend.util;

import java.util.Random;

public class OtpUtil {
    // Phương thức tạo ra mã OTP 6 số
    public static String generateOtp() {
        return String.valueOf(100000 + new Random().nextInt(900000));
    }
}