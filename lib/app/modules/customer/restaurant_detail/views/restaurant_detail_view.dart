import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/restaurant_detail_controller.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../data/models/menu_item_model.dart';
import '../../../../routes/app_routes.dart';

class RestaurantDetailView extends GetView<RestaurantDetailController> {
  const RestaurantDetailView({super.key});

  static const _palette = [
    Color(0xFFFF6B35),
    Color(0xFF2EC4B6),
    Color(0xFF7C3AED),
    Color(0xFF059669),
    Color(0xFF2563EB),
    Color(0xFFDC2626),
  ];

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map?;
    final colorIndex = (args?['colorIndex'] as int?) ?? 0;
    final headerColor = _palette[colorIndex % _palette.length];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: GetBuilder<RestaurantDetailController>(
          builder: (_) {
            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    _RestaurantHeader(
                      restaurant: controller.restaurant,
                      color: headerColor,
                    ),
                    if (controller.isLoading)
                      const SliverFillRemaining(child: AppLoader())
                    else if (controller.menuItems.isEmpty)
                      SliverFillRemaining(
                        child: _EmptyMenu(color: headerColor),
                      )
                    else ...[
                      _MenuContent(controller: controller),
                    ],
                    // Bottom padding for cart bar
                    const SliverToBoxAdapter(
                        child: SizedBox(height: 100)),
                  ],
                ),
                // Floating cart bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _CartBar(
                      controller: controller, color: headerColor),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Restaurant SliverAppBar Header ────────────────────────────────────────
class _RestaurantHeader extends StatelessWidget {
  const _RestaurantHeader(
      {required this.restaurant, required this.color});

  final dynamic restaurant; // RestaurantModel
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: color,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: _HeaderBackground(restaurant: restaurant, color: color),
        collapseMode: CollapseMode.parallax,
      ),
      title: Text(
        restaurant.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground({required this.restaurant, required this.color});
  final dynamic restaurant;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.8)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Content
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppDimensions.md, 0, AppDimensions.md, AppDimensions.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Open/closed badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: restaurant.isOpen
                            ? AppColors.success.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                        border: Border.all(
                          color: restaurant.isOpen
                              ? AppColors.success
                              : Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: restaurant.isOpen
                                  ? AppColors.success
                                  : Colors.white54,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            restaurant.isOpen ? 'Open Now' : 'Closed',
                            style: TextStyle(
                              color: restaurant.isOpen
                                  ? AppColors.success
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (restaurant.description != null &&
                        restaurant.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        restaurant.description!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Info chips
                    Row(
                      children: [
                        _InfoChip(
                            icon: Icons.delivery_dining_outlined,
                            label: 'Delivery'),
                        const SizedBox(width: AppDimensions.sm),
                        _InfoChip(
                            icon: Icons.access_time_outlined,
                            label: '20–35 min'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Menu Content ──────────────────────────────────────────────────────────
class _MenuContent extends StatelessWidget {
  const _MenuContent({required this.controller});
  final RestaurantDetailController controller;

  @override
  Widget build(BuildContext context) {
    // Group items by category
    final grouped = <String, List<MenuItemModel>>{};
    for (final item in controller.menuItems) {
      final cat = (item.category?.isNotEmpty == true)
          ? item.category!
          : 'Menu';
      grouped.putIfAbsent(cat, () => []).add(item);
    }

    final slivers = <Widget>[];
    grouped.forEach((category, items) {
      // Category header
      slivers.add(SliverToBoxAdapter(
        child: _CategoryHeader(title: category),
      ));
      // Items
      slivers.add(SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(
            height: 1, indent: AppDimensions.md, endIndent: AppDimensions.md),
        itemBuilder: (_, i) => _MenuItem(
          item: items[i],
          controller: controller,
        ),
      ));
    });

    return MultiSliver(slivers: slivers);
  }
}

class MultiSliver extends StatelessWidget {
  const MultiSliver({super.key, required this.slivers});
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: slivers);
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.4),
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md, vertical: 10),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─── Menu Item ─────────────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.item, required this.controller});
  final MenuItemModel item;
  final RestaurantDetailController controller;

  @override
  Widget build(BuildContext context) {
    final qty = controller.quantityOf(item);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md, vertical: AppDimensions.sm + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        border: Border.all(color: AppColors.success, width: 1.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Center(
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: AppTextStyles.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '৳ ${item.price.toStringAsFixed(item.price % 1 == 0 ? 0 : 2)}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          // Right: image placeholder + counter
          Column(
            children: [
              Container(
                width: 90,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Center(
                  child: Text(
                    _itemEmoji(item),
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              qty == 0
                  ? _AddButton(onTap: () => controller.addToCart(item))
                  : _Stepper(
                      qty: qty,
                      onAdd: () => controller.addToCart(item),
                      onRemove: () => controller.removeFromCart(item),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  String _itemEmoji(MenuItemModel item) {
    final lower = item.name.toLowerCase();
    if (lower.contains('biriyani') || lower.contains('rice')) return '🍛';
    if (lower.contains('chicken')) return '🍗';
    if (lower.contains('burger')) return '🍔';
    if (lower.contains('pizza')) return '🍕';
    if (lower.contains('salad')) return '🥗';
    if (lower.contains('drink') || lower.contains('juice')) return '🥤';
    if (lower.contains('coffee')) return '☕';
    if (lower.contains('noodle') || lower.contains('pasta')) return '🍝';
    if (lower.contains('fish')) return '🐟';
    if (lower.contains('soup')) return '🍜';
    if (lower.contains('cake') || lower.contains('dessert')) return '🍰';
    return '🍽️';
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          color: AppColors.primary.withValues(alpha: 0.06),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.primary, size: 16),
            const SizedBox(width: 3),
            Text('ADD',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.qty, required this.onAdd, required this.onRemove});
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          _StepBtn(icon: Icons.remove, onTap: onRemove),
          Expanded(
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          _StepBtn(icon: Icons.add, onTap: onAdd),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

// ─── Cart Bar ──────────────────────────────────────────────────────────────
class _CartBar extends StatelessWidget {
  const _CartBar({required this.controller, required this.color});
  final RestaurantDetailController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final count = controller.cartCount;
    if (count == 0) return const SizedBox.shrink();

    final bottomPad = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.CART, arguments: controller),
      child: Container(
        margin: EdgeInsets.fromLTRB(
            AppDimensions.md, 0, AppDimensions.md, AppDimensions.md + bottomPad),
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Text(
                '$count ${count == 1 ? 'item' : 'items'}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            const Expanded(
              child: Text(
                'View Cart',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
              ),
            ),
            Text(
              '৳ ${controller.cartTotal.toStringAsFixed(controller.cartTotal % 1 == 0 ? 0 : 2)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 13),
          ],
        ),
      ),
    );
  }
}

// ─── Empty Menu ────────────────────────────────────────────────────────────
class _EmptyMenu extends StatelessWidget {
  const _EmptyMenu({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
                child: Text('🍽️', style: TextStyle(fontSize: 48))),
          ),
          const SizedBox(height: 16),
          Text('No items today', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text('Check back later for today\'s menu.',
              style: AppTextStyles.bodySecondary),
        ],
      ),
    );
  }
}
