package nlu.fit.backend.dto.order;

import lombok.Builder;

@Builder
public record TicketDTO(
        Long id,
        String seatInfo,
        String ticketCode,
        Long seatId
) {
}
