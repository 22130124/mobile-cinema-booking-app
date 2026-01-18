import 'movie_details.dart';

final dummyMovie = MovieDetailsModel(
  movieId: "1",
  title: "Nàng Bạch Tuyết",
  duration: 109,
  rating: 1.6,
  ageRating: "P",
  releaseDate: "2025-03-21",
  description:
      "Câu chuyện của Nàng Bạch Tuyết ban đầu cống hiến như cổ tích, khi Nàng còn chị mà cha đoái, mang niềm vui và sự ấm áp tới cung điện vương quốc xinh đẹp. Mẹ mất sớm, cha bốc nàng băng tát cả tình yêu...",
  genres: ["Kỳ ảo", "Phiêu lưu", "Âm nhạc"],
  media: [
    MediaModel()
      ..mediaType = "Image"
      ..mediaURL = "https://i0.wp.com/katieatthemovies.com/wp-content/uploads/2025/03/snow-white.jpg?fit=1200%2C675&ssl=1",  // Poster thực
    MediaModel()
      ..mediaType = "Video"
      ..mediaURL = "https://www.youtube.com/watch?v=iV46TJKL8cU",  // Trailer chính thức
  ],
  actors: [
    ActorModel()
      ..name = "Rachel Zegler"
      ..role = "Nàng Bạch Tuyết"
      ..imageURL = "https://variety.com/wp-content/uploads/2025/03/MCDSNWH_WD031.jpg?crop=519px%2C0px%2C1851px%2C1234px&resize=1000%2C667",  // Ảnh thực
    ActorModel()
      ..name = "Gal Gadot"
      ..role = "Hoàng hậu Ác"
      ..imageURL = "https://i.ytimg.com/vi/mEOr-zbALYA/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLBwNTfya_Akgh5-ZTh_nsD5Kl-6yQ",  // Ảnh thực
  ],
);