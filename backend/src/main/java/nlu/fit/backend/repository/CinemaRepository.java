package nlu.fit.backend.repository;

import nlu.fit.backend.model.Cinema;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CinemaRepository extends JpaRepository<Cinema,Long> {

    @Query("select c from Cinema c where c.isActive is null or c.isActive <> 0")
    List<Cinema> findAllActive();
}
