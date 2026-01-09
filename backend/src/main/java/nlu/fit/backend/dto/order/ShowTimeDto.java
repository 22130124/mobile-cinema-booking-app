package nlu.fit.backend.dto.order;

import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record ShowTimeDto(
        Long id,
        LocalDateTime startTime,
        String roomName,
        String cinemaName
) {
}
