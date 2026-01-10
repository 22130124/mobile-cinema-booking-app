package nlu.fit.backend.dto.movie_details;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public record MovieDetailDto(
        Long id,
        String title,
        String description,
        Integer duration,
        LocalDate releaseDate,
        String posterUrl,
        String backdropUrl,
        BigDecimal rating,
        String director,
        String cast,
        String ageRating,
        Byte isSpecial,
        Byte status,
        List<String> genres,
        String castImageUrls
) {}
