import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/models/user/update_user_request.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/services/user/user_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/upload/upload_service.dart';
import '../../widgets/auth/custom_textfield.dart';
import '../../widgets/auth/custom_button.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _gender = "male";
  File? _avatar;
  String? _avatarUrl;
  String? _avatarPublicId;
  bool _isLoading = false;
  bool _isUploadingAvatar = false;

  final ImagePicker _picker = ImagePicker();

  // Hàm bất đồng bộ (async) để người dùng chọn ảnh đại diện (avatar) từ thư viện ảnh
  Future<void> _pickAvatar() async {
    // Hiển thị trình chọn ảnh (Image Picker) để người dùng chọn ảnh từ gallery
    // imageQuality: 80 có nghĩa là nén ảnh xuống 80% chất lượng để giảm dung lượng
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery, // Lấy ảnh từ thư viện ảnh của thiết bị
      imageQuality: 80, // Chất lượng ảnh sau khi nén (0-100)
    );

    // Nếu không chọn ảnh thì thoát
    if (picked == null) return;

    // Lấy ra file ảnh
    final file = File(picked.path);

    // Hiển thị ảnh ngay lập tức
    setState(() {
      _avatar = file;
      _isUploadingAvatar = true;
    });

    try {
      // Gọi API upload avatar
      final result = await UploadService().uploadImageAvatar(file, 'avatar');

      // Lưu URL avatar trả về từ server
      _avatarUrl = result.secureUrl;
      _avatarPublicId = result.publicId;

      debugPrint("avatarUrl: $_avatarUrl");
      debugPrint("avatarPublicId: $_avatarPublicId");

      // Nếu context đã bị hủy thì không làm gì cả
      if (!mounted) return;

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload ảnh đại diện thành công')),
      );
    } catch (e) {
      // Nếu context đã bị hủy thì không làm gì cả
      if (!mounted) return;

      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload ảnh thất bại: $e')));
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          "Thông Tin Cá Nhân",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // AVATAR
            GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: _avatar != null
                        ? FileImage(_avatar!)
                        : null,
                    child: _isUploadingAvatar
                        ? const CircularProgressIndicator(color: Colors.white)
                        : _avatar == null
                        ? const Icon(
                            Icons.person,
                            size: 55,
                            color: Colors.white54,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blueAccent,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // HỌ TÊN
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Họ và Tên",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            CustomTextField(
              controller: _fullNameController,
              hintText: "Nhập họ và tên",
              icon: Icons.person_outline,
            ),

            // GIỚI TÍNH
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Giới Tính",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _genderItem("male", "Nam"),
                const SizedBox(width: 20),
                _genderItem("female", "Nữ"),
              ],
            ),

            // SỐ ĐIỆN THOẠI
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Số Điện Thoại",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            CustomTextField(
              controller: _phoneController,
              hintText: "Nhập số điện thoại",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 40),

            // BUTTON
            CustomButton(
              text: "Lưu Thông Tin",
              isLoading: _isLoading,
              onTapAsync: () async {
                final fullName = _fullNameController.text;
                final phone = _phoneController.text;
                final gender = _gender;

                // Kiểm tra dữ liệu đầu vào
                if (_fullNameController.text.isEmpty ||
                    _phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Vui lòng nhập đầy đủ thông tin"),
                    ),
                  );
                  return;
                }

                // Hiển thị trạng thái loading khi đang gọi API
                setState(() => _isLoading = true);
                try {
                  final updateProfileRequest = UpdateUserRequest(
                    fullName: fullName,
                    phone: phone,
                    gender: gender,
                    avatarUrl: _avatarUrl,
                    avatarPublicId: _avatarPublicId,
                  );
                  await UserService().updateProfile(updateProfileRequest);

                  // Kiểm tra context còn sống hay không
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Cập nhật thông tin hồ sơ thành công"),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Delay một chút trước khi chuyển trang để người
                  // dùng kịp nhìn thấy thông báo
                  await Future.delayed(const Duration(seconds: 2));

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                } finally {
                  if (context.mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderItem(String value, String label) {
    final bool isSelected = _gender == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.white30,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
