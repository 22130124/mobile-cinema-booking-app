package nlu.fit.backend.dto.order;

import lombok.Builder;

import java.util.List;

@Builder
public record PostOrder(
        Long showTimeId,
        Long userId,
        List<Long> seatIds,
        UserInfor userInfor,
        String seatTypeName
) {
}
