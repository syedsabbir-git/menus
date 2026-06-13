import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_vendors_controller.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

class AdminVendorsView extends GetView<AdminVendorsController> {
  const AdminVendorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendors')),
      body: Obx(() {
        if (controller.isLoading.value) return const AppLoader();
        if (controller.restaurants.isEmpty) {
          return const EmptyState(message: 'No vendors registered.', icon: Icons.store_outlined);
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.restaurants.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final r = controller.restaurants[i];
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.store, color: Colors.white, size: 18),
              ),
              title: Text(r.name, style: AppTextStyles.body),
              trailing: Chip(
                label: Text(r.isOpen ? 'Open' : 'Closed',
                    style: TextStyle(
                      color: r.isOpen ? AppColors.success : AppColors.error,
                      fontSize: 12,
                    )),
              ),
            );
          },
        );
      }),
    );
  }
}
