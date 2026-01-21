package nlu.fit.backend.controller;

import lombok.RequiredArgsConstructor;
import nlu.fit.backend.dto.admin.CinemaDto;
import nlu.fit.backend.model.Cinema;
import nlu.fit.backend.repository.CinemaRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/cinemas")
@RequiredArgsConstructor
public class CinemaController {

    private final CinemaRepository cinemaRepository;

    @GetMapping
    public List<CinemaDto> list() {
        return cinemaRepository.findAllActive()
                .stream()
                .map(c -> new CinemaDto(c.getId(), c.getName()))
                .toList();
    }
}
