import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../routes/app_routes.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Platform Overview', style: AppTextStyles.h2),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.store_outlined, color: AppColors.primary),
            title: const Text('Manage Vendors'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(Routes.ADMIN_VENDORS),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people_outline, color: AppColors.primary),
            title: const Text('Manage Users'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(Routes.ADMIN_USERS),
          ),
        ],
      ),
    );
  }
}
