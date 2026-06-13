import 'package:get/get.dart';
import '../../../../data/models/menu_item_model.dart';
import '../../../../data/models/cart_item_model.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/repositories/menu_repo.dart';
import '../../../../core/utils/helpers.dart';

class RestaurantDetailController extends GetxController {
  late final RestaurantModel restaurant;

  final menuItems = <MenuItemModel>[].obs;
  final cart = <CartItemModel>[].obs;
  final isLoading = true.obs;

  final _repo = MenuRepo();

  @override
  void onInit() {
    super.onInit();
    restaurant = Get.arguments as RestaurantModel;
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    isLoading.value = true;
    try {
      menuItems.value = await _repo.fetchTodaysMenu(restaurant.id);
    } catch (e) {
      showSnackBar(message: 'Failed to load menu.', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  int quantityOf(MenuItemModel item) {
    final found = cart.firstWhereOrNull((c) => c.menuItem.id == item.id);
    return found?.quantity ?? 0;
  }

  void addToCart(MenuItemModel item) {
    final index = cart.indexWhere((c) => c.menuItem.id == item.id);
    if (index == -1) {
      cart.add(CartItemModel(menuItem: item));
    } else {
      cart[index].quantity++;
      cart.refresh();
    }
  }

  void removeFromCart(MenuItemModel item) {
    final index = cart.indexWhere((c) => c.menuItem.id == item.id);
    if (index == -1) return;
    if (cart[index].quantity > 1) {
      cart[index].quantity--;
      cart.refresh();
    } else {
      cart.removeAt(index);
    }
  }

  double get cartTotal => cart.fold(0, (sum, c) => sum + c.subtotal);
  int get cartCount => cart.fold(0, (sum, c) => sum + c.quantity);
}
