package nlu.fit.backend.dto.admin.cinema;

public record CinemaCreateRequest(
        String name,
        String address,
        String city,
        String imageUrl,
        Boolean isActive
) {}
