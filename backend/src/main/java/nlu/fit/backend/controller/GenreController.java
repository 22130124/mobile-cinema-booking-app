package nlu.fit.backend.controller;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.genre.GenreResponse;
import nlu.fit.backend.model.Genre;
import nlu.fit.backend.repository.GenreRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class GenreController {

    private final GenreRepository genreRepository;
    // GET /api/genres: Lấy danh sách tất cả thể loại
    @GetMapping("/genres")
    public ResponseEntity<List<GenreResponse>> getAllGenres() {
        List<GenreResponse> genres = genreRepository.findAll().stream()
                .map(GenreResponse::fromEntity)
                .collect(Collectors.toList());
        return ResponseEntity.ok(genres);
    }

    // POST /api/admin/genres: Tạo thể loại mới (Admin only)
    @PostMapping("/admin/genres")
    public ResponseEntity<GenreResponse> createGenre(@RequestBody Map<String, String> request) {
        String name = request.get("name");
        if (name == null || name.trim().isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        Genre genre = new Genre();
        genre.setName(name.trim());
        genre = genreRepository.save(genre);

        return ResponseEntity.ok(GenreResponse.fromEntity(genre));
    }
}
