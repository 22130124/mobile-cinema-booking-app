package nlu.fit.backend.repository;

import nlu.fit.backend.model.Movie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MovieRepository extends JpaRepository<Movie, Long> {

    //Lấy phim đang chiếu (status = 1, is_special = 0)
    @Query("SELECT m FROM Movie m WHERE m.status = 1 AND m.isSpecial = 0")
    List<Movie> findNowShowingMovies();

    //Lấy phim đặc biệt (status = 1, is_special = 1)
    @Query("SELECT m FROM Movie m WHERE m.status = 1 AND m.isSpecial = 1")
    List<Movie> findSpecialMovies();

    //Lấy phim sắp chiếu (status = 2)
    @Query("SELECT m FROM Movie m WHERE m.status = 2")
    List<Movie> findComingSoonMovies();

    //Lấy phim phổ biến (rating >= 4.0, đang chiếu hoặc đặc biệt)
    @Query("SELECT m FROM Movie m WHERE m.rating >= 4.0 AND m.status = 1 ORDER BY m.rating DESC")
    List<Movie> findPopularMovies();

    //Tìm kiếm phim theo tên hoặc thể loại
    @Query("SELECT DISTINCT m FROM Movie m LEFT JOIN m.genres g " +
           "WHERE LOWER(m.title) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(g.name) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Movie> searchMovies(@Param("keyword") String keyword);
}


