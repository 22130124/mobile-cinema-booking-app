package nlu.fit.backend.repository;

import nlu.fit.backend.model.Trailer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TrailerRepository extends JpaRepository<Trailer, Long> {

    // Logic: Trailer có property movie, nên query theo nested property movie.id
    // Spring Data hỗ trợ nested property trong derived query.
    List<Trailer> findByMovie_IdOrderByIdAsc(Long movieId);
}
