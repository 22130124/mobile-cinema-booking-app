class UserAccount {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String userStatus;
  final String role;
  final String accountStatus;
  final String? avatarUrl;

  UserAccount({
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

  UserAccount copyWith({String? accountStatus}) {
    return UserAccount(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      gender: gender,
      userStatus: userStatus,
      role: role,
      accountStatus:
          accountStatus ?? this.accountStatus, // Chỉ update nếu có giá trị mới
    );
  }
}
