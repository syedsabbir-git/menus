import 'package:get/get.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/repositories/restaurant_repo.dart';
import '../../../../data/services/storage_service.dart';

class VendorDashboardController extends GetxController {
  final restaurant = Rxn<RestaurantModel>();
  final isLoading = true.obs;

  final _repo = RestaurantRepo();

  @override
  void onReady() {
    super.onReady();
    fetchRestaurant();
  }

  Future<void> fetchRestaurant() async {
    isLoading.value = true;
    try {
      final userId = StorageService.to.userId!;
      restaurant.value = await _repo.fetchByOwnerId(userId);
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleOpen() async {
    if (restaurant.value == null) return;
    final newStatus = !restaurant.value!.isOpen;
    await _repo.updateOpenStatus(restaurant.value!.id, newStatus);
    await fetchRestaurant();
  }
}
