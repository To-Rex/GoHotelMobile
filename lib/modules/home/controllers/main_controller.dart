import 'package:get/get.dart';
import 'home_controller.dart';

class MainController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
    if (index == 0) {
      Get.find<HomeController>().loadData();
    }
  }
}
