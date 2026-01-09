package nlu.fit.backend.service;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.movie.MovieResponse;
import nlu.fit.backend.model.Movie;
import nlu.fit.backend.repository.MovieRepository;
import nlu.fit.backend.repository.TrailerRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MovieService {
    
    private final MovieRepository movieRepository;
    private final TrailerRepository trailerRepository;

    //Lấy tất cả phim
    public List<MovieResponse> getAllMovies() {
        return movieRepository.findAll().stream()
                .map(MovieResponse::fromEntity)
                .collect(Collectors.toList());
    }

    //Lấy phim theo status: "nowShowing", "special", "comingSoon"
    public List<MovieResponse> getMoviesByStatus(String status) {
        List<Movie> movies;
        
        switch (status.toLowerCase()) {
            case "nowshowing":
                movies = movieRepository.findNowShowingMovies();
                break;
            case "special":
                movies = movieRepository.findSpecialMovies();
                break;
            case "comingsoon":
                movies = movieRepository.findComingSoonMovies();
                break;
            default:
                movies = movieRepository.findAll();
        }
        
        return movies.stream()
                .map(MovieResponse::fromEntity)
                .collect(Collectors.toList());
    }

    //Lấy phim phổ biến (rating >= 4.0)
    public List<MovieResponse> getPopularMovies() {
        return movieRepository.findPopularMovies().stream()
                .map(MovieResponse::fromEntity)
                .collect(Collectors.toList());
    }

    //Lấy phim sắp chiếu
    public List<MovieResponse> getComingSoonMovies() {
        return movieRepository.findComingSoonMovies().stream()
                .map(MovieResponse::fromEntity)
                .collect(Collectors.toList());
    }

    //Lấy phim đang chiếu (không bao gồm special)
    public List<MovieResponse> getNowShowingMovies() {
        return movieRepository.findNowShowingMovies().stream()
                .map(MovieResponse::fromEntity)
                .collect(Collectors.toList());
    }

    //Tìm kiếm phim theo từ khóa (tên phim/thể loại)
    public List<MovieResponse> searchMovies(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllMovies();
        }
        
        return movieRepository.searchMovies(keyword.trim()).stream()
                .map(MovieResponse::fromEntity)
                .collect(Collectors.toList());
    }

    //Lấy chi tiết phim theo ID
    public MovieResponse getMovieById(Long id) {
        Movie movie = movieRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy phim với ID: " + id));
        String trailerUrl = trailerRepository.findFirstByMovieId(movie.getId())
                .map(trailer -> trailer.getYoutubeVideoId())
                .map(String::trim)
                .filter(value -> !value.isEmpty())
                .map(value -> value.startsWith("http")
                        ? value
                        : "https://www.youtube.com/watch?v=" + value)
                .orElse(null);
        return MovieResponse.fromEntity(movie, trailerUrl);
    }
}


