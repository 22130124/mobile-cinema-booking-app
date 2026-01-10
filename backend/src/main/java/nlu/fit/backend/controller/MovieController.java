package nlu.fit.backend.controller;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.movie.MovieResponse;
import nlu.fit.backend.dto.movie_details.MovieDetailDto;
import nlu.fit.backend.dto.movie_details.MovieSummaryDto;
import nlu.fit.backend.dto.movie_details.TrailerDto;
import nlu.fit.backend.service.MovieDetailService;
import nlu.fit.backend.service.MovieService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/movies")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class MovieController {

    private final MovieService movieService;
    private final MovieDetailService movieDetailService; // NEW

    /**
     * Lấy danh sách phim (có thể filter theo status)
     * - GET /api/movies → Tất cả phim
     * - GET /api/movies?status=nowShowing → Phim đang chiếu
     * - GET /api/movies?status=special → Phim đặc biệt
     * - GET /api/movies?status=comingSoon → Phim sắp chiếu
     */
    @GetMapping
    public ResponseEntity<List<MovieResponse>> getMovies(
            @RequestParam(required = false) String status) {

        List<MovieResponse> movies;

        if (status != null && !status.isEmpty()) {
            movies = movieService.getMoviesByStatus(status);
        } else {
            movies = movieService.getAllMovies();
        }

        return ResponseEntity.ok(movies);
    }

    /**
     * GET /api/movies/popular
     * Lấy danh sách phim phổ biến (rating >= 4.0)
     */
    @GetMapping("/popular")
    public ResponseEntity<List<MovieResponse>> getPopularMovies() {
        return ResponseEntity.ok(movieService.getPopularMovies());
    }

    /**
     * GET /api/movies/coming-soon
     * Lấy danh sách phim sắp chiếu
     */
    @GetMapping("/coming-soon")
    public ResponseEntity<List<MovieResponse>> getComingSoonMovies() {
        return ResponseEntity.ok(movieService.getComingSoonMovies());
    }

    /**
     * GET /api/movies/now-showing
     * Lấy danh sách phim đang chiếu
     */
    @GetMapping("/now-showing")
    public ResponseEntity<List<MovieResponse>> getNowShowingMovies() {
        return ResponseEntity.ok(movieService.getNowShowingMovies());
    }

    /**
     * GET /api/movies/search?q={keyword}
     * Tìm kiếm phim theo tên hoặc thể loại
     */
    @GetMapping("/search")
    public ResponseEntity<List<MovieResponse>> searchMovies(
            @RequestParam(required = false, defaultValue = "") String q) {
        return ResponseEntity.ok(movieService.searchMovies(q));
    }

    /**
     * GET /api/movies/{id}
     * Lấy chi tiết phim theo ID
     */
    // @GetMapping("/{id}")
    // public ResponseEntity<MovieResponse> getMovieById(@PathVariable Long id) {
    //     return ResponseEntity.ok(movieService.getMovieById(id));
    // }

    /**
     * GET /api/movies/{id}
     * Lấy chi tiết phim theo ID (DETAIL VERSION - dùng MovieDetailService)
     */
    @GetMapping("/{id}")
    public MovieDetailDto getMovieDetail(@PathVariable Long id) {
        return movieDetailService.getMovieDetail(id);
    }

    /**
     * GET /api/movies/{id}/trailers
     * Trailer theo phim
     */
    @GetMapping("/{id}/trailers")
    public List<TrailerDto> getTrailers(@PathVariable Long id) {
        return movieDetailService.getTrailers(id);
    }

    /**
     * GET /api/movies/{id}/related?limit=10
     * Phim liên quan (cùng thể loại)
     */
    @GetMapping("/{id}/related")
    public List<MovieSummaryDto> getRelated(
            @PathVariable Long id,
            @RequestParam(defaultValue = "10") int limit
    ) {
        return movieDetailService.getRelatedMovies(id, limit);
    }
}
