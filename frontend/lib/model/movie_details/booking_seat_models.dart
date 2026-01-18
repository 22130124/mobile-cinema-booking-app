class ShowtimeOption {
  final int id;
  final DateTime showDate;
  final DateTime startTime;
  final String roomName;
  final int? cinemaId;
  final String cinemaName;
  final String cinemaAddress;
  final String cinemaCity;
  final String cinemaImageUrl;

  const ShowtimeOption({
    required this.id,
    required this.showDate,
    required this.startTime,
    required this.roomName,
    required this.cinemaName,
    required this.cinemaId,
    required this.cinemaAddress,
    required this.cinemaCity,
    required this.cinemaImageUrl,
  });

  factory ShowtimeOption.fromJson(Map<String, dynamic> json) {
    return ShowtimeOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      showDate: DateTime.parse(json['showDate'] as String).toLocal(),
      startTime: DateTime.parse(json['startTime'] as String).toLocal(),
      roomName: json['roomName'] as String? ?? '',
      cinemaId: (json['cinemaId'] as num?)?.toInt(),
      cinemaName: json['cinemaName'] as String? ?? '',
      cinemaAddress: json['cinemaAddress'] as String? ?? '',
      cinemaCity: json['cinemaCity'] as String? ?? '',
      cinemaImageUrl: json['cinemaImageUrl'] as String? ?? '',
    );
  }
}

class CinemaGroup {
  final String key;
  final int? cinemaId;
  final String name;
  final String address;
  final String city;
  final String imageUrl;
  final List<ShowtimeOption> showtimes;

  const CinemaGroup({
    required this.key,
    required this.cinemaId,
    required this.name,
    required this.address,
    required this.city,
    required this.imageUrl,
    required this.showtimes,
  });
}
