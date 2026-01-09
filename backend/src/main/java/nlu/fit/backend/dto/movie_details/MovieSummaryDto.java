package nlu.fit.backend.dto.movie_details;

import java.math.BigDecimal;
import java.time.LocalDate;

public record MovieSummaryDto(
        Long id,
        String title,
        String posterUrl,
        BigDecimal rating,
        LocalDate releaseDate,
        String ageRating,
        Byte status
) {}
