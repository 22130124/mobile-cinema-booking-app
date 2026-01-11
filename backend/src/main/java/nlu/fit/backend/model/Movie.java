package nlu.fit.backend.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.ColumnDefault;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "movies")
public class Movie {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Long id;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description")
    private String description;

    @Column(name = "duration", nullable = false)
    private Integer duration;

    @Column(name = "release_date")
    private LocalDate releaseDate;

    @Column(name = "poster_url")
    private String posterUrl;

    @Column(name = "backdrop_url")
    private String backdropUrl;

    @ColumnDefault("0.0")
    @Column(name = "rating", precision = 3, scale = 1)
    private BigDecimal rating;

    @Column(name = "director")
    private String director;

    @Column(name = "cast", columnDefinition = "TEXT")
    private String cast;

    @ColumnDefault("'P'")
    @Column(name = "age_rating", length = 10)
    private String ageRating;

    @ColumnDefault("0")
    @Column(name = "is_special")
    private Byte isSpecial;

    @ColumnDefault("1")
    @Column(name = "status")
    private Byte status;

    @ColumnDefault("CURRENT_TIMESTAMP")
    @Column(name = "created_at")
    private Instant createdAt;

    @ColumnDefault("CURRENT_TIMESTAMP")
    @Column(name = "updated_at")
    private Instant updatedAt;
    
    @ManyToMany
    @JoinTable(name = "movie_genres",
            joinColumns = @JoinColumn(name = "movie_id"),
            inverseJoinColumns = @JoinColumn(name = "genre_id"))
    private List<Genre> genres;

    @Column(name = "cast_image_urls", columnDefinition = "TEXT")
    private String castImageUrls;


}