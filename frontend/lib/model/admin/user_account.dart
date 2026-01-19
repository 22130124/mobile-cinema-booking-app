enum UserGender { male, female }

enum UserStatus { completed, incompleted }

enum AccountRole { user, admin }

enum AccountStatus { unverified, active, inactive }

class UserAccountModel {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final UserGender gender;
  final UserStatus userStatus;
  final AccountRole role;
  final AccountStatus accountStatus;
  final String? avatarUrl;

  UserAccountModel({
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

  UserAccountModel copyWith({AccountStatus? accountStatus}) {
    return UserAccountModel(
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
