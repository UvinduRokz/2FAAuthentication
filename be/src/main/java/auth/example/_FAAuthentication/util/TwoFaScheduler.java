package auth.example._FAAuthentication.util;

import jakarta.annotation.PostConstruct;
import auth.example._FAAuthentication.entity.User;
import auth.example._FAAuthentication.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;

@Component
public class TwoFaScheduler {

    @Autowired
    private UserRepository userRepository;

    @PostConstruct
    public void init() {
        System.out.println("[TwoFaScheduler] bean created at " + LocalDateTime.now());
    }

    // Cron Expression Reference:
    //
    // Testing:
    // "*/1 * * * * *"  -> every 1 second
    // "*/10 * * * * *" -> every 10 seconds
    // "0 * * * * *"    -> every 1 minute (at second 0)
    //
    // Short Intervals:
    // "0 */5 * * * *"   -> every 5 minutes
    // "0 */30 * * * *"  -> every 30 minutes
    // "0 0 */2 * * *"   -> every 2 hours
    //
    // Daily:
    // "0 0 0 * * *"     -> every day at midnight
    // "0 0 6 * * *"     -> every day at 6 AM
    // "0 30 23 * * *"   -> every day at 11:30 PM
    //
    // Weekly:
    // "0 0 0 * * MON"   -> every Monday at midnight
    // "0 0 9 * * FRI"   -> every Friday at 9 AM
    //
    // Monthly:
    // "0 0 0 1 * *"     -> first day of every month at midnight
    // "0 0 12 15 * *"   -> every 15th day of the month at noon
    //
    // Custom:
    // "0 0 9-17 * * MON-FRI" -> every hour between 9 AM–5 PM, Monday–Friday
    // "0 0/15 8-18 * * *"    -> every 15 minutes between 8 AM–6 PM daily
    @Scheduled(cron = "*/10 * * * * ?")
    public void checkExpired2FA() {
        System.out.println("[TwoFaScheduler] Running 2FA expiration check at " + LocalDateTime.now());
        LocalDateTime now = LocalDateTime.now();
        List<User> users = userRepository.findAll();

        boolean changed = false;
        for (User user : users) {
            if (user.isTwoFaEnabled() && user.getTwoFaLastVerified() != null) {
                LocalDateTime lastVerified = user.getTwoFaLastVerified();
                LocalDateTime expiryDate = lastVerified.plusMinutes(2); // 2 minutes expiry for testing
                long minutesSince = java.time.temporal.ChronoUnit.MINUTES.between(lastVerified, now);
                long secondsSince = java.time.temporal.ChronoUnit.SECONDS.between(lastVerified, now);

                System.out.printf("[TwoFaScheduler] user=%s lastVerified=%s now=%s secondsSince=%d expiryAt=%s%n",
                        user.getEmail(), lastVerified, now, secondsSince, expiryDate);

                if (now.isAfter(expiryDate) && !user.isTwoFaExpired()) {
                    user.setTwoFaExpired(true);
                    System.out.println("[TwoFaScheduler] -> Marking twoFaExpired=true for: " + user.getEmail());
                    changed = true;
                }
            }
        }

        if (changed) {
            userRepository.saveAll(users);
            System.out.println("[TwoFaScheduler] Saved updated users at " + LocalDateTime.now());
        } else {
            System.out.println("[TwoFaScheduler] No updates needed");
        }
    }
}
