package nlu.fit.backend.repository;

import nlu.fit.backend.model.Ticket;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TicketRepository extends JpaRepository<Ticket,Long> {
    boolean existsByShowTimeIdAndSeatId(Long showTimeId, Long seatId);

    boolean existsByShowTimeIdAndSeatIdAndStatus(Long showTimeId, Long seatId, Byte status);

    @Query("select t.seat.id from Ticket t where t.showTime.id = ?1 and t.status = ?2")
    List<Long> findSeatIdsByShowTimeIdAndStatus(Long showTimeId, Byte status);
}
