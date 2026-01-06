package nlu.fit.backend.config;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.NonNull;
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

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request,
                                    @NonNull HttpServletResponse response,
                                    @NonNull FilterChain filterChain) throws ServletException, IOException {
        // Lấy header Authorization từ request
        String authHeader = request.getHeader(HttpHeaders.AUTHORIZATION);

        // Nếu header không có hoặc không bắt đầu bằng "Bearer ", bỏ qua filter này
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        try {
            // Giải mã JWT từ header, kiểm tra chữ ký bằng jwtSecret
            Claims claims = Jwts.parser()
                    .setSigningKey(jwtSecret.getBytes())
                    .build()
                    .parseSignedClaims(authHeader.substring(7))
                    .getPayload();

            // Lấy thông tin email và role từ JWT
            String email = claims.getSubject();
            String role = claims.get("role", String.class);

            // Tạo đối tượng Authentication để lưu thông tin người dùng vào SecurityContext
            var auth = new UsernamePasswordAuthenticationToken(
                    email,
                    null,
                    List.of(new SimpleGrantedAuthority("ROLE_" + role))
            );

            // Lưu Authentication vào SecurityContext, để Spring Security biết người dùng đã đăng nhập
            SecurityContextHolder.getContext().setAuthentication(auth);

            // Tiếp tục cho request đi qua các filter khác
            filterChain.doFilter(request, response);

        } catch (Exception e) {
            // Nếu JWT không hợp lệ, trả về 401 Unauthorized
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        }
    }
}

