package auth.example._FAAuthentication.controller;

import auth.example._FAAuthentication.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

import auth.example._FAAuthentication.entity.User;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody User user) {
        return authService.signup(user);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody User user) {
        return authService.login(user);
    }

    @PostMapping("/setup-2fa/{userId}")
    public ResponseEntity<?> setupTwoFactor(@PathVariable Long userId) {
        return authService.setupTwoFactor(userId);
    }

    @PostMapping("/disable-2fa/{userId}")
    public ResponseEntity<?> disableTwoFactor(@PathVariable Long userId, @RequestBody Map<String, String> body) {
        String password = body.get("password");
        return authService.disableTwoFactor(userId, password);
    }

    @PostMapping("/verify-2fa/{userId}")
    public ResponseEntity<?> verifyTwoFactor(@PathVariable Long userId, @RequestParam int code) {
        return authService.verifyTwoFactor(userId, code);
    }
}
