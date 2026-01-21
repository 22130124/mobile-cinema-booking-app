package nlu.fit.backend.controller.admin;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.admin.cinema.CinemaAdminResponse;
import nlu.fit.backend.dto.admin.cinema.CinemaCreateRequest;
import nlu.fit.backend.dto.admin.cinema.CinemaUpdateRequest;
import nlu.fit.backend.service.admin.AdminCinemaService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/auth/admin/cinemas")
@RequiredArgsConstructor
public class AdminCinemaController {

    private final AdminCinemaService adminCinemaService;

    @GetMapping
    public List<CinemaAdminResponse> list() {
        return adminCinemaService.list();
    }

    @GetMapping("/{id}")
    public CinemaAdminResponse get(@PathVariable Long id) {
        return adminCinemaService.get(id);
    }

    @PostMapping
    public CinemaAdminResponse create(@RequestBody CinemaCreateRequest req) {
        return adminCinemaService.create(req);
    }

    @PutMapping("/{id}")
    public CinemaAdminResponse update(@PathVariable Long id, @RequestBody CinemaUpdateRequest req) {
        return adminCinemaService.update(id, req);
    }

    @DeleteMapping("/{id}")
    public void deactivate(@PathVariable Long id) {
        adminCinemaService.deactivate(id);
    }
}
