package nlu.fit.backend.dto.admin.trailer;

public record TrailerCreateRequest(
        Long movieId,
        String youtubeVideoId,
        String title
) {}
