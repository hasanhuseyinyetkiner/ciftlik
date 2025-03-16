import 'package:get/get.dart';
import 'DatabaseAddAnimalWeightHelper.dart';

class AnimalWeightController extends GetxController {
  var weights = <Weight>[].obs;

  void fetchWeightsByAnimalId(int animalId) async {
    var weightData = await DatabaseAddAnimalWeightHelper.instance.getWeightsByAnimalId(animalId);
    if (weightData.isNotEmpty) {
      weights.assignAll(weightData.map((data) => Weight.fromMap(data)).toList());
    } else {
      weights.clear();
    }
  }

  void removeWeight(int id) async {
    await DatabaseAddAnimalWeightHelper.instance.deleteWeight(id);
    var removedWeight = weights.firstWhereOrNull((weight) => weight.id == id);
    if (removedWeight != null) {
      fetchWeightsByAnimalId(removedWeight.animalId);
      Get.snackbar('Başarılı', 'Ağırlık kaydı silindi');
    }
  }
  Stream<Map<String, dynamic>> getAnimalWeightDetails(int animalId) async* {
    while (true) {
      // SQL sorgusunu çalıştırarak sonucu alıyoruz
      final result = await DatabaseAddAnimalWeightHelper.instance.getAnimalWeightDetails(animalId);
      if (result != null) {
        yield result;
      }
      await Future.delayed(const Duration(seconds: 2)); // 2 saniyelik gecikme
    }
  }

  void addWeight(Weight weight) {
    weights.add(weight);
  }
}

class Weight {
  final int id;
  final double weight;
  final int animalId;
  final String date;

  Weight({
    required this.id,
    required this.weight,
    required this.animalId,
    required this.date,
  });

  factory Weight.fromMap(Map<String, dynamic> map) {
    return Weight(
      id: map['id'],
      weight: map['weight'],
      animalId: map['animalid'],
      date: map['date'],
    );
  }
}
