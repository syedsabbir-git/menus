import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/daily_menu_post_model.dart';
import '../../../../data/models/menu_item_model.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/repositories/menu_post_repo.dart';
import '../../../../data/repositories/menu_repo.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/error_handler.dart';

class PostMenuController extends GetxController {
  late final RestaurantModel restaurant;

  List<MenuItemModel> allItems = [];
  Set<String> selectedItemIds = {};
  MealType selectedMealType = MealType.dinner;
  final deliveryWindowController = TextEditingController();
  final noteController = TextEditingController();

  bool isLoadingItems = true;
  bool isPosting = false;

  final _menuRepo = MenuRepo();
  final _postRepo = MenuPostRepo();

  @override
  void onInit() {
    super.onInit();
    restaurant = Get.arguments as RestaurantModel;
    _loadItems();
  }

  @override
  void onClose() {
    deliveryWindowController.dispose();
    noteController.dispose();
    super.onClose();
  }

  Future<void> _loadItems() async {
    isLoadingItems = true;
    update();
    try {
      allItems = await _menuRepo.fetchAllByRestaurant(restaurant.id);
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isLoadingItems = false;
      update();
    }
  }

  void setMealType(MealType type) {
    selectedMealType = type;
    update();
  }

  void toggleItem(String itemId) {
    if (selectedItemIds.contains(itemId)) {
      selectedItemIds.remove(itemId);
    } else {
      selectedItemIds.add(itemId);
    }
    update();
  }

  bool isSelected(String itemId) => selectedItemIds.contains(itemId);

  Future<void> postMenu() async {
    if (selectedItemIds.isEmpty) {
      AppSnackBar.error('Select at least one menu item.');
      return;
    }

    isPosting = true;
    update();

    try {
      await _postRepo.createPost(
        restaurantId: restaurant.id,
        mealType: selectedMealType,
        menuItemIds: selectedItemIds.toList(),
        deliveryWindow: deliveryWindowController.text.trim().isEmpty
            ? null
            : deliveryWindowController.text.trim(),
        note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
      );
      AppSnackBar.success('Menu posted! Customers will be notified.');
      Get.back();
    } catch (e, st) {
      // ignore: avoid_print
      print('[POST MENU ERROR] $e\n$st');
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isPosting = false;
      update();
    }
  }
}
