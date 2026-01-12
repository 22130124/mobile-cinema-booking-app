package nlu.fit.backend.dto.admin.trailer;

public record TrailerUpdateRequest(
        String youtubeVideoId,
        String title
) {}
