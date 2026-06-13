import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_orders_controller.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/enums/order_status.dart';

class CustomerOrdersView extends GetView<CustomerOrdersController> {
  const CustomerOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: Obx(() {
        if (controller.isLoading.value) return const AppLoader();
        if (controller.orders.isEmpty) {
          return const EmptyState(message: 'No orders yet.', icon: Icons.receipt_long_outlined);
        }
        return RefreshIndicator(
          onRefresh: controller.fetchOrders,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final order = controller.orders[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text('Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: AppTextStyles.h3),
                  subtitle: Text(
                    '${Formatters.dateTime(order.createdAt)}\n${order.deliveryAddress}',
                    style: AppTextStyles.caption,
                  ),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(Formatters.currency(order.total),
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(order.status.label, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
