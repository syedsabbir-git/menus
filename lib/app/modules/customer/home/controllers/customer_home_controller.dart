import 'package:get/get.dart';
import '../../../../data/models/daily_menu_post_model.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/repositories/menu_post_repo.dart';
import '../../../../data/repositories/restaurant_repo.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/helpers.dart';

class CustomerHomeController extends GetxController {
  List<RestaurantModel> restaurants = [];
  List<DailyMenuPost> todaysPosts = [];
  bool isLoading = true;
  String errorMessage = '';

  final _repo = RestaurantRepo();
  final _postRepo = MenuPostRepo();

  @override
  void onReady() {
    super.onReady();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading = true;
    errorMessage = '';
    update();
    try {
      final results = await Future.wait([
        _repo.fetchAll(),
        _postRepo.fetchAllTodaysPosts(),
      ]);
      restaurants = results[0] as List<RestaurantModel>;
      todaysPosts = results[1] as List<DailyMenuPost>;
    } catch (e) {
      errorMessage = ErrorHandler.parse(e);
      AppSnackBar.error(errorMessage);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> fetchRestaurants() => fetchAll();
}
