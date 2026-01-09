package nlu.fit.backend.dto.order;

import lombok.Builder;
import java.math.BigDecimal;
import java.util.List;

@Builder
public record GetOrderHistoryItem(
        String id,
        String title,
        String posterUrl,
        String date,
        String time,
        String cinema,
        String seats,
        BigDecimal amount,
        int status,
        String qrData,
        ShowTimeDto showTime,
        List<TicketDTO> tickets

) {
}
