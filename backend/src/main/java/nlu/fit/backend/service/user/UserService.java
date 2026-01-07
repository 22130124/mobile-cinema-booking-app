package nlu.fit.backend.service.user;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.model.user.User;
import nlu.fit.backend.repository.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import static nlu.fit.backend.model.user.User.UserStatus.*;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

    @Transactional
    public User createAndReturnEmptyUser() {
        User user = new User();
        user.setStatus(INCOMPLETED);
        userRepository.save(user);
        return user;
    }

    @Transactional
    public boolean getUserStatus(User user) {
        String status = String.valueOf(user.getStatus());
        return status.equals("COMPLETED");
    }
}
