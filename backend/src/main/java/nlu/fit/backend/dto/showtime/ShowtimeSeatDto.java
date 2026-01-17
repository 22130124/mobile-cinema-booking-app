package nlu.fit.backend.dto.showtime;

import java.math.BigDecimal;

public record ShowtimeSeatDto(
        Long seatId,
        String rowName,
        Integer seatNumber,
        String status,
        String seatTypeName,
        BigDecimal price
) {
}
