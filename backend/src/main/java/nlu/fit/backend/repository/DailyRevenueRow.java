package nlu.fit.backend.repository;

import java.time.LocalDate;

public interface DailyRevenueRow {
    LocalDate getDay();
    Number getRevenue();      // dùng Number để tránh lệ thuộc Long/BigDecimal
    Number getPaidOrders();
    Number getTicketsSold();
}
