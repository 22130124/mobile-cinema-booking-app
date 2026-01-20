class UserResponse {
  final int id;
  final String fullName;
  final String phone;
  final String gender;
  final String? avatarUrl;
  final String? avatarPublicId;

  UserResponse({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.gender,
    this.avatarUrl,
    this.avatarPublicId,
  });

  factory UserResponse.fromJson(dynamic json) {
    return UserResponse(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      avatarPublicId: json['avatarPublicId'] ?? '',
    );
  }
}
