package nlu.fit.backend.dto.showtime;

import java.util.List;

public record SeatHoldRequest(
        Long userId,
        List<Long> seatIds
) {
}
