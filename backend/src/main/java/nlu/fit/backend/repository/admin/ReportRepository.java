package nlu.fit.backend.repository.admin;

import nlu.fit.backend.model.Order;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Component
public interface ReportRepository extends Repository<Order, String> {

    @Query("""
        select coalesce(sum(o.totalPrice), 0)
        from Order o
        where o.status = 1
          and o.paidAt between :from and :to
          and (:cinemaId is null or o.showtime.room.cinema.id = :cinemaId)
    """)
        java.math.BigDecimal sumRevenuePaid(LocalDateTime from, LocalDateTime to, Long cinemaId);

    @Query("""
        select count(o)
        from Order o
        where o.status = 1
          and o.paidAt between :from and :to
          and (:cinemaId is null or o.showtime.room.cinema.id = :cinemaId)
    """)
        long countPaidOrders(LocalDateTime from, LocalDateTime to, Long cinemaId);

    @Query("""
        select coalesce(sum(o.totalTickets), 0)
        from Order o
        where o.status = 1
          and o.paidAt between :from and :to
          and (:cinemaId is null or o.showtime.room.cinema.id = :cinemaId)
    """)
    long sumTicketsSold(LocalDateTime from, LocalDateTime to, Long cinemaId);
}
