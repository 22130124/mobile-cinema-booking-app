class UpdateUserRequest {
  final String fullName;
  final String phone;
  final String gender;
  final String? avatarUrl;
  final String? avatarPublicId;

  UpdateUserRequest({
    required this.fullName,
    required this.phone,
    required this.gender,
    this.avatarUrl,
    this.avatarPublicId
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'gender': gender,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (avatarPublicId != null) 'avatarPublicId': avatarPublicId,
    };
  }
}