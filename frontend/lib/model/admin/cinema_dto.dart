class CinemaDto {
  final int id;
  final String name;
  final String address;
  final String city;
  final String imageUrl;
  final bool isActive;

  CinemaDto({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.imageUrl,
    required this.isActive,
  });

  factory CinemaDto.fromJson(Map<String, dynamic> json) {
    final rawActive = json['isActive'];
    final isActive = rawActive == null
        ? true
        : (rawActive is bool ? rawActive : (rawActive as num) != 0);

    return CinemaDto(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      city: (json['city'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? '') as String,
      isActive: isActive,
    );
  }
}
