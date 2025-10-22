package auth.example._FAAuthentication.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TwoFaSetupDTO {
    private String message;
    private Long userId;
    private String otpAuthUrl;
    private String qrCodeUrl;
    private String qrImageBase64;
    private String secret;
}
