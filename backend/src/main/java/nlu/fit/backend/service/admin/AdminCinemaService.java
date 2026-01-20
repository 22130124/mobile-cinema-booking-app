package nlu.fit.backend.service.admin;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.admin.cinema.CinemaAdminResponse;
import nlu.fit.backend.dto.admin.cinema.CinemaCreateRequest;
import nlu.fit.backend.dto.admin.cinema.CinemaUpdateRequest;
import nlu.fit.backend.model.Cinema;
import nlu.fit.backend.repository.CinemaRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminCinemaService {
    private final CinemaRepository cinemaRepository;

    public List<CinemaAdminResponse> list() {
        return cinemaRepository.findAll(Sort.by(Sort.Direction.ASC, "id"))
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public CinemaAdminResponse get(Long id) {
        Cinema cinema = cinemaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cinema not found"));
        return toResponse(cinema);
    }

    public CinemaAdminResponse create(CinemaCreateRequest req) {
        Cinema cinema = new Cinema();
        cinema.setName(req.name());
        cinema.setAddress(req.address());
        cinema.setCity(req.city());
        cinema.setImageUrl(normalizeImageUrl(req.imageUrl()));
        cinema.setIsActive(toActive(req.isActive()));

        Cinema saved = cinemaRepository.save(cinema);
        return toResponse(saved);
    }

    public CinemaAdminResponse update(Long id, CinemaUpdateRequest req) {
        Cinema cinema = cinemaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cinema not found"));

        if (req.name() != null) cinema.setName(req.name());
        if (req.address() != null) cinema.setAddress(req.address());
        if (req.city() != null) cinema.setCity(req.city());
        if (req.imageUrl() != null) cinema.setImageUrl(normalizeImageUrl(req.imageUrl()));
        if (req.isActive() != null) cinema.setIsActive(toActive(req.isActive()));

        Cinema saved = cinemaRepository.save(cinema);
        return toResponse(saved);
    }

    public void deactivate(Long id) {
        Cinema cinema = cinemaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cinema not found"));
        cinema.setIsActive((byte) 0);
        cinemaRepository.save(cinema);
    }

    private CinemaAdminResponse toResponse(Cinema cinema) {
        return new CinemaAdminResponse(
                cinema.getId(),
                cinema.getName(),
                cinema.getAddress(),
                cinema.getCity(),
                cinema.getImageUrl(),
                isActive(cinema)
        );
    }

    private boolean isActive(Cinema cinema) {
        Byte raw = cinema.getIsActive();
        return raw == null || raw != 0;
    }

    private byte toActive(Boolean active) {
        return (byte) ((active == null || active) ? 1 : 0);
    }

    private String normalizeImageUrl(String raw) {
        if (raw == null) return null;
        String trimmed = raw.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
