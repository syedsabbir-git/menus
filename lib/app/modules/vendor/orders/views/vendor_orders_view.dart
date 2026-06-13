import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vendor_orders_controller.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/enums/order_status.dart';
import '../../../../data/models/order_model.dart';

class VendorOrdersView extends GetView<VendorOrdersController> {
  const VendorOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Orders'),
        actions: [
          GetBuilder<VendorOrdersController>(
            builder: (_) => IconButton(
              icon: Icon(controller.newestFirst
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded),
              tooltip: controller.newestFirst ? 'Newest first' : 'Oldest first',
              onPressed: controller.isLoading ? null : controller.toggleSort,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(controller: controller),
          Expanded(
            child: GetBuilder<VendorOrdersController>(
              builder: (_) {
                if (controller.isLoading) return const AppLoader();
                if (controller.orders.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: controller.statusFilter == null
                        ? 'No orders yet.'
                        : 'No ${_statusLabel(controller.statusFilter!).toLowerCase()} orders.',
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchOrders,
                  child: ListView.separated(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.md,
                      AppDimensions.sm,
                      AppDimensions.md,
                      AppDimensions.xl,
                    ),
                    itemCount: controller.orders.length + 1,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppDimensions.sm),
                    itemBuilder: (context, i) {
                      if (i == controller.orders.length) {
                        return _ListFooter(
                          isLoadingMore: controller.isLoadingMore,
                          hasMore: controller.hasMore,
                        );
                      }
                      return _OrderCard(
                        order: controller.orders[i],
                        onAccept: () =>
                            controller.acceptOrder(controller.orders[i].id),
                        onReject: () =>
                            _showRejectSheet(context, controller.orders[i].id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectSheet(BuildContext context, String orderId) {
    final reasonCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.lg,
          AppDimensions.lg,
          AppDimensions.lg,
          MediaQuery.of(ctx).viewInsets.bottom + AppDimensions.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reject order?', style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.xs),
            Text(
              'Optionally let the customer know why.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppDimensions.md),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: FilledButton(
                    style:
                        FilledButton.styleFrom(backgroundColor: AppColors.error),
                    onPressed: () {
                      Navigator.pop(ctx);
                      controller.rejectOrder(
                        orderId,
                        reason: reasonCtrl.text.trim().isEmpty
                            ? null
                            : reasonCtrl.text.trim(),
                      );
                    },
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Accepted';
      case OrderStatus.cancelled:
        return 'Rejected';
      default:
        return s.label;
    }
  }
}

// ---------------------------------------------------------------------------

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller});
  final VendorOrdersController controller;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VendorOrdersController>(
      builder: (_) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        child: Row(
          children: [
            _chip(context, label: 'All', value: null),
            const SizedBox(width: AppDimensions.xs),
            _chip(context, label: 'Pending', value: OrderStatus.pending),
            const SizedBox(width: AppDimensions.xs),
            _chip(context, label: 'Accepted', value: OrderStatus.confirmed),
            const SizedBox(width: AppDimensions.xs),
            _chip(context, label: 'Rejected', value: OrderStatus.cancelled),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required OrderStatus? value,
  }) {
    final selected = controller.statusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => controller.setStatusFilter(value),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.caption.copyWith(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onAccept,
    required this.onReject,
  });

  final OrderModel order;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final isPending = order.status == OrderStatus.pending;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: BorderSide(
          color: _statusColor(order.status).withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: ID + total + status badge
            Row(
              children: [
                Text(
                  '#${order.id.substring(0, 8).toUpperCase()}',
                  style: AppTextStyles.h3,
                ),
                const Spacer(),
                Text(
                  Formatters.currency(order.total),
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: AppDimensions.sm),
                _StatusBadge(status: order.status),
              ],
            ),

            const SizedBox(height: AppDimensions.sm),
            const Divider(height: 1),
            const SizedBox(height: AppDimensions.sm),

            // Customer info
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: AppDimensions.iconSm,
                    color: AppColors.textSecondary),
                const SizedBox(width: AppDimensions.xs),
                Expanded(
                  child: Text(
                    order.customerName ?? 'Unknown customer',
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                if (order.customerPhone != null &&
                    order.customerPhone!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: AppDimensions.iconSm,
                          color: AppColors.textSecondary),
                      const SizedBox(width: AppDimensions.xs),
                      Text(order.customerPhone!,
                          style: AppTextStyles.bodySecondary),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: AppDimensions.xs),

            // Delivery address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: AppDimensions.iconSm,
                    color: AppColors.textSecondary),
                const SizedBox(width: AppDimensions.xs),
                Expanded(
                  child: Text(order.deliveryAddress,
                      style: AppTextStyles.bodySecondary),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.xs),

            // Timestamp
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: AppDimensions.iconSm,
                    color: AppColors.textSecondary),
                const SizedBox(width: AppDimensions.xs),
                Text(
                  Formatters.dateTime(order.createdAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),

            // Order items
            if (order.items.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.sm),
              const Divider(height: 1),
              const SizedBox(height: AppDimensions.sm),
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Items ordered',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        )),
                    const SizedBox(height: AppDimensions.xs),
                    ...order.items.map(
                      (item) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppDimensions.xs),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.menuItemName ?? 'Item'} × ${item.quantity}',
                                style: AppTextStyles.body,
                              ),
                            ),
                            Text(
                              Formatters.currency(item.subtotal),
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Rejection reason (if present)
            if (order.rejectionReason != null &&
                order.rejectionReason!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: AppDimensions.iconSm, color: AppColors.error),
                  const SizedBox(width: AppDimensions.xs),
                  Expanded(
                    child: Text(
                      'Reason: ${order.rejectionReason}',
                      style:
                          AppTextStyles.caption.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],

            // Accept / Reject buttons (pending only)
            if (isPending) ...[
              const SizedBox(height: AppDimensions.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      onPressed: onReject,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Accept'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                      onPressed: onAccept,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      OrderStatus.pending => ('Pending', AppColors.warning),
      OrderStatus.confirmed => ('Accepted', AppColors.success),
      OrderStatus.cancelled => ('Rejected', AppColors.error),
      _ => (status.label, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.isLoadingMore, required this.hasMore});
  final bool isLoadingMore;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
        child: Center(
          child: Text('All orders loaded', style: AppTextStyles.caption),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
