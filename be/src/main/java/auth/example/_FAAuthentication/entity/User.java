package auth.example._FAAuthentication.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String username;
    private String email;
    private String password;

    @Column(name = "two_fa_enabled")
    private boolean twoFaEnabled = false;

    @Column(name = "two_fa_secret")
    private String twoFaSecret;
}
