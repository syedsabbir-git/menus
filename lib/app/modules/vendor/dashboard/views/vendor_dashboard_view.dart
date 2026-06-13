import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_dashboard_controller.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../routes/app_routes.dart';

class VendorDashboardView extends GetView<VendorDashboardController> {
  const VendorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
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
        final r = controller.restaurant.value;
        if (r == null) {
          return const Center(child: Text('No restaurant linked to your account.'));
        }
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(r.name, style: AppTextStyles.h2),
            if (r.description != null) ...[
              const SizedBox(height: 8),
              Text(r.description!, style: AppTextStyles.bodySecondary),
            ],
            const SizedBox(height: 24),
            SwitchListTile(
              value: r.isOpen,
              onChanged: (_) => controller.toggleOpen(),
              title: Text(r.isOpen ? 'Restaurant is OPEN' : 'Restaurant is CLOSED',
                  style: AppTextStyles.h3),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.restaurant_menu, color: AppColors.primary),
              title: const Text('Manage Menu'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed(Routes.MENU_MANAGEMENT, arguments: r),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: AppColors.primary),
              title: const Text('Incoming Orders'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed(Routes.VENDOR_ORDERS, arguments: r),
            ),
          ],
        );
      }),
    );
  }
}
