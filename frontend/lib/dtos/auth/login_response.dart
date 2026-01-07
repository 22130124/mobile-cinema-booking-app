class LoginResponse {
  final String jwtToken;
  final bool? userStatus;

  LoginResponse({required this.jwtToken, this.userStatus});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      jwtToken: json['jwtToken'],
      userStatus: json['userStatus'],
    );
  }
}