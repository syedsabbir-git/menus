import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/menu_management_controller.dart';
import '../widgets/menu_item_form_sheet.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';

class MenuManagementView extends GetView<MenuManagementController> {
  const MenuManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Menu')),
      body: GetBuilder<MenuManagementController>(
        builder: (_) {
          if (controller.isLoading) return const AppLoader();
          if (controller.items.isEmpty) {
            return EmptyState(
              message: 'No menu items yet.\nTap + to add your first item.',
              icon: Icons.no_meals_outlined,
              action: () => MenuItemFormSheet.show(),
              actionLabel: 'Add Item',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              AppDimensions.md,
              AppDimensions.md,
              100,
            ),
            itemCount: controller.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final item = controller.items[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: AppDimensions.xs,
                ),
                title: Text(item.name, style: AppTextStyles.body),
                subtitle: Text(
                  '${item.category?.isEmpty ?? true ? 'No category' : item.category} · ${Formatters.currency(item.price)}',
                  style: AppTextStyles.caption,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: item.isAvailableToday,
                      onChanged: (_) => controller.toggleAvailability(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                      tooltip: 'Edit',
                      onPressed: () => MenuItemFormSheet.show(item: item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      tooltip: 'Delete',
                      onPressed: () => _confirmDelete(context, item.id, item.name),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => MenuItemFormSheet.show(),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Remove "$name" from the menu?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteItem(id);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
