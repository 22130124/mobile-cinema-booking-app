package nlu.fit.backend.dto.order;

import lombok.Builder;
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
        int amount,
        int status,
        String qrData,
        ShowTimeDto showTime,
        List<TicketDTO> tickets

) {
}
