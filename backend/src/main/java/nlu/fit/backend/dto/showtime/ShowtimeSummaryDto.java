package nlu.fit.backend.dto.showtime;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record ShowtimeSummaryDto(
        Long id,
        LocalDate showDate,
        LocalDateTime startTime,
        String roomName,
        String cinemaName
) {
}
