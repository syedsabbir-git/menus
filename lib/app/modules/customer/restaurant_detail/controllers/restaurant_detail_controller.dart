import 'package:get/get.dart';
import '../../../../data/models/menu_item_model.dart';
import '../../../../data/models/cart_item_model.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/repositories/menu_repo.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/error_handler.dart';

class RestaurantDetailController extends GetxController {
  late final RestaurantModel restaurant;

  List<MenuItemModel> menuItems = [];
  List<CartItemModel> cart = [];
  bool isLoading = true;

  final _repo = MenuRepo();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    restaurant = args is Map
        ? args['restaurant'] as RestaurantModel
        : args as RestaurantModel;
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    isLoading = true;
    update();
    try {
      menuItems = await _repo.fetchTodaysMenu(restaurant.id);
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isLoading = false;
      update();
    }
  }

  int quantityOf(MenuItemModel item) {
    return cart.firstWhereOrNull((c) => c.menuItem.id == item.id)?.quantity ?? 0;
  }

  void addToCart(MenuItemModel item) {
    final index = cart.indexWhere((c) => c.menuItem.id == item.id);
    if (index == -1) {
      cart.add(CartItemModel(menuItem: item));
    } else {
      cart[index].quantity++;
    }
    update();
  }

  void removeFromCart(MenuItemModel item) {
    final index = cart.indexWhere((c) => c.menuItem.id == item.id);
    if (index == -1) return;
    if (cart[index].quantity > 1) {
      cart[index].quantity--;
    } else {
      cart.removeAt(index);
    }
    update();
  }

  double get cartTotal => cart.fold(0, (sum, c) => sum + c.subtotal);
  int get cartCount => cart.fold(0, (sum, c) => sum + c.quantity);
}
