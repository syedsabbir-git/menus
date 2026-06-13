import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/menu_management_controller.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

class MenuManagementView extends GetView<MenuManagementController> {
  const MenuManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Menu')),
      body: Obx(() {
        if (controller.isLoading.value) return const AppLoader();
        if (controller.items.isEmpty) {
          return const EmptyState(message: 'No menu items yet.', icon: Icons.no_meals);
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.items.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final item = controller.items[i];
            return ListTile(
              title: Text(item.name, style: AppTextStyles.body),
              subtitle: Text('${item.category ?? ''} · ${Formatters.currency(item.price)}',
                  style: AppTextStyles.caption),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: item.isAvailableToday,
                    onChanged: (_) => controller.toggleAvailability(item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: () => controller.deleteItem(item.id),
                  ),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          // TODO: open add-item bottom sheet
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Item', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
