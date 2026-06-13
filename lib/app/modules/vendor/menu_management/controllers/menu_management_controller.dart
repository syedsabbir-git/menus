import 'package:get/get.dart';
import '../../../../data/models/menu_item_model.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/repositories/menu_repo.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/error_handler.dart';

class MenuManagementController extends GetxController {
  late final RestaurantModel restaurant;
  List<MenuItemModel> items = [];
  bool isLoading = true;

  final _repo = MenuRepo();

  @override
  void onInit() {
    super.onInit();
    restaurant = Get.arguments as RestaurantModel;
    fetchItems();
  }

  Future<void> fetchItems() async {
    isLoading = true;
    update();
    try {
      items = await _repo.fetchAllByRestaurant(restaurant.id);
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<bool> saveItem(Map<String, dynamic> data) async {
    try {
      await _repo.upsertItem(data);
      await fetchItems();
      AppSnackBar.success(data.containsKey('id') ? 'Item updated.' : 'Item added.');
      return true;
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
      return false;
    }
  }

  Future<void> toggleAvailability(MenuItemModel item) async {
    try {
      await _repo.toggleAvailability(item.id, !item.isAvailableToday);
      fetchItems();
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _repo.deleteItem(id);
      items.removeWhere((i) => i.id == id);
      update();
      AppSnackBar.success('Item removed.');
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    }
  }
}
