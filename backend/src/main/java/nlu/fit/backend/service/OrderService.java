package nlu.fit.backend.service;

import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import nlu.fit.backend.dto.order.*;
import nlu.fit.backend.model.*;
import nlu.fit.backend.repository.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor
public class OrderService {
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final TicketRepository ticketRepository;
    private final ShowTimeRepository showTimeRepository;
    private final SeatHoldRepository seatHoldRepository;
    private final SeatRepository seatRepository;

    public List<GetOrderHistoryItem> getListOrder(Long userId) {
        User user = userRepository.findById(userId).orElseThrow(
                () -> new RuntimeException("User not found!")
        );
        List<Order> orders = orderRepository.findALLByUser(user, Pageable.unpaged());
        return convertFromOrderToOrderHistoryItemDto(orders);
    }

    @Transactional
    public OrderResponse createOrder(PostOrder input) {
        User user = userRepository.findById(input.userId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        Showtime showTime = showTimeRepository.findById((long) input.showTimeId()).orElseThrow(
                () -> new RuntimeException("Show time not found"));

        /* - Kiểm tra các ghế (seatIds) có đang trống không? (Check bảng tickets và seat_holds)         */
        List<Long> unAvailableSeatIds = input.seatIds().stream().filter(seatId -> {

            boolean isSold = ticketRepository.existsByShowTimeIdAndSeatIdAndStatus(input.showTimeId(), seatId, (byte) 1);

            boolean isHeld = seatHoldRepository.existsByShowtimeIdAndSeatIdAndExpiresAt(
                    input.showTimeId(), seatId, LocalDateTime.now());

            return isSold || isHeld;
        }).collect(Collectors.toList());

        if (!unAvailableSeatIds.isEmpty()) {
            System.out.println(unAvailableSeatIds + " are unavailable");
            return null;
        }

        /* setTime cho ghế khách đặt
        * Nên tạo seathold cho khách khi khách selected hay là khách create order
        * */
        input.seatIds().forEach(seatId -> {
            SeatHold seatHold = new SeatHold();
            Seat seat = seatRepository.findById(seatId).orElseThrow(() -> new RuntimeException("Seat not found"));
            seatHold.setUser(user);
            seatHold.setSeat(seat);
            seatHold.setShowtime(showTime);
            seatHold.setExpiresAt(LocalDateTime.now().plusMinutes(10));
            seatHoldRepository.save(seatHold);
        });

        BigDecimal totalPrice = caculationTotalPrice(input.seatIds(), showTime.getBasePrice());

        Order order = new Order();
        String orderCode = "ORD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        order.setOrderCode(orderCode);
        order.setUser(user);
        order.setShowtime(showTime);
        order.setTotalTickets(input.seatIds().size());
        order.setTotalPrice(totalPrice);
        order.setPaymentMethod("VNPay");
        order.setStatus((byte) 0);
        order.setUserName(input.userInfor().userName());
        order.setUserEmail(input.userInfor().userEmail());
        order.setUserPhone(input.userInfor().userPhone());
        order.setCreatedAt(Instant.now());
        orderRepository.save(order);
        return new OrderResponse(order.getId()
        ,order.getOrderCode(),order.getStatus().intValue(),order.getTotalPrice());
    }

    private BigDecimal caculationTotalPrice(List<Long> integers, BigDecimal basePrice) {
        List<Long> ids = integers.stream().map(Long::valueOf).collect(Collectors.toList());
        List<Seat> seats = seatRepository.findAllById(ids);
        return seats.stream().map(seat -> basePrice.multiply(seat.getPriceMultiplier()))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public GetOrderHistoryItem getOrderById(String id) {
        Order order = orderRepository.findById(id).orElseThrow(() -> new RuntimeException("Booking not found"));
        return convertFromOrderToOrderHistoryItemDto(List.of(order)).get(0);
    }

    private List<GetOrderHistoryItem> convertFromOrderToOrderHistoryItemDto(List<Order> orders) {
        return orders.stream().map(item -> {
                    Showtime showTime = showTimeRepository.findById(item.getShowtime().getId()).orElseThrow(() -> new RuntimeException("Show time not found"));
                    String seatsName = item.getTickets()
                            .stream().map(Ticket::getSeatInfo)
                            .collect(Collectors.joining(", "));

                    List<TicketDTO> ticketDTOS = item.getTickets().stream().map(ticket ->
                            new TicketDTO(ticket.getId(),ticket.getSeatInfo(), ticket.getTicketCode(), ticket.getSeat().getId())
                            ).collect(Collectors.toList());

                    ShowTimeDto showTimeDto = new ShowTimeDto(showTime.getId(), showTime.getStartTime(), showTime.getRoom().getName(),showTime.getRoom().getCinema().getName());

                    return new GetOrderHistoryItem(
                            item.getId(),
                            showTime.getMovie().getTitle(),
                            showTime.getMovie().getPosterUrl(),
                            showTime.getShowDate().format(DateTimeFormatter.ofPattern("dd.MM.yyyy")),
                            showTime.getStartTime().format(DateTimeFormatter.ofPattern("HH:mm")),
                            showTime.getRoom().getCinema().getName(),
                            seatsName,
                            item.getTotalTickets(),
                            item.getStatus(),
                            item.getQrCodeData(),
                            showTimeDto,
                            ticketDTOS
                    );
                }
        ).collect(Collectors.toList());
    }

    public OrderResponse cancelOrder(String id) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));

        if(order.getStatus() == 0 || order.getStatus() == 1) {
            order.setStatus((byte) 2);
        }

        seatHoldRepository.deleteByShowtimeIdAndSeatIdIn(
                order.getShowtime().getId(),
                order.getTickets().stream().map(item -> item.getSeat().getId()).toList()
        );

        return mapToResponse(orderRepository.save(order));
    }

    public OrderResponse confirmPaidOrder(String id) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));

        if (order.getStatus() == 1) {
            throw new RuntimeException("Đơn hàng này đã được thanh toán rồi");
        }

        order.setStatus((byte) 1);
        order.setPaidAt(LocalDateTime.now());

        // create QRCODE

        return mapToResponse(orderRepository.save(order));
    }

    public Page<OrderResponse> filterOrders(OrderFilterRequest filter, Pageable pageable) {
        Specification<Order> spec = Specification.where((Specification<Order>) null);

        if (filter.orderCode() != null) {
            spec = spec.and((root, query, cb) -> cb.like(root.get("orderCode"), "%" + filter.orderCode() + "%"));
        }
        if (filter.userEmail() != null) {
            spec = spec.and((root, query, cb) -> cb.equal(root.get("userEmail"), filter.userEmail()));
        }
        if (filter.status() != null) {
            spec = spec.and((root, query, cb) -> cb.equal(root.get("status"), filter.status()));
        }
        if (filter.startDate() != null && filter.endDate() != null) {
            spec = spec.and((root, query, cb) -> cb.between(root.get("createdAt"), filter.startDate(), filter.endDate()));
        }

        return orderRepository.findAll(spec, pageable).map(this::mapToResponse);
    }

    private OrderResponse mapToResponse(Order order) {
        return OrderResponse.builder()
                .id(order.getId())
                .orderCode(order.getOrderCode())
                .status(order.getStatus().intValue())
                .totalPrice(order.getTotalPrice())
                .build();
    }
}
