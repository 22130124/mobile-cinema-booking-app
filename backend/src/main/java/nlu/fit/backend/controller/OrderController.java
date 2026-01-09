package nlu.fit.backend.controller;

import lombok.AllArgsConstructor;
import nlu.fit.backend.dto.order.*;
import nlu.fit.backend.model.Order;
import nlu.fit.backend.repository.OrderRepository;
import nlu.fit.backend.repository.SeatHoldRepository;
import nlu.fit.backend.service.OrderService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/booking")
@AllArgsConstructor
@CrossOrigin(origins = "*", maxAge = 3600)
public class OrderController {
    private final OrderService orderService;
    private final SeatHoldRepository seatHoldRepository;
    private final OrderRepository orderRepository;

    @GetMapping("/getListBooking/{userId}")
    public ResponseEntity<List<GetOrderHistoryItem>> getListOrder(@PathVariable Long userId) {
        return ResponseEntity.ok(orderService.getListOrder(userId));
    }

    @GetMapping("/getOrderById/{id}")
    public ResponseEntity<GetOrderHistoryItem> getOrderById(@PathVariable String id) {
        return ResponseEntity.ok(orderService.getOrderById(id));
    }

    @PostMapping("/createOrder")
    public ResponseEntity<OrderResponse> createOrder(
            @RequestBody PostOrder order) {
        return ResponseEntity.ok(orderService.createOrder(order));
    }

    @PutMapping("/{id}/cancel")
    public ResponseEntity<OrderResponse> cancelOrder(
            @PathVariable String id
    ) {
        return ResponseEntity.ok(orderService.cancelOrder(id));
    }

    @PutMapping("/{id}/confirm-paid")
    public ResponseEntity<OrderResponse> confirmPaidOrder(
            @PathVariable String id
    ) {
        return ResponseEntity.ok(orderService.confirmPaidOrder(id));
    }

    @GetMapping("/filter")
    public ResponseEntity<Page<OrderResponse>> filterOrders(
            OrderFilterRequest filter,
            @PageableDefault(size = 10, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable
    ) {
        return ResponseEntity.ok(orderService.filterOrders(filter, pageable));
    }

    @DeleteMapping("/deleteSeatHoldByUser/{orderId}")
    public ResponseEntity<?> cancelSeatHold(@PathVariable String orderId) {
        Order order = orderRepository.findById(orderId).orElseThrow(() -> new RuntimeException("Order not found"));
        try {
            System.out.println("Here");
            seatHoldRepository.deleteByUserIdAndShowtime(order.getUser().getId(), order.getShowtime());
            return ResponseEntity.ok("Đã giải phóng ghế thành công.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Lỗi: " + e.getMessage());
        }
    }
}
