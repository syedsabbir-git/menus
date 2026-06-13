import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_profile_controller.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';

class CustomerProfileView extends GetView<CustomerProfileController> {
  const CustomerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: GetBuilder<CustomerProfileController>(
        builder: (_) {
          if (controller.isLoading) return const AppLoader();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _avatar(),
                const SizedBox(height: AppDimensions.lg),
                _infoTile(Icons.person_outline, 'Name', controller.fullName),
                _infoTile(Icons.email_outlined, 'Email', controller.email),
                _infoTile(Icons.phone_outlined, 'Phone', controller.phone),
                const SizedBox(height: AppDimensions.lg),
                Text('Delivery Address', style: AppTextStyles.h3),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  'This address will be pre-filled at checkout.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppDimensions.md),
                Form(
                  key: controller.formKey,
                  child: AppTextField(
                    hint: 'Hall name, room number, or full address',
                    controller: controller.addressController,
                    maxLines: 2,
                    validator: (v) => Validators.required(v, fieldName: 'Delivery address'),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                PrimaryButton(
                  label: 'Save Address',
                  isLoading: controller.isSaving,
                  onPressed: controller.saveAddress,
                ),
                const SizedBox(height: AppDimensions.xl),
                const Divider(),
                const SizedBox(height: AppDimensions.sm),
                ListTile(
                  leading: const Icon(Icons.logout_outlined, color: AppColors.error),
                  title: Text('Sign Out',
                      style: AppTextStyles.body.copyWith(color: AppColors.error)),
                  onTap: () => _confirmLogout(context),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _avatar() {
    return Center(
      child: CircleAvatar(
        radius: AppDimensions.avatarLg,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Text(
          controller.fullName.isNotEmpty
              ? controller.fullName[0].toUpperCase()
              : '?',
          style: AppTextStyles.h1.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        children: [
          Icon(icon, size: AppDimensions.iconMd, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(value.isEmpty ? '—' : value, style: AppTextStyles.body),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: Text('Sign Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
