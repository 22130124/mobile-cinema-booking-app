package nlu.fit.backend.dto.movie;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import nlu.fit.backend.model.Genre;
import nlu.fit.backend.model.Movie;

import java.util.List;
import java.util.stream.Collectors;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MovieResponse {
    private Long id;
    private String title;
    private String posterUrl;
    private String backdropUrl;
    private String genre;//dạng chuỗi
    private List<String> genres;//ds tên genres
    private List<Integer> genreIds;//để edit
    private Double rating;
    private Integer duration;
    private String releaseDate;
    private String description;
    private String status; // "nowShowing", "special", "comingSoon", "ended"
    private Boolean isSpecial;
    
    // Thông tin bổ sung (cho trang chi tiết)
    private String director;
    private String cast;
    private String ageRating;
    private String trailerUrl;
    
    /**
     * Convert từ Movie Entity sang MovieResponse DTO
     */
    public static MovieResponse fromEntity(Movie movie) {
        return MovieResponse.builder()
                .id(movie.getId())
                .title(movie.getTitle())
                .posterUrl(movie.getPosterUrl())
                .backdropUrl(movie.getBackdropUrl())
                .genre(getGenreString(movie))
                .genres(getGenreNames(movie))
                .genreIds(getGenreIdsList(movie))
                .rating(movie.getRating() != null ? movie.getRating().doubleValue() : 0.0)
                .duration(movie.getDuration())
                .releaseDate(movie.getReleaseDate() != null ? movie.getReleaseDate().toString() : "")
                .description(movie.getDescription())
                .status(mapStatus(movie))
                .isSpecial(movie.getIsSpecial() != null && movie.getIsSpecial() == 1)
                .director(movie.getDirector())
                .cast(movie.getCast())
                .ageRating(movie.getAgeRating())
                .build();
    }

    public static MovieResponse fromEntity(Movie movie, String trailerUrl) {
        MovieResponse response = fromEntity(movie);
        response.setTrailerUrl(trailerUrl);
        return response;
    }
    
    // Lấy ds tên genres
    private static List<String> getGenreNames(Movie movie) {
        if (movie.getGenres() == null || movie.getGenres().isEmpty()) {
            return List.of();
        }
        return movie.getGenres().stream()
                .map(Genre::getName)
                .collect(Collectors.toList());
    }
    
    // Lấy ds ID genres (để edit)
    private static List<Integer> getGenreIdsList(Movie movie) {
        if (movie.getGenres() == null || movie.getGenres().isEmpty()) {
            return List.of();
        }
        return movie.getGenres().stream()
                .map(Genre::getId)
                .collect(Collectors.toList());
    }
    
    // Chuyển ds thể loại thành chuỗi phân cách bởi dấu phẩy (legacy)
    private static String getGenreString(Movie movie) {
        if (movie.getGenres() == null || movie.getGenres().isEmpty()) {
            return "";
        }
        return movie.getGenres().stream()
                .map(Genre::getName)
                .collect(Collectors.joining(", "));
    }
    
    /**
     * Map status từ database sang enum string cho Frontend
     * Database: status (1,2,3) + is_special (0,1)
     * Frontend: "nowShowing", "special", "comingSoon", "ended"
     */
    private static String mapStatus(Movie movie) {
        Byte status = movie.getStatus();
        Byte isSpecial = movie.getIsSpecial();
        
        if (status == null) return "nowShowing";
        
        switch (status) {
            case 1: // Đang chiếu
                if (isSpecial != null && isSpecial == 1) {
                    return "special";
                }
                return "nowShowing";
            case 2: // Sắp chiếu
                return "comingSoon";
            case 3: // Ngừng chiếu
                return "ended";
            default:
                return "nowShowing";
        }
    }
}


