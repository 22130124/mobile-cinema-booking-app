package nlu.fit.backend.controller;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.movie.MovieRequest;
import nlu.fit.backend.dto.movie.MovieResponse;
import nlu.fit.backend.service.AdminMovieService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/movies")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AdminMovieController {

    private final AdminMovieService adminMovieService;
    // POST /api/admin/movies: Tạo phim mới
    @PostMapping
    public ResponseEntity<MovieResponse> createMovie(@RequestBody MovieRequest request) {
        MovieResponse movie = adminMovieService.createMovie(request);
        return ResponseEntity.ok(movie);
    }

    // PUT /api/admin/movies/{id}: Cập nhật phim
    @PutMapping("/{id}")
    public ResponseEntity<MovieResponse> updateMovie(
            @PathVariable Long id,
            @RequestBody MovieRequest request) {
        MovieResponse movie = adminMovieService.updateMovie(id, request);
        return ResponseEntity.ok(movie);
    }

    // DELETE /api/admin/movies/{id}: Xóa phim
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMovie(@PathVariable Long id) {
        adminMovieService.deleteMovie(id);
        return ResponseEntity.noContent().build();
    }
}
