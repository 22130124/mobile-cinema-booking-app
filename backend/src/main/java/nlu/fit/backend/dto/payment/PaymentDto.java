package nlu.fit.backend.dto.payment;

import lombok.Data;

@Data
public class PaymentDto {
    private long amount;
    private String orderInfo;
}
