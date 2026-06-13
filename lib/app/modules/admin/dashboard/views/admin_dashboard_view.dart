import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../routes/app_routes.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: controller.fetchStats,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: () async {
              final confirm = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await SupabaseService.to.auth.signOut();
                StorageService.to.clearSession();
                Get.offAllNamed(Routes.LOGIN);
              }
            },
          ),
        ],
      ),
      body: GetBuilder<AdminDashboardController>(
        builder: (_) {
          if (controller.isLoading) return const AppLoader();
          return RefreshIndicator(
            onRefresh: controller.fetchStats,
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.md),
              children: [
                Text('Overview', style: AppTextStyles.h2),
                const SizedBox(height: AppDimensions.md),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total\nRestaurants',
                        value: '${controller.totalRestaurants}',
                        icon: Icons.store_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: _StatCard(
                        label: 'Open\nNow',
                        value: '${controller.openRestaurants}',
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total\nUsers',
                        value: '${controller.totalUsers}',
                        icon: Icons.people_outline,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: _StatCard(
                        label: 'Vendor\nAccounts',
                        value: '${controller.totalVendors}',
                        icon: Icons.storefront_outlined,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.lg),
                Text('Management', style: AppTextStyles.h2),
                const SizedBox(height: AppDimensions.sm),
                _NavCard(
                  icon: Icons.store_outlined,
                  iconColor: AppColors.primary,
                  title: 'Restaurants',
                  subtitle: 'Add restaurants, toggle open/close, assign vendors',
                  onTap: () => Get.toNamed(Routes.ADMIN_VENDORS),
                ),
                const SizedBox(height: AppDimensions.sm),
                _NavCard(
                  icon: Icons.people_outline,
                  iconColor: AppColors.secondary,
                  title: 'Users',
                  subtitle: 'View all registered users and their roles',
                  onTap: () => Get.toNamed(Routes.ADMIN_USERS),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Icon(icon, color: color, size: AppDimensions.iconMd),
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: AppTextStyles.h2.copyWith(color: color)),
                  Text(label, style: AppTextStyles.caption, maxLines: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppDimensions.sm),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: AppTextStyles.h3),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
