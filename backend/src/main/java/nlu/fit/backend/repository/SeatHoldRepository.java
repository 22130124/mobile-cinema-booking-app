package nlu.fit.backend.repository;

import nlu.fit.backend.model.SeatHold;
import nlu.fit.backend.model.Showtime;
import nlu.fit.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;

@Repository
public interface SeatHoldRepository extends JpaRepository<SeatHold,Long> {

    void deleteByShowtimeIdAndSeatIdIn(Long showtimeId, Collection<Long> seatIds);

    List<SeatHold> findByUser(User user);

    void deleteByUserId(Long userId);

    void deleteByUserIdAndShowtime(Long userId, Showtime showtime);

    List<SeatHold> findByUserAndShowtime(User user, Showtime showtime);

    boolean existsByShowtimeIdAndSeatIdAndExpiresAtAfter(Long showtimeId, Long seatId, LocalDateTime expiresAtAfter);

    boolean existsByShowtimeIdAndSeatIdAndExpiresAt(Long showtimeId, Long seatId, LocalDateTime expiresAt);

    List<SeatHold> findByShowtimeIdAndExpiresAtAfter(Long showtimeId, LocalDateTime expiresAtAfter);
}
