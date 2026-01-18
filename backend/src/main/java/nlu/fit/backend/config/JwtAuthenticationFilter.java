package nlu.fit.backend.config;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    // Secret key dùng để verify chữ ký JWT
    @Value("${jwt.secret}")
    private String jwtSecret;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        // 1. Lấy header Authorization từ request
        String authHeader = request.getHeader(HttpHeaders.AUTHORIZATION);

        // 2. Nếu không có header hoặc không bắt đầu bằng "Bearer "
        //    → coi như request chưa đăng nhập
        //    → cho đi tiếp để các API permitAll hoạt động bình thường
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        // 3. Cắt lấy phần token (bỏ "Bearer ")
        String token = authHeader.substring(7);

        try {
            // 4. Giải mã và verify JWT bằng secret key
            Claims claims = Jwts.parser()
                    .setSigningKey(jwtSecret.getBytes())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            // Lấy thông tin từ JWT
            Long userId = Long.valueOf(claims.getSubject());
            String role = claims.get("role", String.class);

            // 6. Tạo Authentication object
            //    - principal: email
            //    - credentials: null (không cần password)
            //    - authorities: ROLE_<role>
            var auth = new UsernamePasswordAuthenticationToken(
                    userId,
                    null,
                    List.of(new SimpleGrantedAuthority("ROLE_" + role))
            );

            // 7. Lưu Authentication vào SecurityContext
            //    → Spring Security hiểu rằng user đã đăng nhập
            SecurityContextHolder.getContext().setAuthentication(auth);

        } catch (Exception e) {
            // 8. Nếu JWT không hợp lệ (sai chữ ký, hết hạn, token lỗi...)
            //    → xóa SecurityContext để tránh dính auth cũ
            SecurityContextHolder.clearContext();

            // 9. Trả về 401 Unauthorized
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);

            // 10. Dừng request ngay, không cho đi tiếp xuống controller
            return;
        }

        // 11. Cho request đi tiếp qua các filter còn lại và tới controller
        //     (nằm ngoài try-catch để lỗi business không bị biến thành 401)
        filterChain.doFilter(request, response);
    }
}
