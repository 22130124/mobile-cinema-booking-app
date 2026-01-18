package nlu.fit.backend.dto.user;

public record UserProfileDto(
        Long id,
        String email,
        String username,
        String fullName
) {
}
