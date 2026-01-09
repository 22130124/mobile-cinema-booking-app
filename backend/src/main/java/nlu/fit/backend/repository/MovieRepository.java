package nlu.fit.backend.repository;

import nlu.fit.backend.model.Movie;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface MovieRepository extends JpaRepository<Movie, Long> {

    // Logic: Lấy movie + genres (ManyToMany) cho API chi tiết.
    // DISTINCT để tránh movie bị duplicate khi fetch join collection.
    @Query("""
        select distinct m
        from Movie m
        left join fetch m.genres
        where m.id = :id
    """)
    Optional<Movie> findDetailById(@Param("id") Long id);

    // Logic: Phim liên quan = phim có chung ít nhất 1 thể loại với phim hiện tại.
    @Query("""
        select distinct m2
        from Movie m2
        join m2.genres g2
        where g2.id in (
            select g.id
            from Movie m
            join m.genres g
            where m.id = :movieId
        )
        and m2.id <> :movieId
    """)
    List<Movie> findRelatedMovies(@Param("movieId") Long movieId, Pageable pageable);
}
