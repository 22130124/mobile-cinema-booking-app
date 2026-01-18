package nlu.fit.backend.controller.admin;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.admin.trailer.TrailerAdminResponse;
import nlu.fit.backend.dto.admin.trailer.TrailerCreateRequest;
import nlu.fit.backend.dto.admin.trailer.TrailerUpdateRequest;
import nlu.fit.backend.service.admin.AdminTrailerService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/auth/admin/trailers")
@RequiredArgsConstructor
public class AdminTrailerController {

    private final AdminTrailerService adminTrailerService;

    // GET /auth/admin/trailers              -> list all (id asc)
    // GET /auth/admin/trailers?movieId=123  -> list by movieId (id asc)
    @GetMapping
    public List<TrailerAdminResponse> list(@RequestParam(required = false) Long movieId) {
        return adminTrailerService.list(movieId);
    }

    @PostMapping
    public TrailerAdminResponse create(@RequestBody TrailerCreateRequest req) {
        return adminTrailerService.create(req);
    }

    @PutMapping("/{id}")
    public TrailerAdminResponse update(@PathVariable Long id, @RequestBody TrailerUpdateRequest req) {
        return adminTrailerService.update(id, req);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        adminTrailerService.delete(id);
    }
}
