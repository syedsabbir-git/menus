import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_dashboard_controller.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../routes/app_routes.dart';

class VendorDashboardView extends GetView<VendorDashboardController> {
  const VendorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Restaurant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: GetBuilder<VendorDashboardController>(
        builder: (_) {
          if (controller.isLoading) return const AppLoader();
          final r = controller.restaurant;
          if (r == null) {
            return const EmptyState(
              icon: Icons.store_outlined,
              message: 'No restaurant is linked to your account.\nContact support to get set up.',
            );
          }
          return RefreshIndicator(
            onRefresh: controller.fetchRestaurant,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.md,
                AppDimensions.md,
                AppDimensions.md,
                AppDimensions.xl,
              ),
              children: [
                _RestaurantHeader(restaurant: r),
                const SizedBox(height: AppDimensions.md),
                _StatusCard(controller: controller),
                const SizedBox(height: AppDimensions.md),
                _PendingOrdersStat(controller: controller),
                const SizedBox(height: AppDimensions.lg),
                Text('Quick Actions', style: AppTextStyles.h3),
                const SizedBox(height: AppDimensions.sm),
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.restaurant_menu_outlined,
                        label: 'Manage\nMenu',
                        onTap: () => Get.toNamed(Routes.MENU_MANAGEMENT, arguments: r),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.receipt_long_outlined,
                        label: 'Incoming\nOrders',
                        onTap: () => Get.toNamed(Routes.VENDOR_ORDERS, arguments: r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will be returned to the login screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              await SupabaseService.to.auth.signOut();
              StorageService.to.clearSession();
              Get.offAllNamed(Routes.LOGIN);
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _RestaurantHeader extends StatelessWidget {
  const _RestaurantHeader({required this.restaurant});
  final RestaurantModel restaurant;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusLg),
            ),
            child: AppNetworkImage(
              url: restaurant.imageUrl,
              height: 160,
              width: double.infinity,
              placeholderIcon: Icons.store_outlined,
              iconSize: AppDimensions.iconXxl,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant.name, style: AppTextStyles.h2),
                if (restaurant.description != null) ...[
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    restaurant.description!,
                    style: AppTextStyles.bodySecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.controller});
  final VendorDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final isOpen = controller.restaurant!.isOpen;
    final accent = isOpen ? AppColors.success : AppColors.error;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.lg,
        vertical: AppDimensions.md,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Row(
        children: [
          _PulseDot(color: accent, active: isOpen),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? 'Open for orders' : 'Currently closed',
                  style: AppTextStyles.h3.copyWith(color: accent),
                ),
                Text(
                  isOpen
                      ? 'Customers can place orders now'
                      : 'Toggle to start accepting orders',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          if (controller.isToggling)
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            Switch(
              value: isOpen,
              activeThumbColor: AppColors.success,
              onChanged: (_) => controller.toggleOpen(),
            ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot({required this.color, required this.active});
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: active
            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)]
            : null,
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      elevation: AppDimensions.cardElevation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.lg,
            horizontal: AppDimensions.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Icon(icon, color: AppColors.primary, size: AppDimensions.iconLg),
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                label,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _PendingOrdersStat extends StatelessWidget {
  const _PendingOrdersStat({required this.controller});
  final VendorDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final count = controller.pendingOrderCount;
    final hasOrders = count > 0;
    final color = hasOrders ? AppColors.warning : AppColors.textSecondary;

    return Material(
      color: hasOrders
          ? AppColors.warning.withValues(alpha: 0.08)
          : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        onTap: () => Get.toNamed(
          Routes.VENDOR_ORDERS,
          arguments: controller.restaurant,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.lg,
            vertical: AppDimensions.md,
          ),
          child: Row(
            children: [
              Container(
                width: AppDimensions.iconXxl,
                height: AppDimensions.iconXxl,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Orders',
                      style: AppTextStyles.h3.copyWith(color: color),
                    ),
                    Text(
                      hasOrders
                          ? 'Tap to review and accept'
                          : 'No orders waiting',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
