package nlu.fit.backend.service;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.movie_details.MovieDetailDto;
import nlu.fit.backend.dto.movie_details.MovieSummaryDto;
import nlu.fit.backend.dto.movie_details.TrailerDto;
import nlu.fit.backend.model.Genre;
import nlu.fit.backend.model.Movie;
import nlu.fit.backend.model.Trailer;
import nlu.fit.backend.repository.MovieRepository;
import nlu.fit.backend.repository.TrailerRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MovieDetailService {

    private final MovieRepository movieRepository;
    private final TrailerRepository trailerRepository;

    public MovieDetailDto getMovieDetail(Long movieId) {
        Movie m = movieRepository.findDetailById(movieId)
                .orElseThrow(() -> new RuntimeException("Movie not found: " + movieId));

        List<String> genres = m.getGenres() == null
                ? List.of()
                : m.getGenres().stream().map(Genre::getName).toList();

        return new MovieDetailDto(
                m.getId(),
                m.getTitle(),
                m.getDescription(),
                m.getDuration(),
                m.getReleaseDate(),
                m.getPosterUrl(),
                m.getBackdropUrl(),
                m.getRating(),
                m.getDirector(),
                m.getCast(),
                m.getAgeRating(),
                m.getIsSpecial(),
                m.getStatus(),
                genres,
                m.getCastImageUrls()
        );
    }

    public List<TrailerDto> getTrailers(Long movieId) {
        List<Trailer> trailers = trailerRepository.findByMovie_IdOrderByIdAsc(movieId);

        return trailers.stream()
                .map(t -> new TrailerDto(
                        t.getId(),
                        t.getMovie().getId(),
                        t.getYoutubeVideoId(),
                        t.getTitle()
                ))
                .toList();
    }

    public List<MovieSummaryDto> getRelatedMovies(Long movieId, int limit) {
        var page = PageRequest.of(0, Math.max(1, limit));

        return movieRepository.findRelatedMovies(movieId, page).stream()
                .map(m -> new MovieSummaryDto(
                        m.getId(),
                        m.getTitle(),
                        m.getPosterUrl(),
                        m.getRating(),
                        m.getReleaseDate(),
                        m.getAgeRating(),
                        m.getStatus()
                ))
                .toList();
    }
}
