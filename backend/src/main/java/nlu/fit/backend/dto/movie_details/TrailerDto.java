package nlu.fit.backend.dto.movie_details;

public record TrailerDto(
        Long id,
        Long movieId,
        String youtubeVideoId,
        String title
) {}
