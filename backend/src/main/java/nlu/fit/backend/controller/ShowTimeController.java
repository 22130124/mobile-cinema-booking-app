package nlu.fit.backend.controller;

import lombok.AllArgsConstructor;
import nlu.fit.backend.dto.showtime.ShowtimeSeatDto;
import nlu.fit.backend.dto.showtime.ShowtimeSeatResponse;
import nlu.fit.backend.dto.showtime.ShowtimeSummaryDto;
import nlu.fit.backend.dto.showtime.SeatHoldRequest;
import nlu.fit.backend.model.Cinema;
import nlu.fit.backend.model.Seat;
import nlu.fit.backend.model.SeatHold;
import nlu.fit.backend.model.Showtime;
import nlu.fit.backend.model.User;
import nlu.fit.backend.repository.SeatHoldRepository;
import nlu.fit.backend.repository.SeatRepository;
import nlu.fit.backend.repository.ShowTimeRepository;
import nlu.fit.backend.repository.TicketRepository;
import nlu.fit.backend.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/showtimes")
@AllArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class ShowTimeController {
    private final ShowTimeRepository showTimeRepository;
    private final SeatRepository seatRepository;
    private final SeatHoldRepository seatHoldRepository;
    private final TicketRepository ticketRepository;
    private final UserRepository userRepository;

    @GetMapping
    public ResponseEntity<List<ShowtimeSummaryDto>> getShowtimes(@RequestParam Long movieId) {
        List<Showtime> showtimes = showTimeRepository.findByMovieIdOrderByShowDateAscStartTimeAsc(movieId);
        List<ShowtimeSummaryDto> result = showtimes.stream()
                .map(showtime -> {
                    Cinema cinema = showtime.getRoom().getCinema();
                    return new ShowtimeSummaryDto(
                            showtime.getId(),
                            showtime.getShowDate(),
                            showtime.getStartTime(),
                            showtime.getRoom().getName(),
                            cinema.getId(),
                            cinema.getName(),
                            cinema.getAddress(),
                            cinema.getCity(),
                            cinema.getImageUrl()
                    );
                })
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


    @PostMapping("/{showtimeId}/holds")
    public ResponseEntity<?> holdSeats(
            @PathVariable Long showtimeId,
            @RequestBody SeatHoldRequest request
    ) {
        if (request == null || request.userId() == null || request.seatIds() == null || request.seatIds().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        Showtime showtime = showTimeRepository.findById(showtimeId)
                .orElseThrow(() -> new RuntimeException("Showtime not found"));
        User user = userRepository.findById(request.userId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        Set<Long> seatIds = new HashSet<>(request.seatIds());
        List<Seat> seats = seatRepository.findAllById(seatIds);
        if (seats.size() != seatIds.size()) {
            return ResponseEntity.badRequest().build();
        }
        Map<Long, Seat> seatById = seats.stream()
                .collect(Collectors.toMap(Seat::getId, seat -> seat));

        LocalDateTime now = LocalDateTime.now();
        List<Long> unavailable = new ArrayList<>();
        for (Long seatId : seatIds) {
            Seat seat = seatById.get(seatId);
            if (seat == null || !seat.getRoom().getId().equals(showtime.getRoom().getId())) {
                return ResponseEntity.badRequest().build();
            }
            boolean isSold = ticketRepository.existsByShowTimeIdAndSeatIdAndStatus(showtimeId, seatId, (byte) 1);
            if (isSold) {
                unavailable.add(seatId);
                continue;
            }
            SeatHold existingHold = seatHoldRepository
                    .findFirstByShowtimeIdAndSeatIdAndExpiresAtAfter(showtimeId, seatId, now)
                    .orElse(null);
            if (existingHold != null && !existingHold.getUser().getId().equals(user.getId())) {
                unavailable.add(seatId);
            }
        }

        if (!unavailable.isEmpty()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(unavailable);
        }

        LocalDateTime expiresAt = now.plusMinutes(10);
        for (Long seatId : seatIds) {
            SeatHold existingHold = seatHoldRepository
                    .findFirstByShowtimeIdAndSeatIdAndExpiresAtAfter(showtimeId, seatId, now)
                    .orElse(null);
            if (existingHold != null) {
                existingHold.setHeldAt(now);
                existingHold.setExpiresAt(expiresAt);
                seatHoldRepository.save(existingHold);
                continue;
            }
            Seat seat = seatById.get(seatId);
            SeatHold seatHold = new SeatHold();
            seatHold.setUser(user);
            seatHold.setSeat(seat);
            seatHold.setShowtime(showtime);
            seatHold.setExpiresAt(expiresAt);
            seatHoldRepository.save(seatHold);
        }

        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{showtimeId}/holds")
    public ResponseEntity<?> releaseSeats(
            @PathVariable Long showtimeId,
            @RequestBody SeatHoldRequest request
    ) {
        if (request == null || request.userId() == null || request.seatIds() == null || request.seatIds().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        seatHoldRepository.deleteByUserIdAndShowtimeIdAndSeatIdIn(
                request.userId(),
                showtimeId,
                new HashSet<>(request.seatIds())
        );
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{showtimeId}/holds/release")
    public ResponseEntity<?> releaseSeatsViaPost(
            @PathVariable Long showtimeId,
            @RequestBody SeatHoldRequest request
    ) {
        return releaseSeats(showtimeId, request);
    }
}
