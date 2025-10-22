package auth.example._FAAuthentication.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SuccessfulLoginDTO {
    private Long id;
    private String username;
    private String email;
    private String message;
    private boolean twoFaEnabled;
}
