package auth.example._FAAuthentication.service;

import org.springframework.http.ResponseEntity;
import auth.example._FAAuthentication.entity.User;

public interface AuthService {
    ResponseEntity<?> signup(User user);

    ResponseEntity<?> login(User user);

    ResponseEntity<?> setupTwoFactor(Long userId);

    ResponseEntity<?> disableTwoFactor(Long userId, String password);

    ResponseEntity<?> verifyTwoFactor(Long userId, int code);
}
