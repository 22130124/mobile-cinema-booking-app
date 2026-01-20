import 'dart:convert';
import 'dart:io';

import 'package:frontend/dtos/upload/upload_image_response.dart';
import 'package:frontend/storage/jwt_token_storage.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';

class UploadService {
  final String baseUrl = '$BASE_URL/files';

  // Upload hình ảnh avatar lên server
  // [imageFile]: file ảnh cần upload
  // [type]: loại ảnh (ví dụ: avatar, movie...)
  Future<UploadImageResponse> uploadImageAvatar(
    File imageFile,
    String type,
  ) async {
    final uri = Uri.parse('$baseUrl/image/$type');

    final request = http.MultipartRequest('POST', uri);

    // Thêm file ảnh
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    // Gửi kèm JWT Token
    final jwtToken = await JwtTokenStorage.getToken();
    request.headers['Authorization'] = 'Bearer $jwtToken';

    // Gọi API
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    // Kiểm tra kết quả
    if (response.statusCode == 200) {
      // Chuyển đổi kết quả thành UploadImageResponse
      final json = jsonDecode(responseBody);
      return UploadImageResponse.fromJson(json);
    } else {
      throw Exception('Upload image failed: $responseBody');
    }
  }
}
