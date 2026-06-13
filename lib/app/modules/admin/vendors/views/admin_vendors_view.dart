import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_vendors_controller.dart';
import '../widgets/restaurant_form_sheet.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../data/models/restaurant_model.dart';

class AdminVendorsView extends GetView<AdminVendorsController> {
  const AdminVendorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: controller.fetchAll,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => RestaurantFormSheet.show(),
        icon: const Icon(Icons.add),
        label: const Text('Add Restaurant'),
      ),
      body: GetBuilder<AdminVendorsController>(
        builder: (_) {
          if (controller.isLoading) return const AppLoader();
          if (controller.restaurants.isEmpty) {
            return EmptyState(
              message: 'No restaurants yet.\nTap + to add one.',
              icon: Icons.store_outlined,
              action: controller.fetchAll,
              actionLabel: 'Refresh',
            );
          }
          return RefreshIndicator(
            onRefresh: controller.fetchAll,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.md,
                AppDimensions.md,
                AppDimensions.md,
                AppDimensions.md + 72,
              ),
              itemCount: controller.restaurants.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.sm),
              itemBuilder: (_, i) => _RestaurantCard(
                restaurant: controller.restaurants[i],
                controller: controller,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant, required this.controller});

  final RestaurantModel restaurant;
  final AdminVendorsController controller;

  @override
  Widget build(BuildContext context) {
    final isToggling = controller.togglingId == restaurant.id;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: const Icon(Icons.store_outlined,
                      color: AppColors.primary, size: AppDimensions.iconMd),
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(restaurant.name, style: AppTextStyles.h3),
                      if (restaurant.description != null &&
                          restaurant.description!.isNotEmpty)
                        Text(restaurant.description!,
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') {
                      RestaurantFormSheet.show(restaurant: restaurant);
                    }
                    if (v == 'delete') controller.deleteRestaurant(restaurant);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            const Divider(height: 1),
            const SizedBox(height: AppDimensions.sm),
            Row(
              children: [
                _VendorChip(ownerId: restaurant.ownerId, controller: controller),
                const Spacer(),
                if (isToggling)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Row(
                    children: [
                      Text(
                        restaurant.isOpen ? 'Open' : 'Closed',
                        style: AppTextStyles.caption.copyWith(
                          color: restaurant.isOpen
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.xs),
                      Switch.adaptive(
                        value: restaurant.isOpen,
                        activeThumbColor: AppColors.success,
                        activeTrackColor:
                            AppColors.success.withValues(alpha: 0.5),
                        onChanged: (_) =>
                            controller.toggleOpenStatus(restaurant),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorChip extends StatelessWidget {
  const _VendorChip({required this.ownerId, required this.controller});

  final String? ownerId;
  final AdminVendorsController controller;

  @override
  Widget build(BuildContext context) {
    if (ownerId == null) {
      return Chip(
        visualDensity: VisualDensity.compact,
        avatar: const Icon(Icons.person_off_outlined,
            size: 14, color: AppColors.textSecondary),
        label: Text('Unassigned', style: AppTextStyles.caption),
        backgroundColor: AppColors.textSecondary.withValues(alpha: 0.1),
      );
    }
    final vendor = controller.vendorUsers.firstWhereOrNull(
      (u) => u.id == ownerId,
    );
    final label = vendor != null && vendor.fullName.isNotEmpty
        ? vendor.fullName
        : ownerId!.substring(0, 8);
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar:
          const Icon(Icons.person_outline, size: 14, color: AppColors.primary),
      label: Text(label,
          style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
    );
  }
}
