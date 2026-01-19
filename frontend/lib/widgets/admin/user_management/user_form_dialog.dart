import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../model/admin/user_account.dart';
import 'confirmation_dialog.dart';

class UserFormDialog extends StatefulWidget {
  final UserAccountModel? user; // Nếu null là Tạo mới, có dữ liệu là Sửa
  final Function(UserAccountModel) onSubmit;

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
  UserGender _gender = UserGender.male; // Mặc định là Nam

  bool get isEditMode => widget.user != null;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    _nameCtrl = TextEditingController(text: widget.user?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: widget.user?.phone ?? '');
    // Ở chế độ Edit, hiển thị placeholder cho pass vì không xem được pass cũ
    _passCtrl = TextEditingController(text: isEditMode ? '********' : '');
    if (isEditMode) {
      _gender = widget.user!.gender;
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
          onConfirm: () {
            // Đóng Form Dialog
            Navigator.pop(context);

            // Tạo model mới (Giả lập)
            final newUser = UserAccountModel(
              id: widget.user?.id ?? DateTime.now().millisecondsSinceEpoch,
              fullName: _nameCtrl.text,
              email: _emailCtrl.text,
              phone: _phoneCtrl.text,
              gender: _gender,
              // Giữ nguyên giá trị cũ hoặc set mặc định
              userStatus: widget.user?.userStatus ?? UserStatus.incompleted,
              role: widget.user?.role ?? AccountRole.user,
              accountStatus: widget.user?.accountStatus ?? AccountStatus.active,
            );

            widget.onSubmit(newUser);
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

                // 1. Email
                _buildTextField(
                  label: 'Email',
                  controller: _emailCtrl,
                  required: true,
                ),

                // 2. Mật khẩu (Logic khóa khi Edit)
                _buildTextField(
                  label: 'Mật khẩu',
                  controller: _passCtrl,
                  isPassword: true,
                  required: !isEditMode, // Chỉ bắt buộc khi tạo mới
                  readOnly: isEditMode,  // Khóa không cho sửa khi Edit
                  fillColor: isEditMode ? Colors.grey.withOpacity(0.2) : null,
                ),

                // 3. Họ tên
                _buildTextField(label: 'Họ và tên', controller: _nameCtrl),

                // 4. Số điện thoại
                _buildTextField(
                  label: 'Số điện thoại',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                ),

                // 5. Giới tính
                const Text('Giới tính', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Row(
                  children: [
                    _buildRadio(UserGender.male, 'Nam'),
                    const SizedBox(width: 20),
                    _buildRadio(UserGender.female, 'Nữ'),
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
        validator: required
            ? (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập $label' : null
            : null,
      ),
    );
  }

  Widget _buildRadio(UserGender value, String label) {
    return Row(
      children: [
        Radio<UserGender>(
          value: value,
          groupValue: _gender,
          activeColor: AppColors.accent,
          onChanged: (v) => setState(() => _gender = v!),
        ),
        Text(label, style: const TextStyle(color: AppColors.textPrimary)),
      ],
    );
  }
}