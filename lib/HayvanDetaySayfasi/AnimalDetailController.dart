import 'package:get/get.dart';
import 'DatabaseAnimalDetailHelper.dart';

class AnimalDetailController extends GetxController {
  var animalDetails = <String, dynamic>{}.obs;

  void fetchAnimalDetails(String tableName, int animalId) async {
    var details = await DatabaseAnimalDetailHelper.instance.getAnimalDetails(tableName, animalId);
    if (details != null) {
      animalDetails.value = details;
    } else {
      animalDetails.value = {};
    }
  }
}
