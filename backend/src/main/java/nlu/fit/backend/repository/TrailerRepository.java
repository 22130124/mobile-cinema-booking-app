package nlu.fit.backend.repository;

import nlu.fit.backend.model.Trailer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TrailerRepository extends JpaRepository<Trailer, Long> {
    Optional<Trailer> findFirstByMovieId(Long movieId);
}
