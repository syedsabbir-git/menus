import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_home_controller.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../routes/app_routes.dart';

class CustomerHomeView extends GetView<CustomerHomeController> {
  const CustomerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await SupabaseService.to.auth.signOut();
              StorageService.to.clearSession();
              Get.offAllNamed(Routes.LOGIN);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const AppLoader();
        if (controller.error.value.isNotEmpty) {
          return EmptyState(
            message: 'Failed to load restaurants.',
            icon: Icons.error_outline,
            action: controller.fetchRestaurants,
            actionLabel: 'Retry',
          );
        }
        if (controller.restaurants.isEmpty) {
          return const EmptyState(
            message: 'No restaurants available yet.',
            icon: Icons.store_outlined,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchRestaurants,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.restaurants.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final r = controller.restaurants[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.store_outlined, color: AppColors.primary),
                  ),
                  title: Text(r.name, style: AppTextStyles.h3),
                  subtitle: Text(r.description ?? '', style: AppTextStyles.bodySecondary),
                  trailing: Chip(
                    label: Text(r.isOpen ? 'Open' : 'Closed',
                        style: TextStyle(
                          color: r.isOpen ? AppColors.success : AppColors.error,
                          fontSize: 12,
                        )),
                    backgroundColor: r.isOpen
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                  ),
                  onTap: r.isOpen
                      ? () => Get.toNamed(Routes.RESTAURANT_DETAIL, arguments: r)
                      : () => showSnackBar(message: 'This restaurant is currently closed.', isError: true),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
