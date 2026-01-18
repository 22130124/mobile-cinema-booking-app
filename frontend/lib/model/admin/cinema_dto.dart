class CinemaDto {
  final int id;
  final String name;

  CinemaDto({required this.id, required this.name});

  factory CinemaDto.fromJson(Map<String, dynamic> json) => CinemaDto(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
      );
}
