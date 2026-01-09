package nlu.fit.backend.dto.order;

import lombok.Builder;

import java.math.BigDecimal;

@Builder
public record OrderResponse(String id, String orderCode, Integer status
, BigDecimal totalPrice) {
}
