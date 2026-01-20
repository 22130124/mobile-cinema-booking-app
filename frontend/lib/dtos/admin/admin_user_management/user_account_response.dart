class UserAccountResponse {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String userStatus;
  final String role;
  final String accountStatus;
  final String? avatarUrl;

  UserAccountResponse({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.userStatus,
    required this.role,
    required this.accountStatus,
    this.avatarUrl,
  });

  UserAccountResponse copyWith({String? accountStatus, String? role}) {
    return UserAccountResponse(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      gender: gender,
      userStatus: userStatus,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus, // Chỉ update nếu có giá trị mới
    );
  }

  factory UserAccountResponse.fromJson(Map<String, dynamic> json) {
    return UserAccountResponse(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      userStatus: json['userStatus'] ?? '',
      role: json['role'] ?? '',
      accountStatus: json['accountStatus'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }
}
