package nlu.fit.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.math.BigDecimal;

@Getter
@Setter
@Entity
@Table(name = "seats")
public class Seat {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.CASCADE)
    @JoinColumn(name = "room_id", nullable = false)
    private Room room;

    @Column(name = "row_name", nullable = false, length = 5)
    private String rowName;

    @Column(name = "seat_number", nullable = false)
    private Integer seatNumber;

    @ColumnDefault("1")
    @Column(name = "type")
    private Byte type;

    @ColumnDefault("1.00")
    @Column(name = "price_multiplier", precision = 3, scale = 2)
    private BigDecimal priceMultiplier;

    @ColumnDefault("1")
    @Column(name = "status")
    private Byte status;

}