package nlu.fit.backend.service.admin;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.admin.report.DailyRevenuePoint;
import nlu.fit.backend.dto.admin.report.ReportOverviewResponse;
import nlu.fit.backend.repository.DailyRevenueRow;
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

    public ReportOverviewResponse overview(LocalDateTime from, LocalDateTime to) {
        return new ReportOverviewResponse(
                reportRepository.sumRevenuePaid(from, to),
                reportRepository.countPaidOrders(from, to),
                reportRepository.sumTicketsSold(from, to)
        );
    }

    public List<DailyRevenuePoint> getRevenueDaily(LocalDateTime from, LocalDateTime to) {
        List<DailyRevenueRow> rows = orderRepository.revenueDaily(from, to);
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
