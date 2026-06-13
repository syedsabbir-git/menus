import 'package:get/get.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/repositories/restaurant_repo.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/helpers.dart';

class CustomerHomeController extends GetxController {
  List<RestaurantModel> restaurants = [];
  bool isLoading = true;
  String errorMessage = '';

  final _repo = RestaurantRepo();

  @override
  void onReady() {
    super.onReady();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    isLoading = true;
    errorMessage = '';
    update();
    try {
      restaurants = await _repo.fetchAll();
    } catch (e) {
      errorMessage = ErrorHandler.parse(e);
      AppSnackBar.error(errorMessage);
    } finally {
      isLoading = false;
      update();
    }
  }
}
