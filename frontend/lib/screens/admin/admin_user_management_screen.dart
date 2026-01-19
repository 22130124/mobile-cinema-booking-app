import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../model/admin/user_account.dart';
import '../../widgets/admin/user_management/confirmation_dialog.dart';
import '../../widgets/admin/user_management/dropdown.dart';
import '../../widgets/admin/user_management/user_account_card.dart';
import '../../widgets/admin/user_management/user_detail_dialog.dart';
import '../../widgets/admin/user_management/user_form_dialog.dart';

final fakeUsers = <UserAccountModel>[
  UserAccountModel(
    id: 1,
    fullName: 'Nguyen Van A',
    email: 'a@gmail.com',
    phone: '0901234567',
    gender: UserGender.male,
    userStatus: UserStatus.completed,
    role: AccountRole.user,
    accountStatus: AccountStatus.active,
    avatarUrl: 'https://res.cloudinary.com/dmjlttgiu/image/upload/v1768758743/cinema/avatar/qkjtebe4vxenthmtjmtu.jpg'
  ),
  UserAccountModel(
    id: 2,
    fullName: 'Tran Thi B',
    email: 'b@gmail.com',
    phone: '0912345678',
    gender: UserGender.female,
    userStatus: UserStatus.incompleted,
    role: AccountRole.admin,
    accountStatus: AccountStatus.inactive,
  ),
];

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  // Biến lưu giá trị filter hiện tại. Null nghĩa là chọn "All" (Tất cả).
  AccountRole? roleFilter;
  AccountStatus? statusFilter;

  // Hàm mở modal chi tiết
  void _viewUserDetail(UserAccountModel user) {
    showDialog(
      context: context,
      builder: (_) => UserDetailDialog(
        user: user,
        // Truyền callback để user có thể bấm nút "Sửa" ngay trong modal chi tiết
        // Nó sẽ đóng modal chi tiết và mở form sửa.
        onEdit: () => _openUserForm(user: user),
      ),
    );
  }

  // Hàm mở modal thêm/chỉnh sửa thông tin user
  // Nếu [user] == null => Chế độ Thêm mới (Create).
  // Nếu [user] != null => Chế độ Chỉnh sửa (Edit).
  void _openUserForm({UserAccountModel? user}) {
    showDialog(
      context: context,
      // Bắt buộc người dùng phải bấm nút Lưu hoặc Hủy, không bấm ra ngoài được.
      barrierDismissible: false,
      builder: (_) => UserFormDialog(
        user: user,
        // Callback nhận về dữ liệu user sau khi người dùng bấm submit
        onSubmit: (updatedUser) {
          setState(() {
            if (user == null) {
              // Logic Thêm mới: Insert vào đầu list để dễ thấy
              fakeUsers.insert(0, updatedUser);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tạo tài khoản thành công!')),
              );
            } else {
              // Logic Cập nhật: Tìm và thay thế thông tin
              final index = fakeUsers.indexWhere((u) => u.id == user.id);
              if (index != -1) {
                fakeUsers[index] = updatedUser;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cập nhật thành công!')),
                );
              }
            }
          });
        },
      ),
    );
  }

  // Hàm xử lý khóa/mở khóa
  // Hiển thị dialog xác nhận trước khi thực hiện hành động.
  void _toggleLockUser(UserAccountModel user) {
    // Kiểm tra xem user hiện tại đang bị khóa hay không
    bool isCurrentlyLocked = user.accountStatus == AccountStatus.inactive;
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        // Tiêu đề và nội dung dialog thay đổi tùy theo trạng thái hiện tại
        title: isCurrentlyLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
        content: isCurrentlyLocked
            ? 'Bạn có chắc muốn mở khóa cho user ${user.fullName}?'
            : 'Người dùng này sẽ không thể đăng nhập. Bạn có chắc chắn?',
        onConfirm: () {
          // Khi người dùng bấm "Đồng ý"
          setState(() {
            final index = fakeUsers.indexWhere((u) => u.id == user.id);
            if (index != -1) {
              // Tạo bản sao của user với trạng thái accountStatus mới (đảo ngược trạng thái cũ)
              fakeUsers[index] = user.copyWith(
                accountStatus: isCurrentlyLocked
                    ? AccountStatus.active
                    : AccountStatus.inactive,
              );
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logic lọc danh sách user dựa trên bộ lọc (Filter)
    // Nếu filter là null thì lấy hết, ngược lại chỉ lấy item trùng khớp
    final filteredUsers = fakeUsers.where((u) {
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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.accent),
            // Khi nhấn sẽ gọi setState để rebuild UI
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      // Nút nổi (Floating Action Button) để thêm user mới
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
        // Gọi hàm form với user = null để kích hoạt chế độ Thêm mới
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
        Dropdown<AccountRole>(
          value: roleFilter,
          items: const {
            null: 'Tất cả',
            AccountRole.user: 'User',
            AccountRole.admin: 'Admin',
          },
          onChanged: (v) => setState(() => roleFilter = v),
        ),
        // Dropdown lọc theo Status (Unverified/Active/Inactive)
        Dropdown<AccountStatus>(
          value: statusFilter,
          items: const {
            null: 'Tất cả',
            AccountStatus.active: 'Active',
            AccountStatus.inactive: 'Inactive',
            AccountStatus.unverified: 'Unverified',
          },
          onChanged: (v) => setState(() => statusFilter = v),
        ),
      ],
    );
  }
}
