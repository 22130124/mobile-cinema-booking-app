package nlu.fit.backend.controller.admin;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.admin.report.DailyRevenuePoint;
import nlu.fit.backend.dto.admin.report.ReportOverviewResponse;
import nlu.fit.backend.service.admin.AdminReportService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/auth/admin/reports")
@RequiredArgsConstructor
public class AdminReportController {

    private final AdminReportService adminReportService;

    @GetMapping("/overview")
    public ReportOverviewResponse overview(
            @RequestParam("from") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime from,
            @RequestParam("to") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime to
            , @RequestParam(value = "cinemaId", required = false) Long cinemaId
    ) {
        // Optional cinemaId query parameter to filter report for a specific cinema
        // Example: /auth/admin/reports/overview?from=...&to=...&cinemaId=2
        return adminReportService.overview(from, to, cinemaId);
    }

    @GetMapping("/revenue-daily")
    public List<DailyRevenuePoint> revenueDaily(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss") LocalDateTime from,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss") LocalDateTime to
            , @RequestParam(value = "cinemaId", required = false) Long cinemaId
    ) {
        return adminReportService.getRevenueDaily(from, to, cinemaId);
    }
}
