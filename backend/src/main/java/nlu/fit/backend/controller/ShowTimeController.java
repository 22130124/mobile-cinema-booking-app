package nlu.fit.backend.controller;

import lombok.AllArgsConstructor;
import nlu.fit.backend.dto.showtime.ShowtimeSeatDto;
import nlu.fit.backend.dto.showtime.ShowtimeSeatResponse;
import nlu.fit.backend.dto.showtime.ShowtimeSummaryDto;
import nlu.fit.backend.model.Seat;
import nlu.fit.backend.model.SeatHold;
import nlu.fit.backend.model.Showtime;
import nlu.fit.backend.repository.SeatHoldRepository;
import nlu.fit.backend.repository.SeatRepository;
import nlu.fit.backend.repository.ShowTimeRepository;
import nlu.fit.backend.repository.TicketRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@RestController
@RequestMapping("/api/showtimes")
@AllArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class ShowTimeController {
    private final ShowTimeRepository showTimeRepository;
    private final SeatRepository seatRepository;
    private final SeatHoldRepository seatHoldRepository;
    private final TicketRepository ticketRepository;

    @GetMapping
    public ResponseEntity<List<ShowtimeSummaryDto>> getShowtimes(@RequestParam Long movieId) {
        List<Showtime> showtimes = showTimeRepository.findByMovieIdOrderByShowDateAscStartTimeAsc(movieId);
        List<ShowtimeSummaryDto> result = showtimes.stream()
                .map(showtime -> new ShowtimeSummaryDto(
                        showtime.getId(),
                        showtime.getShowDate(),
                        showtime.getStartTime(),
                        showtime.getRoom().getName(),
                        showtime.getRoom().getCinema().getName()
                ))
                .toList();
        return ResponseEntity.ok(result);
    }

    @GetMapping("/{showtimeId}/seats")
    public ResponseEntity<ShowtimeSeatResponse> getSeatMap(
            @PathVariable Long showtimeId,
            @RequestParam(required = false) Long userId
    ) {
        Showtime showtime = showTimeRepository.findById(showtimeId)
                .orElseThrow(() -> new RuntimeException("Showtime not found"));

        List<Seat> seats = seatRepository.findByRoomIdOrderByRowNameAscSeatNumberAsc(
                showtime.getRoom().getId()
        );

        Set<Long> bookedSeatIds = new HashSet<>(
                ticketRepository.findSeatIdsByShowTimeIdAndStatus(showtimeId, (byte) 1)
        );

        Map<Long, Long> holdSeatToUser = new HashMap<>();
        List<SeatHold> activeHolds = seatHoldRepository.findByShowtimeIdAndExpiresAtAfter(
                showtimeId, LocalDateTime.now()
        );
        for (SeatHold hold : activeHolds) {
            holdSeatToUser.put(hold.getSeat().getId(), hold.getUser().getId());
        }

        List<ShowtimeSeatDto> seatDtos = new ArrayList<>();
        for (Seat seat : seats) {
            String status = "AVAILABLE";
            if (bookedSeatIds.contains(seat.getId())) {
                status = "BOOKED";
            } else {
                Long holdUserId = holdSeatToUser.get(seat.getId());
                if (holdUserId != null) {
                    status = (userId != null && holdUserId.equals(userId)) ? "MINE_HELD" : "HELD";
                }
            }
            seatDtos.add(new ShowtimeSeatDto(
                    seat.getId(),
                    seat.getRowName(),
                    seat.getSeatNumber(),
                    status
            ));
        }

        return ResponseEntity.ok(new ShowtimeSeatResponse(showtimeId, seatDtos));
    }
}
