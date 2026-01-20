import 'package:flutter/material.dart';
import 'package:frontend/services/user/user_service.dart';
import '../../config/app_colors.dart';
import '../../model/admin/admin_user_management/user_info.dart';
import '../../services/auth/auth_service.dart';
import '../../widgets/admin/user_management/confirmation_dialog.dart';
import '../../widgets/admin/user_management/dropdown.dart';
import '../../widgets/admin/user_management/user_account_card.dart';
import '../../widgets/admin/user_management/user_detail_dialog.dart';
import '../../widgets/admin/user_management/user_form_dialog.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  // Biến lưu giá trị filter hiện tại. Null nghĩa là chọn "All" (Tất cả).
  String? roleFilter;
  String? statusFilter;
  List<UserInfo> data = []; // data hiển thị

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Hàm refresh lại trang
  Future<void> _refresh() async {
    setState(() {
      roleFilter = null;
      statusFilter = null;
    });

    final result = await UserService().getUserAccountList();

    setState(() {
      data = result;
    });
  }

  // Hàm lấy data để hiển thị
  Future<void> _fetchData() async {
    final result = await UserService().getUserAccountList();
    setState(() {
      data = result;
    });
  }

  // Hàm mở modal chi tiết
  void _viewUserDetail(UserInfo user) {
    showDialog(
      context: context,
      builder: (_) => UserDetailDialog(
        user: user,
        // Truyền callback để user_profile có thể bấm nút "Sửa" ngay trong modal chi tiết
        // Nó sẽ đóng modal chi tiết và mở form sửa.
        onEdit: () => _openUserForm(user: user),
      ),
    );
  }

  // Hàm mở modal thêm/chỉnh sửa thông tin user_profile
  // Nếu [user_profile] == null => Chế độ Thêm mới (Create).
  // Nếu [user_profile] != null => Chế độ Chỉnh sửa (Edit).
  void _openUserForm({UserInfo? user}) {
    showDialog(
      context: context,
      // Bắt buộc người dùng phải bấm nút Lưu hoặc Hủy, không bấm ra ngoài được.
      barrierDismissible: false,
      builder: (_) => UserFormDialog(
        user: user,
        // Callback nhận về dữ liệu user_profile sau khi người dùng bấm submit
        onSubmit: (updatedUser) async {
          if (user == null) {
            try {
              // Gọi API tạo user mới
              await UserService().createNewUserFromAdmin(updatedUser);

              // Insert vào đầu list để dễ thấy
              setState(() {
                data.insert(0, updatedUser);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tạo người dùng mới thành công')),
              );

              return true;
            } catch (e) {
              _showError(e.toString());
              return false;
            }
          } else {
            // Logic Cập nhật: Tìm và thay thế thông tin
            try {
              // Gọi API cập nhật thông tin
              await UserService().updateUserInfo(updatedUser);

              final index = data.indexWhere((u) => u.id == user.id);
              if (index != -1) {
                setState(() {
                  data[index] = updatedUser;
                });
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cập nhật thông tin thành công')),
              );

              return true;
            } catch (e) {
              _showError(e.toString());
              return false;
            }
          }
        },
      ),
    );
  }

  // Hàm xử lý khóa/mở khóa
  // Hiển thị dialog xác nhận trước khi thực hiện hành động.
  void _toggleLockUser(UserInfo user) {
    final isCurrentlyLocked = user.accountStatus == 'INACTIVE';

    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: isCurrentlyLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
        content: isCurrentlyLocked
            ? 'Bạn có chắc muốn mở khóa cho ${user.fullName}?'
            : 'Người dùng này sẽ không thể đăng nhập. Bạn có chắc chắn?',
        onConfirm: () async {
          _showLoading();

          try {
            if (isCurrentlyLocked) {
              await AuthService().unlockAccount(user.email);
            } else {
              await AuthService().lockAccount(user.email);
            }

            final index = data.indexWhere((u) => u.id == user.id);
            if (index != -1) {
              setState(() {
                data[index] = user.copyWith(
                  accountStatus: isCurrentlyLocked ? 'ACTIVE' : 'INACTIVE',
                );
              });
            }

            _hideLoading();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isCurrentlyLocked
                      ? 'Mở khóa tài khoản thành công'
                      : 'Khóa tài khoản thành công',
                ),
              ),
            );
          } catch (e) {
            _hideLoading();
            _showError(e.toString());
          }
        },
      ),
    );
  }

  // Hàm xử lý khóa/mở khóa
  // Hiển thị dialog xác nhận trước khi thực hiện hành động.
  void _toggleChangeRole(UserInfo user) {
    final isAdmin = user.role == 'ADMIN';

    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: isAdmin ? 'Chuyển sang User' : 'Đặt làm Admin',
        content: isAdmin
            ? 'Bạn có chắc muốn thu hồi quyền Admin của người dùng này?'
            : 'Bạn có chắc muốn cấp quyền Admin cho người dùng này?',
        onConfirm: () async {
          _showLoading();

          try {
            if (isAdmin) {
              await AuthService().setUser(user.email);
            } else {
              await AuthService().setAdmin(user.email);
            }

            final index = data.indexWhere((u) => u.id == user.id);
            if (index != -1) {
              setState(() {
                data[index] = user.copyWith(role: isAdmin ? 'USER' : 'ADMIN');
              });
            }

            _hideLoading();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isAdmin ? 'Đã chuyển quyền về User' : 'Đã cấp quyền Admin',
                ),
              ),
            );
          } catch (e) {
            _hideLoading();
            _showError(e.toString());
          }
        },
      ),
    );
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoading() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // Logic lọc danh sách user_profile dựa trên bộ lọc (Filter)
    // Nếu filter là null thì lấy hết, ngược lại chỉ lấy item trùng khớp
    final filteredUsers = data.where((u) {
      if (roleFilter != null && u.role != roleFilter) return false;
      if (statusFilter != null && u.accountStatus != statusFilter) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        centerTitle: true,
        title: const Text(
          'Users & Accounts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.accent),
            // Khi nhấn sẽ gọi setState để rebuild UI
            onPressed: _refresh,
          ),
        ],
      ),
      // Nút nổi (Floating Action Button) để thêm user_profile mới
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
        // Gọi hàm form với user_profile = null để kích hoạt chế độ Thêm mới
        onPressed: () => _openUserForm(user: null),
      ),
      // Nội dung chính
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Khu vực hiển thị dropdown filters
            // Tách ra để code dễ đọc hơn
            _buildFilters(),
            const SizedBox(height: 12),
            // Danh sách user (List View)
            Expanded(
              child: ListView.separated(
                itemCount: filteredUsers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => UserAccountCard(
                  user: filteredUsers[i],
                  // Gán các hàm xử lý sự kiện cho từng thẻ User
                  onEdit: () => _openUserForm(user: filteredUsers[i]),
                  onLockToggle: () => _toggleLockUser(filteredUsers[i]),
                  onRoleToggle: () => _toggleChangeRole(filteredUsers[i]),
                  onTap: () => _viewUserDetail(filteredUsers[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget xây dựng khu vực bộ lọc (Filter Area)
  Widget _buildFilters() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        // Dropdown lọc theo Role (User/Admin)
        Dropdown<String>(
          value: roleFilter,
          items: const {null: 'Tất cả', 'USER': 'User', 'ADMIN': 'Admin'},
          onChanged: (v) => setState(() => roleFilter = v),
        ),
        // Dropdown lọc theo Status (Unverified/Active/Inactive)
        Dropdown<String>(
          value: statusFilter,
          items: const {
            null: 'Tất cả',
            'ACTIVE': 'Hoạt động',
            'INACTIVE': 'Bị khóa',
            'UNVERIFIED': 'Chờ xác thực',
          },
          onChanged: (v) => setState(() => statusFilter = v),
        ),
      ],
    );
  }
}
