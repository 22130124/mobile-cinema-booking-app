package nlu.fit.backend.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import nlu.fit.backend.model.*;
import nlu.fit.backend.repository.OrderRepository;
import nlu.fit.backend.repository.SeatHoldRepository;
import nlu.fit.backend.repository.TicketRepository;
import nlu.fit.backend.service.VNPayService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/payment")
@RequiredArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class PaymentController {

    private final VNPayService vnPayService;
    private final OrderRepository orderRepository;
    private final SeatHoldRepository seatHoldRepository;
    private final TicketRepository ticketRepository;

    @PostMapping("/createPaymentUrl/{bookingId}")
    public ResponseEntity<Map<String, String>> createPaymentUrl(
            @PathVariable("bookingId") String bookingId,
            HttpServletRequest request) {
        try {
            Order order = orderRepository.findById(bookingId).orElseThrow(() -> new RuntimeException("Booking not found"));

            for (Ticket ticket : order.getTickets()) {

                boolean stillHeld = seatHoldRepository.existsByShowtimeIdAndSeatIdAndExpiresAtAfter(
                        order.getShowtime().getId(), ticket.getSeat().getId(), LocalDateTime.now());

                if (!stillHeld) {
                    throw new RuntimeException("Ghế " + ticket.getSeatInfo() + " đã hết hạn giữ chỗ!");
                }
            }
            long amount = order.getTotalPrice()
                    .multiply(BigDecimal.valueOf(100))
                    .longValue();
            String paymentUrl = vnPayService.createPaymentUrl(bookingId, amount, request);
            return ResponseEntity.ok(Map.of("paymentUrl", paymentUrl));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }

    @GetMapping("/ReturnUrl")
    @Transactional
    public ResponseEntity<?> handleVNPayReturn(HttpServletRequest request) {
        boolean valid = vnPayService.verifySignature(request);
        if (!valid) {
            return ResponseEntity.badRequest().build();
        }

        String responseCode = request.getParameter("vnp_ResponseCode");
        String txnRef = request.getParameter("vnp_TxnRef");
        List<Ticket> tickets;
        Order order = orderRepository.findById(txnRef).orElseThrow(() -> new RuntimeException("Booking not found"));
        if ("00".equals(responseCode)) {
            order.setStatus((byte) 1);
            order.setPaidAt(LocalDateTime.now());
            String qrData = generateQRData(order);
            order.setQrCodeData(qrData);
            List<SeatHold> seatHolds = seatHoldRepository.findByUserAndShowtime(order.getUser(), order.getShowtime());

            tickets = seatHolds.stream().map(seatHold -> {
                Seat seat = seatHold.getSeat();
                Ticket ticket = new Ticket();
                ticket.setPrice(seat.getPriceMultiplier());

                ticket.setOrder(order);

                ticket.setSeat(seat);

                String randomPart = UUID.randomUUID().toString().replace("-", "").substring(0, 6).toUpperCase();
                String generatedCode = "TKT-" + randomPart;

                ticket.setTicketCode(generatedCode);

                ticket.setShowTime(order.getShowtime());

                ticket.setSeatTypeName(getSeatTypeName(seat.getType()));

                String seatInfo = seat.getRoom().getName() + " - " + seat.getRowName() + " - " + seat.getSeatNumber();

                ticket.setSeatInfo(seatInfo);
                ticket.setStatus((byte) 1);
                return ticket;
            }).collect(Collectors.toList());

            ticketRepository.saveAll(tickets);

            order.getTickets().clear();
            order.getTickets().addAll(tickets);
            List<Long> seatIds = seatHolds.stream().map(sh -> sh.getSeat().getId()).toList();
            seatHoldRepository.deleteByShowtimeIdAndSeatIdIn(order.getShowtime().getId(), seatIds);
        } else {
            order.setStatus((byte) 2);
            List<SeatHold> seatHolds = seatHoldRepository.findByUser(order.getUser());

            List<Long> seatIds = seatHolds.stream().map(sh -> sh.getSeat().getId()).toList();

            seatHoldRepository.deleteByShowtimeIdAndSeatIdIn(order.getShowtime().getId(), seatIds);
        }

        orderRepository.save(order);
        String status = "00".equals(request.getParameter("vnp_ResponseCode")) ? "success" : "fail";
        String redirect = request.getParameter("redirect");
        String redirectUrl = buildRedirectUrl(redirect, txnRef, status);
        return ResponseEntity.status(HttpStatus.FOUND)
                .location(URI.create(redirectUrl))
                .build();
    }

    private String getSeatTypeName(Byte type) {
        int seatType = type;
        return switch (seatType) {
            case 1 -> "Thường";
            case 2 -> "VIP";
            case 3 -> "Sweetbox";
            default -> "Tiêu chuẩn";
        };
    }

    private void deleteSeatHoldsForOrder(Order order) {
        List<Long> seatIds = order.getTickets().stream()
                .map(item -> item.getSeat().getId())
                .collect(Collectors.toList());

        seatHoldRepository.deleteByShowtimeIdAndSeatIdIn(
                order.getShowtime().getId(),
                seatIds
        );
    }

    private String generateQRData(Order order) {
        return String.format(
                "order:%s|USER:%s|SHOWTIME:%s|AMOUNT:%d",
                order.getId(),
                order.getUser().getId(),
                order.getShowtime().getId(),
                order.getTotalTickets()
        );
    }

    private String buildRedirectUrl(String redirect, String orderId, String status) {
        if (redirect != null && !redirect.isBlank()) {
            try {
                return appendQuery(redirect, orderId, status);
            } catch (Exception ignored) {
            }
        }
        String encodedOrderId = URLEncoder.encode(orderId, StandardCharsets.UTF_8);
        String encodedStatus = URLEncoder.encode(status, StandardCharsets.UTF_8);
        return String.format("cinemapp://payment-result?orderId=%s&status=%s", encodedOrderId, encodedStatus);
    }

    private String appendQuery(String baseUrl, String orderId, String status) {
        String separator = baseUrl.contains("?") ? "&" : "?";
        String encodedOrderId = URLEncoder.encode(orderId, StandardCharsets.UTF_8);
        String encodedStatus = URLEncoder.encode(status, StandardCharsets.UTF_8);
        return baseUrl + separator + "orderId=" + encodedOrderId + "&status=" + encodedStatus;
    }
}
