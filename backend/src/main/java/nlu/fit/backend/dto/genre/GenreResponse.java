package nlu.fit.backend.dto.genre;

import lombok.AllArgsConstructor;
import lombok.Data;
import nlu.fit.backend.model.Genre;

@Data
@AllArgsConstructor
public class GenreResponse {
    private Integer id;
    private String name;

    public static GenreResponse fromEntity(Genre genre) {
        return new GenreResponse(genre.getId(), genre.getName());
    }
}
