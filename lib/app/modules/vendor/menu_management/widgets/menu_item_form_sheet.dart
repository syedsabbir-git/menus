import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/menu_management_controller.dart';
import '../../../../../app/core/widgets/app_text_field.dart';
import '../../../../../app/core/widgets/primary_button.dart';
import '../../../../../app/core/theme/app_colors.dart';
import '../../../../../app/core/theme/app_text_styles.dart';
import '../../../../../app/core/theme/app_dimensions.dart';
import '../../../../../app/core/utils/validators.dart';
import '../../../../../app/data/models/menu_item_model.dart';

class MenuItemFormSheet extends StatefulWidget {
  const MenuItemFormSheet({super.key, this.item});

  /// null = add mode, non-null = edit mode
  final MenuItemModel? item;

  static Future<void> show({MenuItemModel? item}) {
    return Get.bottomSheet(
      MenuItemFormSheet(item: item),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<MenuItemFormSheet> createState() => _MenuItemFormSheetState();
}

class _MenuItemFormSheetState extends State<MenuItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _category;
  late bool _availableToday;
  bool _isSaving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item?.name ?? '');
    _description = TextEditingController(text: widget.item?.description ?? '');
    _price = TextEditingController(
        text: widget.item != null ? widget.item!.price.toStringAsFixed(2) : '');
    _category = TextEditingController(text: widget.item?.category ?? '');
    _availableToday = widget.item?.isAvailableToday ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final ctrl = Get.find<MenuManagementController>();
    final data = {
      if (_isEdit) 'id': widget.item!.id,
      'restaurant_id': ctrl.restaurant.id,
      'name': _name.text.trim(),
      'description': _description.text.trim().isEmpty ? null : _description.text.trim(),
      'price': double.parse(_price.text.trim()),
      'category': _category.text.trim().isEmpty ? null : _category.text.trim(),
      'is_available_today': _availableToday,
    };

    final ok = await ctrl.saveItem(data);
    if (ok && mounted) Get.back();
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.md,
        AppDimensions.md,
        AppDimensions.md,
        AppDimensions.md + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              _isEdit ? 'Edit Menu Item' : 'Add Menu Item',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppDimensions.md),
            AppTextField(
              hint: 'e.g. Chicken Biriyani',
              label: 'Item Name *',
              controller: _name,
              validator: (v) => Validators.required(v, fieldName: 'Item name'),
            ),
            const SizedBox(height: AppDimensions.sm),
            AppTextField(
              hint: 'Short description (optional)',
              label: 'Description',
              controller: _description,
              maxLines: 2,
            ),
            const SizedBox(height: AppDimensions.sm),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    hint: '0.00',
                    label: 'Price (৳) *',
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Price is required';
                      if (double.tryParse(v.trim()) == null) return 'Enter a valid price';
                      if (double.parse(v.trim()) < 0) return 'Price must be positive';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: AppTextField(
                    hint: 'e.g. Rice, Snacks',
                    label: 'Category',
                    controller: _category,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            StatefulBuilder(
              builder: (_, setLocal) => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Available Today', style: AppTextStyles.body),
                subtitle: Text(
                  'Toggle off to hide from today\'s menu',
                  style: AppTextStyles.caption,
                ),
                value: _availableToday,
                onChanged: (v) {
                  setLocal(() => _availableToday = v);
                },
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            PrimaryButton(
              label: _isEdit ? 'Update Item' : 'Add Item',
              isLoading: _isSaving,
              onPressed: _save,
            ),
            const SizedBox(height: AppDimensions.sm),
          ],
        ),
      ),
    );
  }
}
