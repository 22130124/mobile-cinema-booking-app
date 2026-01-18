package nlu.fit.backend.dto.admin.report;

import java.math.BigDecimal;

public record ReportOverviewResponse(
        BigDecimal totalRevenue,
        long totalPaidOrders,
        long totalTicketsSold
) {}
