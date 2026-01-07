import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  String _gender = "nam";
  File? _avatar;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

// Hàm bất đồng bộ (async) để người dùng chọn ảnh đại diện (avatar) từ thư viện ảnh
  Future<void> _pickAvatar() async {
    // Hiển thị trình chọn ảnh (Image Picker) để người dùng chọn ảnh từ gallery
    // imageQuality: 80 có nghĩa là nén ảnh xuống 80% chất lượng để giảm dung lượng
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery, // Lấy ảnh từ thư viện ảnh của thiết bị
      imageQuality: 80,           // Chất lượng ảnh sau khi nén (0-100)
    );

    // Kiểm tra xem người dùng có chọn ảnh hay không
    if (picked != null) {
      // Nếu có ảnh được chọn, cập nhật state để hiển thị ảnh mới
      setState(() {
        _avatar = File(picked.path); // Lưu ảnh dưới dạng File từ đường dẫn của ảnh
      });
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
                    backgroundImage:
                    _avatar != null ? FileImage(_avatar!) : null,
                    child: _avatar == null
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
                  )
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
                if (_fullNameController.text.isEmpty ||
                    _phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Vui lòng nhập đầy đủ thông tin"),
                    ),
                  );
                  return;
                }

                setState(() => _isLoading = true);

                await Future.delayed(const Duration(seconds: 1));

                debugPrint("Họ tên: ${_fullNameController.text}");
                debugPrint("Giới tính: $_gender");
                debugPrint("SĐT: ${_phoneController.text}");
                debugPrint("Avatar: ${_avatar?.path}");

                if (!context.mounted) return;

                setState(() => _isLoading = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Lưu thông tin thành công"),
                  ),
                );
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
