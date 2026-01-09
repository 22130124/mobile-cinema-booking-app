package nlu.fit.backend.dto.showtime;

import java.util.List;

public record ShowtimeSeatResponse(
        Long showtimeId,
        List<ShowtimeSeatDto> seats
) {
}
