class UserInfo {
  final int id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? gender;
  final String? userStatus;
  final String? role;
  final String? accountStatus;
  final String? avatarUrl;
  final String? password;

  UserInfo({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.gender,
    this.userStatus,
    this.role,
    this.accountStatus,
    this.avatarUrl,
    this.password
  });

  UserInfo copyWith({
    String? email,
    String? fullName,
    String? phone,
    String? gender,
    String? userStatus,
    String? role,
    String? accountStatus,
    String? avatarUrl,
  }) {
    return UserInfo(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      userStatus: userStatus ?? this.userStatus,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }


  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
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
