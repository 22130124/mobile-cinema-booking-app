package nlu.fit.backend.dto.admin.report;

import java.time.LocalDate;

public record DailyRevenuePoint(
        LocalDate date,
        double revenue,
        int paidOrders,
        int ticketsSold
) {}
