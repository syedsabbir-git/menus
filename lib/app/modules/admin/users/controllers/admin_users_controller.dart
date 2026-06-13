import 'package:get/get.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/auth_repo.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/error_handler.dart';

class AdminUsersController extends GetxController {
  List<UserModel> users = [];
  bool isLoading = true;
  String searchQuery = '';

  final _repo = AuthRepo();

  @override
  void onReady() {
    super.onReady();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading = true;
    update();
    try {
      final data = await _repo.fetchAllProfiles();
      users = data.map((m) => UserModel.fromMap(m)).toList();
    } catch (e) {
      AppSnackBar.error(ErrorHandler.parse(e));
    } finally {
      isLoading = false;
      update();
    }
  }

  void onSearchChanged(String q) {
    searchQuery = q;
    update();
  }

  List<UserModel> get filtered {
    final q = searchQuery.toLowerCase();
    if (q.isEmpty) return users;
    return users
        .where((u) =>
            u.fullName.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.role.contains(q))
        .toList();
  }
}
