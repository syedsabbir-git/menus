import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../routes/app_routes.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Obx(() {
        final items = controller.items;
        if (items.isEmpty) {
          return const Center(child: Text('Your cart is empty'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) {
            final c = items[i];
            return ListTile(
              title: Text(c.menuItem.name, style: AppTextStyles.body),
              subtitle: Text(Formatters.currency(c.menuItem.price), style: AppTextStyles.caption),
              trailing: Text('x${c.quantity}  ${Formatters.currency(c.subtotal)}',
                  style: AppTextStyles.body.copyWith(color: AppColors.primary)),
            );
          },
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() => ElevatedButton(
                onPressed: () => Get.toNamed(Routes.CHECKOUT, arguments: controller),
                child: Text('Proceed to Checkout · ${Formatters.currency(controller.total)}'),
              )),
        ),
      ),
    );
  }
}
