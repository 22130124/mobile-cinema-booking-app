class LoginResponse {
  final String jwtToken;
  final bool userStatus;
  final String accountStatus;

  LoginResponse({required this.jwtToken, required this.userStatus, required this.accountStatus});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      jwtToken: json['jwtToken'],
      userStatus: json['userStatus'],
      accountStatus: json['accountStatus']
    );
  }
}