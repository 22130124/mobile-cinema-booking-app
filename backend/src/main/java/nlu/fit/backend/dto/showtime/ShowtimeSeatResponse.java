package nlu.fit.backend.dto.showtime;

import java.math.BigDecimal;
import java.util.List;

public record ShowtimeSeatResponse(
        Long showtimeId,
        BigDecimal basePrice,
        List<ShowtimeSeatDto> seats
) {
}
