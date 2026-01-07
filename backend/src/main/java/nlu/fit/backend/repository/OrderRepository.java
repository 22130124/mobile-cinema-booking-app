package nlu.fit.backend.repository;

import nlu.fit.backend.model.Order;
import nlu.fit.backend.model.User;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface OrderRepository extends JpaRepository<Order,String>, JpaSpecificationExecutor<Order> {

    List<Order> findALLByUser(User user, Pageable pageable);
}
