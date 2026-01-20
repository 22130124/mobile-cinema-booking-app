package nlu.fit.backend.dto.admin.cinema;

public record CinemaAdminResponse(
        Long id,
        String name,
        String address,
        String city,
        String imageUrl,
        boolean isActive
) {}
