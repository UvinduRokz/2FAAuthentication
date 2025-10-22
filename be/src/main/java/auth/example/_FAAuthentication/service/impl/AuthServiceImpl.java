package auth.example._FAAuthentication.service.impl;

import auth.example._FAAuthentication.dto.ResponseDTO;
import auth.example._FAAuthentication.dto.SuccessfulLoginDTO;
import auth.example._FAAuthentication.dto.TwoFaRequiredDTO;
import auth.example._FAAuthentication.dto.TwoFaSetupDTO;
import auth.example._FAAuthentication.entity.User;
import auth.example._FAAuthentication.repository.UserRepository;
import auth.example._FAAuthentication.service.AuthService;
import com.warrenstrange.googleauth.GoogleAuthenticator;
import com.warrenstrange.googleauth.GoogleAuthenticatorKey;
import com.warrenstrange.googleauth.GoogleAuthenticatorQRGenerator;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Optional;
import java.io.ByteArrayOutputStream;


@Service
public class AuthServiceImpl implements AuthService {

    @Autowired
    private UserRepository userRepository;

    private final GoogleAuthenticator gAuth = new GoogleAuthenticator();

    @Override
    public ResponseEntity<?> signup(User user) {
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(new ResponseDTO("Email already registered!"));
        }

        userRepository.save(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(new ResponseDTO("User registered successfully!"));
    }

    @Override
    public ResponseEntity<?> login(User request) {
        Optional<User> userOpt = userRepository.findByEmail(request.getEmail());
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(new ResponseDTO("Invalid credentials"));
        }

        User user = userOpt.get();
        if (!user.getPassword().equals(request.getPassword())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(new ResponseDTO("Invalid credentials"));
        }

        if (user.isTwoFaEnabled()) {
            return ResponseEntity.ok(new TwoFaRequiredDTO("2FA required. Please verify your OTP.", user.getId()));
        }

        SuccessfulLoginDTO dto = new SuccessfulLoginDTO(user.getId(), user.getUsername(), user.getEmail(), "Login Successful", user.isTwoFaEnabled());
        return ResponseEntity.ok(dto);
    }

    @Override
    public ResponseEntity<?> setupTwoFactor(Long userId) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ResponseDTO("User not found"));
        }

        User user = userOpt.get();

        GoogleAuthenticator gAuth = new GoogleAuthenticator();
        GoogleAuthenticatorKey key = gAuth.createCredentials();

        user.setTwoFaSecret(key.getKey());
        user.setTwoFaEnabled(false);
        userRepository.save(user);

        // 1) Raw otpauth URI (canonical) -- use this when possible
        String otpAuthUrl = GoogleAuthenticatorQRGenerator.getOtpAuthTotpURL("2FA testing app", user.getEmail(), key);

//        // 2) External QR image URL (encode otpAuthUrl exactly once)
//        String qrCodeUrl = "https://api.qrserver.com/v1/create-qr-code/?data=" + URLEncoder.encode(otpAuthUrl, StandardCharsets.UTF_8) + "&size=400x400&ecc=M&margin=0";
//
//        // 3) Optional - generate PNG bytes server-side using ZXing and return base64
//        String qrImageBase64 = null;
//        try {
//            BitMatrix matrix = new MultiFormatWriter().encode(otpAuthUrl, BarcodeFormat.QR_CODE, 400, 400);
//            ByteArrayOutputStream baos = new ByteArrayOutputStream();
//            MatrixToImageWriter.writeToStream(matrix, "PNG", baos);
//            byte[] png = baos.toByteArray();
//            qrImageBase64 = Base64.getEncoder().encodeToString(png); // client can use data:image/png;base64,...
//        } catch (Exception ex) {
//            ex.printStackTrace();
//        }
//
//        // Build DTO (include otpAuthUrl, qrCodeUrl, qrImageBase64, secret)
//        TwoFaSetupDTO dto = new TwoFaSetupDTO("Scan this QR code or enter the secret manually", user.getId(), otpAuthUrl, qrCodeUrl, qrImageBase64, key.getKey());

        TwoFaSetupDTO dto = new TwoFaSetupDTO("Scan this QR code or enter the secret manually", user.getId(), otpAuthUrl, null, null, key.getKey());

        return ResponseEntity.ok(dto);
    }

    @Override
    public ResponseEntity<?> disableTwoFactor(Long userId, String password) {
        Optional<User> uOpt = userRepository.findById(userId);
        if (uOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ResponseDTO("User not found"));
        }

        User user = uOpt.get();
        if (!user.getPassword().equals(password)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(new ResponseDTO("Invalid password"));
        }

        user.setTwoFaEnabled(false);
        user.setTwoFaSecret(null);
        userRepository.save(user);
        return ResponseEntity.ok(new ResponseDTO("2FA disabled"));
    }

    @Override
    public ResponseEntity<?> verifyTwoFactor(Long userId, int code) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ResponseDTO("User not found"));
        }

        User user = userOpt.get();
        if (user.getTwoFaSecret() == null) {
            return ResponseEntity.badRequest().body(new ResponseDTO("2FA not set up for this user"));
        }

        boolean isValid = gAuth.authorize(user.getTwoFaSecret(), code);
        if (isValid) {
            user.setTwoFaEnabled(true);
            userRepository.save(user);

            SuccessfulLoginDTO dto = new SuccessfulLoginDTO(user.getId(), user.getUsername(), user.getEmail(), "Login Successful (2FA verified)", user.isTwoFaEnabled());
            return ResponseEntity.ok(dto);
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(new ResponseDTO("Invalid 2FA code"));
        }
    }
}
