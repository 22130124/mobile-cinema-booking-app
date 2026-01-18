package nlu.fit.backend.service.admin;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.admin.report.DailyRevenuePoint;
import nlu.fit.backend.dto.admin.report.ReportOverviewResponse;
import nlu.fit.backend.repository.admin.DailyRevenueRow;
import nlu.fit.backend.repository.OrderRepository;
import nlu.fit.backend.repository.admin.ReportRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminReportService {

    private final ReportRepository reportRepository;
    private final OrderRepository orderRepository;

    public ReportOverviewResponse overview(LocalDateTime from, LocalDateTime to, Long cinemaId) {
        // Pass the optional cinemaId to repository methods. If cinemaId is null
        // repository methods will aggregate across all cinemas.
        return new ReportOverviewResponse(
                reportRepository.sumRevenuePaid(from, to, cinemaId),
                reportRepository.countPaidOrders(from, to, cinemaId),
                reportRepository.sumTicketsSold(from, to, cinemaId)
        );
    }

    public List<DailyRevenuePoint> getRevenueDaily(LocalDateTime from, LocalDateTime to, Long cinemaId) {
        // Forward cinemaId to native query. If null, query returns all cinemas.
        List<DailyRevenueRow> rows = orderRepository.revenueDaily(from, to, cinemaId);
        return rows.stream()
                .map(r -> new DailyRevenuePoint(
                        r.getDay(), // map day -> date
                        r.getRevenue().doubleValue(),
                        r.getPaidOrders().intValue(),
                        r.getTicketsSold().intValue()
                ))
                .toList();
    }
}
