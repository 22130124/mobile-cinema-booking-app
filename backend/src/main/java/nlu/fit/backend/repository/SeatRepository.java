package nlu.fit.backend.repository;

import nlu.fit.backend.model.Seat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SeatRepository extends JpaRepository<Seat,Long> {
    List<Seat> findByRoomIdOrderByRowNameAscSeatNumberAsc(Long roomId);
}
