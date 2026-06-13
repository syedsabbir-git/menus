import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_vendors_controller.dart';
import '../../../../../app/core/widgets/app_text_field.dart';
import '../../../../../app/core/widgets/primary_button.dart';
import '../../../../../app/core/theme/app_colors.dart';
import '../../../../../app/core/theme/app_text_styles.dart';
import '../../../../../app/core/theme/app_dimensions.dart';
import '../../../../../app/core/utils/validators.dart';
import '../../../../../app/data/models/restaurant_model.dart';
import '../../../../../app/data/models/user_model.dart';

class RestaurantFormSheet extends StatefulWidget {
  const RestaurantFormSheet({super.key, this.restaurant});

  final RestaurantModel? restaurant;

  static Future<void> show({RestaurantModel? restaurant}) {
    return Get.bottomSheet(
      RestaurantFormSheet(restaurant: restaurant),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<RestaurantFormSheet> createState() => _RestaurantFormSheetState();
}

class _RestaurantFormSheetState extends State<RestaurantFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  UserModel? _selectedVendor;
  bool _isSaving = false;

  bool get _isEdit => widget.restaurant != null;
  AdminVendorsController get _ctrl => Get.find<AdminVendorsController>();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.restaurant?.name ?? '');
    _description =
        TextEditingController(text: widget.restaurant?.description ?? '');
    if (widget.restaurant?.ownerId != null) {
      _selectedVendor = _ctrl.vendorUsers.firstWhereOrNull(
        (u) => u.id == widget.restaurant!.ownerId,
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final data = <String, dynamic>{
      'name': _name.text.trim(),
      'description':
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      'is_open': widget.restaurant?.isOpen ?? false,
      if (_selectedVendor != null) 'owner_id': _selectedVendor!.id,
    };

    if (_isEdit) {
      await _ctrl.updateRestaurant(widget.restaurant!.id, data);
    } else {
      await _ctrl.createRestaurant(data);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final vendors = _ctrl.vendorUsers;

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
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              _isEdit ? 'Edit Restaurant' : 'Add Restaurant',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppDimensions.md),
            AppTextField(
              label: 'Restaurant Name *',
              hint: 'e.g. Campus Bistro',
              controller: _name,
              validator: (v) => Validators.required(v, fieldName: 'Name'),
            ),
            const SizedBox(height: AppDimensions.sm),
            AppTextField(
              label: 'Description',
              hint: 'Short description (optional)',
              controller: _description,
              maxLines: 2,
            ),
            const SizedBox(height: AppDimensions.sm),
            if (vendors.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
                child: Text(
                  'No vendor accounts yet. Vendor registers first, then assign here.',
                  style: AppTextStyles.caption,
                ),
              )
            else
              DropdownButtonFormField<UserModel?>(
                initialValue: _selectedVendor,
                decoration: const InputDecoration(
                  labelText: 'Assign Vendor (optional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('— Unassigned —'),
                  ),
                  ...vendors.map(
                    (u) => DropdownMenuItem(
                      value: u,
                      child: Text(
                        u.fullName.isNotEmpty ? u.fullName : u.email,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedVendor = v),
              ),
            const SizedBox(height: AppDimensions.md),
            PrimaryButton(
              label: _isEdit ? 'Update' : 'Create Restaurant',
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
