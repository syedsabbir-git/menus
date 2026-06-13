import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_home_controller.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../routes/app_routes.dart';

class CustomerHomeView extends GetView<CustomerHomeController> {
  const CustomerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<CustomerHomeController>(
        builder: (_) {
          return RefreshIndicator(
            onRefresh: controller.fetchRestaurants,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _Header(topPad: topPad)),
                const SliverToBoxAdapter(child: _SearchBar()),
                const SliverToBoxAdapter(child: _CategoryRow()),
                _RestaurantSectionHeader(
                  count: controller.restaurants.length,
                  isLoading: controller.isLoading,
                ),
                if (controller.isLoading)
                  const SliverFillRemaining(child: AppLoader())
                else if (controller.restaurants.isEmpty)
                  const SliverFillRemaining(child: _EmptyRestaurants())
                else
                  _RestaurantGrid(restaurants: controller.restaurants),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.topPad});
  final double topPad;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.fromLTRB(
          AppDimensions.md, topPad + AppDimensions.sm, AppDimensions.md, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 4),
                    Text('Campus Delivery',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(_greeting, style: AppTextStyles.h2),
                Text('What would you like to eat?',
                    style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant_menu,
                color: AppColors.primary, size: 22),
          ),
        ],
      ),
    );
  }
}

// ─── Search Bar ────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppDimensions.md, AppDimensions.md, AppDimensions.md, AppDimensions.sm),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
                color: AppColors.divider.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: AppDimensions.sm),
              Text('Search restaurants or dishes...',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textHint)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Category Row ──────────────────────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  static const _cats = [
    ('🍛', 'Rice'),
    ('🍗', 'Chicken'),
    ('🍔', 'Burgers'),
    ('🥗', 'Salads'),
    ('🥤', 'Drinks'),
    ('🍰', 'Desserts'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
        itemCount: _cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.sm),
        itemBuilder: (_, i) {
          final (emoji, label) = _cats[i];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(height: 4),
              Text(label,
                  style: AppTextStyles.caption
                      .copyWith(fontWeight: FontWeight.w500)),
            ],
          );
        },
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────
class _RestaurantSectionHeader extends StatelessWidget {
  const _RestaurantSectionHeader(
      {required this.count, required this.isLoading});
  final int count;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppDimensions.md, AppDimensions.sm, AppDimensions.md, AppDimensions.sm),
        child: Row(
          children: [
            Text('Restaurants', style: AppTextStyles.h3),
            const Spacer(),
            if (!isLoading && count > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text('$count open',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Restaurant Grid ───────────────────────────────────────────────────────
class _RestaurantGrid extends StatelessWidget {
  const _RestaurantGrid({required this.restaurants});
  final List<RestaurantModel> restaurants;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppDimensions.md,
          crossAxisSpacing: AppDimensions.md,
          childAspectRatio: 0.82,
        ),
        itemCount: restaurants.length,
        itemBuilder: (_, i) =>
            _RestaurantCard(restaurant: restaurants[i], index: i),
      ),
    );
  }
}

// ─── Restaurant Card ───────────────────────────────────────────────────────
class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant, required this.index});
  final RestaurantModel restaurant;
  final int index;

  static const _palette = [
    Color(0xFFFF6B35),
    Color(0xFF2EC4B6),
    Color(0xFF7C3AED),
    Color(0xFF059669),
    Color(0xFF2563EB),
    Color(0xFFDC2626),
  ];

  static const _emojis = ['🍛', '🍗', '🍔', '🥗', '🍕', '🥡', '🍰', '🍜'];

  Color get _color => _palette[index % _palette.length];
  String get _emoji => _emojis[index % _emojis.length];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: restaurant.isOpen
          ? () => Get.toNamed(Routes.RESTAURANT_DETAIL,
              arguments: {'restaurant': restaurant, 'colorIndex': index})
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient color
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _color,
                        _color.withValues(alpha: 0.75),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern circles
                      Positioned(
                        right: -16,
                        top: -16,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: -20,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      // Open/closed badge
                      Positioned(
                        top: AppDimensions.sm,
                        right: AppDimensions.sm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: restaurant.isOpen
                                ? Colors.white.withValues(alpha: 0.95)
                                : Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: restaurant.isOpen
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                restaurant.isOpen ? 'Open' : 'Closed',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: restaurant.isOpen
                                      ? AppColors.success
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Emoji
                      Center(
                        child: Text(_emoji,
                            style: const TextStyle(fontSize: 44)),
                      ),
                    ],
                  ),
                ),
              ),
              // Info section
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        restaurant.description?.isNotEmpty == true
                            ? restaurant.description!
                            : 'Campus restaurant',
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.delivery_dining,
                              size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text('Delivery',
                              style: AppTextStyles.caption
                                  .copyWith(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────
class _EmptyRestaurants extends StatelessWidget {
  const _EmptyRestaurants();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('No restaurants open yet', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text('Check back soon!', style: AppTextStyles.bodySecondary),
        ],
      ),
    );
  }
}
