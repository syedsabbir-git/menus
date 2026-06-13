import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_orders_controller.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/enums/order_status.dart';

class VendorOrdersView extends GetView<VendorOrdersController> {
  const VendorOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Orders')),
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('#${order.id.substring(0, 8).toUpperCase()}',
                              style: AppTextStyles.h3),
                          Text(Formatters.currency(order.total),
                              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(order.deliveryAddress, style: AppTextStyles.bodySecondary),
                      Text(Formatters.dateTime(order.createdAt), style: AppTextStyles.caption),
                      const SizedBox(height: 12),
                      DropdownButton<OrderStatus>(
                        value: order.status,
                        isExpanded: true,
                        items: OrderStatus.values
                            .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                            .toList(),
                        onChanged: (s) {
                          if (s != null) controller.updateStatus(order.id, s);
                        },
                      ),
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
