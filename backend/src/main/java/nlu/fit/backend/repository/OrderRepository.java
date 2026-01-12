package nlu.fit.backend.repository;

import nlu.fit.backend.model.Order;
import nlu.fit.backend.model.User;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;


@Repository
public interface OrderRepository extends JpaRepository<Order,String>, JpaSpecificationExecutor<Order> {

    List<Order> findALLByUser(User user, Pageable pageable);

    @Query(value = """
        SELECT
          DATE(o.paid_at) AS day,
          COALESCE(SUM(o.total_price), 0) AS revenue,
          COUNT(*) AS paidOrders,
          COALESCE(SUM(o.total_tickets), 0) AS ticketsSold
        FROM orders o
        WHERE o.status = 1
          AND o.paid_at IS NOT NULL
          AND o.paid_at BETWEEN :from AND :to
        GROUP BY DATE(o.paid_at)
        ORDER BY DATE(o.paid_at) ASC
        """, nativeQuery = true)
    List<DailyRevenueRow> revenueDaily(
            @Param("from") LocalDateTime from,
            @Param("to") LocalDateTime to
    );
}
