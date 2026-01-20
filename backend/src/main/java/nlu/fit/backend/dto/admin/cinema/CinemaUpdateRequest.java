package nlu.fit.backend.dto.admin.cinema;

public record CinemaUpdateRequest(
        String name,
        String address,
        String city,
        String imageUrl,
        Boolean isActive
) {}
