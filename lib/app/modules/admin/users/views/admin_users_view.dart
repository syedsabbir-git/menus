import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_users_controller.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../data/models/user_model.dart';

class AdminUsersView extends GetView<AdminUsersController> {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppDimensions.md, 0, AppDimensions.md, AppDimensions.sm),
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name, email or role...',
                prefixIcon:
                    const Icon(Icons.search, size: AppDimensions.iconMd),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: GetBuilder<AdminUsersController>(
        builder: (_) {
          if (controller.isLoading) return const AppLoader();
          final list = controller.filtered;
          if (list.isEmpty) {
            return EmptyState(
              message: controller.searchQuery.isEmpty
                  ? 'No users found.'
                  : 'No results for "${controller.searchQuery}".',
              icon: Icons.people_outline,
              action: controller.fetchAll,
              actionLabel: 'Refresh',
            );
          }
          return RefreshIndicator(
            onRefresh: controller.fetchAll,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.md),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _UserTile(user: list[i]),
            ),
          );
        },
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});
  final UserModel user;

  Color _roleColor(String role) => switch (role) {
        'admin' => Colors.deepPurple,
        'vendor' => AppColors.secondary,
        _ => AppColors.primary,
      };

  IconData _roleIcon(String role) => switch (role) {
        'admin' => Icons.admin_panel_settings_outlined,
        'vendor' => Icons.store_outlined,
        _ => Icons.person_outline,
      };

  @override
  Widget build(BuildContext context) {
    final initial = user.fullName.isNotEmpty
        ? user.fullName[0].toUpperCase()
        : user.email[0].toUpperCase();

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(vertical: AppDimensions.xs),
      leading: CircleAvatar(
        backgroundColor: _roleColor(user.role).withValues(alpha: 0.15),
        child: Text(
          initial,
          style: AppTextStyles.body.copyWith(
            color: _roleColor(user.role),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        user.fullName.isNotEmpty ? user.fullName : '(no name)',
        style: AppTextStyles.body,
      ),
      subtitle: Text(user.email, style: AppTextStyles.caption),
      trailing: Chip(
        visualDensity: VisualDensity.compact,
        avatar: Icon(_roleIcon(user.role),
            size: 14, color: _roleColor(user.role)),
        label: Text(
          user.role,
          style: AppTextStyles.caption.copyWith(color: _roleColor(user.role)),
        ),
        backgroundColor: _roleColor(user.role).withValues(alpha: 0.1),
        side: BorderSide.none,
      ),
    );
  }
}
