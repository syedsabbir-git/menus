import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../data/models/daily_menu_post_model.dart';
import '../../../../data/models/menu_item_model.dart';
import '../controllers/post_menu_controller.dart';

class PostMenuView extends GetView<PostMenuController> {
  const PostMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Today\'s Menu')),
      body: GetBuilder<PostMenuController>(
        builder: (_) {
          if (controller.isLoadingItems) return const AppLoader();
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  children: [
                    _MealTypeSelector(controller: controller),
                    const SizedBox(height: AppDimensions.lg),
                    _SectionTitle(title: 'Select Items'),
                    const SizedBox(height: AppDimensions.sm),
                    if (controller.allItems.isEmpty)
                      _EmptyItems()
                    else
                      ...controller.allItems.map(
                        (item) => _ItemTile(item: item, controller: controller),
                      ),
                    const SizedBox(height: AppDimensions.lg),
                    _SectionTitle(title: 'Delivery Window (optional)'),
                    const SizedBox(height: AppDimensions.sm),
                    TextField(
                      controller: controller.deliveryWindowController,
                      decoration: InputDecoration(
                        hintText: 'e.g.  7:00 PM – 9:00 PM',
                        prefixIcon: const Icon(Icons.access_time_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                    _SectionTitle(title: 'Note (optional)'),
                    const SizedBox(height: AppDimensions.sm),
                    TextField(
                      controller: controller.noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Any special note for today…',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xl),
                  ],
                ),
              ),
              _PostButton(controller: controller),
            ],
          );
        },
      ),
    );
  }
}

// ── Meal type chips ───────────────────────────────────────────────────────────
class _MealTypeSelector extends StatelessWidget {
  const _MealTypeSelector({required this.controller});
  final PostMenuController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Meal Type'),
        const SizedBox(height: AppDimensions.sm),
        Row(
          children: MealType.values.map((type) {
            final selected = controller.selectedMealType == type;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: AppDimensions.sm),
                child: GestureDetector(
                  onTap: () => controller.setMealType(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(type.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(
                          type.label,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Item tile ─────────────────────────────────────────────────────────────────
class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item, required this.controller});
  final MenuItemModel item;
  final PostMenuController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.isSelected(item.id);
    return GestureDetector(
      onTap: () => controller.toggleItem(item.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: AppDimensions.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.divider,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600)),
                  if (item.category != null)
                    Text(item.category!, style: AppTextStyles.caption),
                ],
              ),
            ),
            Text(
              '৳${item.price.toStringAsFixed(0)}',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Post button ───────────────────────────────────────────────────────────────
class _PostButton extends StatelessWidget {
  const _PostButton({required this.controller});
  final PostMenuController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedItemIds.length;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.md,
          AppDimensions.sm,
          AppDimensions.md,
          AppDimensions.md,
        ),
        child: PrimaryButton(
          label: controller.isPosting
              ? 'Posting…'
              : selected == 0
                  ? 'Post Menu'
                  : 'Post Menu ($selected item${selected > 1 ? 's' : ''})',
          isLoading: controller.isPosting,
          onPressed: controller.isPosting ? null : controller.postMenu,
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.h3);
  }
}

class _EmptyItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
      child: Center(
        child: Text(
          'No menu items yet. Add items in Manage Menu first.',
          style: AppTextStyles.bodySecondary,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
