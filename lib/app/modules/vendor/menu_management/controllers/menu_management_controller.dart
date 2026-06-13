import 'package:get/get.dart';
import '../../../../data/models/menu_item_model.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/repositories/menu_repo.dart';

class MenuManagementController extends GetxController {
  late final RestaurantModel restaurant;
  final items = <MenuItemModel>[].obs;
  final isLoading = true.obs;

  final _repo = MenuRepo();

  @override
  void onInit() {
    super.onInit();
    restaurant = Get.arguments as RestaurantModel;
    fetchItems();
  }

  Future<void> fetchItems() async {
    isLoading.value = true;
    try {
      items.value = await _repo.fetchAllByRestaurant(restaurant.id);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleAvailability(MenuItemModel item) async {
    await _repo.toggleAvailability(item.id, !item.isAvailableToday);
    fetchItems();
  }

  Future<void> deleteItem(String id) async {
    await _repo.deleteItem(id);
    items.removeWhere((i) => i.id == id);
  }
}
