package nlu.fit.backend.repository;

import nlu.fit.backend.model.Ticket;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TicketRepository extends JpaRepository<Ticket,Long> {
    boolean existsByShowTimeIdAndSeatId(Long showTimeId, Long seatId);

    boolean existsByShowTimeIdAndSeatIdAndStatus(Long showTimeId, Long seatId, Byte status);
}
