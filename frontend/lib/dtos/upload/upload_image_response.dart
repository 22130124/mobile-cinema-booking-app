class UploadImageResponse {
  final String publicId;
  final String secureUrl;

  UploadImageResponse({required this.publicId, required this.secureUrl});

  factory UploadImageResponse.fromJson(Map<String, dynamic> json) {
    return UploadImageResponse(
      publicId: json['publicId'],
      secureUrl: json['secureUrl'],
    );
  }
}