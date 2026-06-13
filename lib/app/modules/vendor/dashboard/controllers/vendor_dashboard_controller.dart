import 'package:get/get.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/repositories/restaurant_repo.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/error_handler.dart';

class VendorDashboardController extends GetxController {
  RestaurantModel? restaurant;
  bool isLoading = true;
  bool isToggling = false;

  final _repo = RestaurantRepo();

  @override
  void onReady() {
    super.onReady();
    fetchRestaurant();
  }

  Future<void> fetchRestaurant() async {
    isLoading = true;
    update();
    try {
      final userId = StorageService.to.userId!;
      restaurant = await _repo.fetchByOwnerId(userId);
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> toggleOpen() async {
    if (restaurant == null || isToggling) return;
    isToggling = true;
    update();
    try {
      final newStatus = !restaurant!.isOpen;
      await _repo.updateOpenStatus(restaurant!.id, newStatus);
      await fetchRestaurant();
      AppSnackBar.success(
        newStatus ? 'Restaurant is now open.' : 'Restaurant is now closed.',
      );
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isToggling = false;
      update();
    }
  }
}
