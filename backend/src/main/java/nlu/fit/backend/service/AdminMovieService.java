package nlu.fit.backend.service;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.movie.MovieRequest;
import nlu.fit.backend.dto.movie.MovieResponse;
import nlu.fit.backend.model.Genre;
import nlu.fit.backend.model.Movie;
import nlu.fit.backend.repository.GenreRepository;
import nlu.fit.backend.repository.MovieRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminMovieService {

    private final MovieRepository movieRepository;
    private final GenreRepository genreRepository;

    // Tạo phim mới
    @Transactional
    public MovieResponse createMovie(MovieRequest request) {
        Movie movie = new Movie();
        updateMovieFromRequest(movie, request);
        movie.setCreatedAt(Instant.now());
        movie.setUpdatedAt(Instant.now());

        movie = movieRepository.save(movie);
        return MovieResponse.fromEntity(movie);
    }

    // Cập nhật phim
    @Transactional
    public MovieResponse updateMovie(Long id, MovieRequest request) {
        Movie movie = movieRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Không tìm thấy phim với ID: " + id));

        updateMovieFromRequest(movie, request);
        movie.setUpdatedAt(Instant.now());

        movie = movieRepository.save(movie);
        return MovieResponse.fromEntity(movie);
    }

    // Xóa phim
    @Transactional
    public void deleteMovie(Long id) {
        if (!movieRepository.existsById(id)) {
            throw new ResponseStatusException(
                    HttpStatus.NOT_FOUND, "Không tìm thấy phim với ID: " + id);
        }
        movieRepository.deleteById(id);
    }

    // Cập nhật entity Movie từ request
    private void updateMovieFromRequest(Movie movie, MovieRequest request) {
        if (request.getTitle() != null) {
            movie.setTitle(request.getTitle());
        }
        if (request.getDescription() != null) {
            movie.setDescription(request.getDescription());
        }
        if (request.getDuration() != null) {
            movie.setDuration(request.getDuration());
        }
        if (request.getReleaseDate() != null && !request.getReleaseDate().isEmpty()) {
            movie.setReleaseDate(LocalDate.parse(request.getReleaseDate(), 
                    DateTimeFormatter.ISO_LOCAL_DATE));
        }
        if (request.getPosterUrl() != null) {
            movie.setPosterUrl(request.getPosterUrl());
        }
        if (request.getBackdropUrl() != null) {
            movie.setBackdropUrl(request.getBackdropUrl());
        }
        if (request.getRating() != null) {
            movie.setRating(BigDecimal.valueOf(request.getRating()));
        }
        if (request.getDirector() != null) {
            movie.setDirector(request.getDirector());
        }
        if (request.getCast() != null) {
            movie.setCast(request.getCast());
        }
        if (request.getAgeRating() != null) {
            movie.setAgeRating(request.getAgeRating());
        }
        if (request.getIsSpecial() != null) {
            movie.setIsSpecial(request.getIsSpecial() ? (byte) 1 : (byte) 0);
        }
        if (request.getStatus() != null) {
            movie.setStatus(parseStatus(request.getStatus()));
        }

        // Update genres
        if (request.getGenreIds() != null && !request.getGenreIds().isEmpty()) {
            List<Genre> genres = genreRepository.findAllById(request.getGenreIds());
            movie.setGenres(genres);
        }
    }

    // NOW_SHOWING = 1, COMING_SOON = 2, ENDED = 3
    private byte parseStatus(String status) {
        if (status == null) return 1;
        
        switch (status.toUpperCase()) {
            case "NOW_SHOWING":
            case "NOWSHOWING":
                return 1;
            case "COMING_SOON":
            case "COMINGSOON":
                return 2;
            case "ENDED":
                return 3;
            default:
                return 1;
        }
    }
}
