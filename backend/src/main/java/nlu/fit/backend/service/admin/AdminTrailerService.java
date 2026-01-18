package nlu.fit.backend.service.admin;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.admin.trailer.TrailerAdminResponse;
import nlu.fit.backend.dto.admin.trailer.TrailerCreateRequest;
import nlu.fit.backend.dto.admin.trailer.TrailerUpdateRequest;
import nlu.fit.backend.model.Movie;
import nlu.fit.backend.model.Trailer;
import nlu.fit.backend.repository.MovieRepository;
import nlu.fit.backend.repository.TrailerRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminTrailerService {

    private final TrailerRepository trailerRepository;
    private final MovieRepository movieRepository;

    // GET list (all hoặc theo movieId)
    public List<TrailerAdminResponse> list(Long movieId) {
        List<Trailer> trailers;
        if (movieId == null) {
            trailers = trailerRepository.findAll(Sort.by(Sort.Direction.ASC, "id"));
        } else {
            trailers = trailerRepository.findByMovie_IdOrderByIdAsc(movieId);
        }

        return trailers.stream().map(this::toResponse).toList();
    }

    public TrailerAdminResponse create(TrailerCreateRequest req) {
        Movie movie = movieRepository.findById(req.movieId())
                .orElseThrow(() -> new RuntimeException("Movie not found"));

        Trailer t = new Trailer();
        t.setMovie(movie);
        t.setYoutubeVideoId(req.youtubeVideoId());
        t.setTitle(req.title());

        Trailer saved = trailerRepository.save(t);
        return toResponse(saved);
    }

    public TrailerAdminResponse update(Long id, TrailerUpdateRequest req) {
        Trailer t = trailerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Trailer not found"));

        t.setYoutubeVideoId(req.youtubeVideoId());
        t.setTitle(req.title());

        Trailer saved = trailerRepository.save(t);
        return toResponse(saved);
    }

    public void delete(Long id) {
        if (!trailerRepository.existsById(id)) {
            throw new RuntimeException("Trailer not found");
        }
        trailerRepository.deleteById(id);
    }

    private TrailerAdminResponse toResponse(Trailer t) {
        Long movieId = (t.getMovie() != null) ? t.getMovie().getId() : null;
        return new TrailerAdminResponse(
                t.getId(),
                movieId,
                t.getYoutubeVideoId(),
                t.getTitle()
        );
    }
}
