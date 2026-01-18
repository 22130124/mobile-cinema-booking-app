package nlu.fit.backend.dto.admin.trailer;

public record TrailerAdminResponse(
        Long id,
        Long movieId,
        String youtubeVideoId,
        String title
) {}
