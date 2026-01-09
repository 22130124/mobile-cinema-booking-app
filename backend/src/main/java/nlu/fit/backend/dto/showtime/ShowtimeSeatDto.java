package nlu.fit.backend.dto.showtime;

public record ShowtimeSeatDto(
        Long seatId,
        String rowName,
        Integer seatNumber,
        String status
) {
}
