import 'package:get/get.dart';
class DrawerMenuController extends GetxController {
  var isExpanded = false.obs;
  void toggleExpanded() {
    isExpanded.value = !isExpanded.value;
  }

  void logout() {
    Get.offAllNamed('/login');
  }

  void navigateTo(String routeName) {
    Get.toNamed(routeName);
  }
}
