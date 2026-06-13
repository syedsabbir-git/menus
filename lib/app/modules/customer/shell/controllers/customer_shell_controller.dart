import 'package:get/get.dart';

class CustomerShellController extends GetxController {
  int selectedIndex = 0;

  void changeTab(int index) {
    selectedIndex = index;
    update();
  }
}
