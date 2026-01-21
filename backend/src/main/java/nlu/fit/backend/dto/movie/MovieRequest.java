package nlu.fit.backend.dto.movie;

import lombok.Data;
import java.util.List;

@Data
public class MovieRequest {
    private String title;
    private String description;
    private Integer duration;
    private String releaseDate; // yyyy-MM-dd
    private String posterUrl;
    private String backdropUrl;
    private Double rating;
    private String director;
    private String cast;
    private String ageRating;
    private Boolean isSpecial;
    private String status; // NOW_SHOWING, COMING_SOON, ENDED
    private List<Integer> genreIds;
}
