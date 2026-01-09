package nlu.fit.backend.dto.order;

import lombok.Builder;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Builder
public record OrderFilterResponse(
        String id,
        String orderCode,
        String userEmail,
        String userName,
        String userPhone,
        BigDecimal totalPrice,
        int status, // 0: Pending, 1: Paid, 2: Canceled
        LocalDateTime createdAt,
        String qrCodeData,
        List<TicketDTO> tickets
) {
}
