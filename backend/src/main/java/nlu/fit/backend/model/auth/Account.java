package nlu.fit.backend.model.auth;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import nlu.fit.backend.model.user.User;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

@Entity
@Table(name = "accounts")
@Getter
@Setter
public class Account {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @OneToOne(cascade = CascadeType.ALL)
    @OnDelete(action = OnDeleteAction.CASCADE)
    @JoinColumn(name = "user_id", referencedColumnName = "id")
    private User user;

    private String email;

    private String password;

    @Enumerated(EnumType.STRING)
    private AccountRole role;

    @Enumerated(EnumType.STRING)
    private AccountStatus status;

    public enum AccountRole {USER, ADMIN}
    public enum AccountStatus {UNVERIFIED, ACTIVE, INACTIVE}
}
