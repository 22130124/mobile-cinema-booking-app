package nlu.fit.backend.repository;

import nlu.fit.backend.model.Showtime;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ShowTimeRepository extends JpaRepository<Showtime,Long> {
    List<Showtime> findByMovieIdOrderByShowDateAscStartTimeAsc(Long movieId);
}
