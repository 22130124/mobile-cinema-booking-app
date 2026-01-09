package nlu.fit.backend.controller;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.movie_details.MovieDetailDto;
import nlu.fit.backend.dto.movie_details.MovieSummaryDto;
import nlu.fit.backend.dto.movie_details.TrailerDto;
import nlu.fit.backend.service.MovieDetailService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/movies")
@RequiredArgsConstructor
public class MovieDetailController {

    private final MovieDetailService movieService;

    // API 1: Chi tiết phim
    @GetMapping("/{movieId}")
    public MovieDetailDto detail(@PathVariable Long movieId) {
        return movieService.getMovieDetail(movieId);
    }

    // API 2: Trailer theo phim
    @GetMapping("/{movieId}/trailers")
    public List<TrailerDto> trailers(@PathVariable Long movieId) {
        return movieService.getTrailers(movieId);
    }

    // API 3: Phim liên quan (cùng thể loại)
    @GetMapping("/{movieId}/related")
    public List<MovieSummaryDto> related(
            @PathVariable Long movieId,
            @RequestParam(defaultValue = "10") int limit
    ) {
        return movieService.getRelatedMovies(movieId, limit);
    }
}
