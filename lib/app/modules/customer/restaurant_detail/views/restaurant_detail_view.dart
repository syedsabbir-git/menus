import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/restaurant_detail_controller.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routes/app_routes.dart';

class RestaurantDetailView extends GetView<RestaurantDetailController> {
  const RestaurantDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text(controller.restaurant.name))),
      body: Obx(() {
        if (controller.isLoading.value) return const AppLoader();
        if (controller.menuItems.isEmpty) {
          return const EmptyState(
            message: "No items available today.",
            icon: Icons.no_meals_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: controller.menuItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final item = controller.menuItems[i];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: AppTextStyles.h3),
                          if (item.description != null) ...[
                            const SizedBox(height: 4),
                            Text(item.description!, style: AppTextStyles.bodySecondary),
                          ],
                          const SizedBox(height: 8),
                          Text(Formatters.currency(item.price),
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ),
                    Obx(() {
                      final qty = controller.quantityOf(item);
                      return qty == 0
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(80, 36),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () => controller.addToCart(item),
                              child: const Text('Add'),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => controller.removeFromCart(item),
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: AppColors.primary),
                                ),
                                Text('$qty', style: AppTextStyles.h3),
                                IconButton(
                                  onPressed: () => controller.addToCart(item),
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: AppColors.primary),
                                ),
                              ],
                            );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.cartCount == 0) return const SizedBox.shrink();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => Get.toNamed(Routes.CART, arguments: controller),
              child: Text(
                '${controller.cartCount} items · ${Formatters.currency(controller.cartTotal)}  →  View Cart',
              ),
            ),
          ),
        );
      }),
    );
  }
}
