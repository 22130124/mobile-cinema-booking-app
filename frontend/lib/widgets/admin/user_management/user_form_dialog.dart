import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../model/admin/admin_user_management/user_info.dart';
import 'confirmation_dialog.dart';

class UserFormDialog extends StatefulWidget {
  final UserInfo? user; // Nếu null là Tạo mới, có dữ liệu là Sửa
  final Future<bool> Function(UserInfo) onSubmit;

  const UserFormDialog({super.key, this.user, required this.onSubmit});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _emailCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _passCtrl;
  String _gender = 'MALE'; // Mặc định là Nam

  bool get isEditMode => widget.user != null;

  // Hàm kiểm tra định dạng email
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    return emailRegex.hasMatch(email);
  }


  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    _nameCtrl = TextEditingController(text: widget.user?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: widget.user?.phone ?? '');
    _passCtrl = TextEditingController();
    if (isEditMode) {
      _gender = widget.user!.gender!;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // Hiển thị modal xác nhận trước khi lưu
      showDialog(
        context: context,
        builder: (context) => ConfirmationDialog(
          title: isEditMode ? 'Xác nhận cập nhật' : 'Xác nhận tạo mới',
          content: 'Bạn có chắc chắn muốn lưu thông tin này không?',
          onConfirm: () async {
            // Tạo model mới
            final updatedUser = UserInfo(
              id: widget.user?.id ?? DateTime.now().millisecondsSinceEpoch,
              fullName: _nameCtrl.text,
              email: _emailCtrl.text,
              phone: _phoneCtrl.text,
              gender: _gender,
              userStatus: widget.user?.userStatus ?? 'INCOMPLETED',
              role: widget.user?.role ?? 'USER',
              accountStatus: widget.user?.accountStatus ?? 'UNVERIFIED',
              avatarUrl: widget.user?.avatarUrl,
              password: isEditMode ? null : _passCtrl.text,
            );

            final success = await widget.onSubmit(updatedUser);
            if (!context.mounted) return;

            if (success) {
              Navigator.of(context).pop();
            }
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 400, // Giới hạn chiều rộng
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode ? 'Cập nhật User' : 'Thêm User mới',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),

                // Email
                _buildTextField(
                  label: 'Email',
                  isEmail: true,
                  controller: _emailCtrl,
                  required: true,
                ),

                // Password
                // Chỉ hiển thị khi không phải là Edit Mode
                if (!isEditMode)
                  _buildTextField(
                    label: 'Mật khẩu',
                    controller: _passCtrl,
                    isPassword: true, // Tận dụng thuộc tính có sẵn của helper
                    required: true,   // Bắt buộc nhập khi tạo mới
                  ),

                // Họ tên
                _buildTextField(label: 'Họ và tên', controller: _nameCtrl),

                // Số điện thoại
                _buildTextField(
                  label: 'Số điện thoại',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                ),

                // Giới tính
                const Text('Giới tính', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Row(
                  children: [
                    _buildRadio('MALE', 'Nam'),
                    const SizedBox(width: 20),
                    _buildRadio('FEMALE', 'Nữ'),
                  ],
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đóng', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: _handleSave,
                      child: Text(isEditMode ? 'Lưu thay đổi' : 'Tạo mới',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    bool required = false,
    bool isEmail = false,
    bool readOnly = false,
    Color? fillColor,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: fillColor ?? AppColors.backgroundCard,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: (v) {
          if (required && (v == null || v.isEmpty)) {
            return 'Vui lòng nhập $label';
          }

          if (isEmail && v != null && v.isNotEmpty && !isValidEmail(v)) {
            return 'Email không đúng định dạng';
          }

          return null;
        },
      ),
    );
  }

  Widget _buildRadio(String value, String label) {
    return Row(
      children: [
        RadioGroup<String>(
          groupValue: _gender,
          onChanged: (v) => setState(() => _gender = v!),
          child: Radio<String>(
            value: value,
            activeColor: AppColors.accent,
          ),
        ),
        Text(label, style: const TextStyle(color: AppColors.textPrimary)),
      ],
    );
  }
}