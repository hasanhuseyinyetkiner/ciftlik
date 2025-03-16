import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'DatabaseFeedStockHelper.dart';

class AddFeedController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final TextEditingController yemAdiController = TextEditingController();
  final TextEditingController kuruMaddeController = TextEditingController();
  final TextEditingController uflController = TextEditingController();
  final TextEditingController meController = TextEditingController();
  final TextEditingController pdiController = TextEditingController();
  final TextEditingController hamProteinController = TextEditingController();
  final TextEditingController lizinController = TextEditingController();
  final TextEditingController metioninController = TextEditingController();
  final TextEditingController kalsiyumController = TextEditingController();
  final TextEditingController fosforController = TextEditingController();
  final TextEditingController altLimitController = TextEditingController();
  final TextEditingController ustLimitController = TextEditingController();
  final TextEditingController notlarController = TextEditingController();

  final Rxn<String> selectedTur = Rxn<String>();

  Future<void> saveFeedStock() async {
    if (formKey.currentState!.validate()) {
      Map<String, dynamic> feedData = {
        'feedName': yemAdiController.text,
        'kuruMadde': double.tryParse(kuruMaddeController.text) ?? 0.0,
        'ufl': double.tryParse(uflController.text) ?? 0.0,
        'me': double.tryParse(meController.text) ?? 0.0,
        'pdi': double.tryParse(pdiController.text) ?? 0.0,
        'hamProtein': double.tryParse(hamProteinController.text) ?? 0.0,
        'lizin': double.tryParse(lizinController.text) ?? 0.0,
        'metionin': double.tryParse(metioninController.text) ?? 0.0,
        'kalsiyum': double.tryParse(kalsiyumController.text) ?? 0.0,
        'fosfor': double.tryParse(fosforController.text) ?? 0.0,
        'altLimit': double.tryParse(altLimitController.text) ?? 0.0,
        'ustLimit': double.tryParse(ustLimitController.text) ?? 0.0,
        'notlar': notlarController.text,
        'tur': selectedTur.value,
      };
      int result =
          await DatabaseFeedStockHelper.instance.insertFeedStock(feedData);
      if (result != 0) {
        print('Ekleme başarılı, ID: $result');
      } else {
        print('Ekleme başarısız');
      }
      Get.back(result: true);
      Get.snackbar('Başarılı', 'Yem Stoğu Eklendi');
    }
  }

  @override
  void onClose() {
    yemAdiController.dispose();
    kuruMaddeController.dispose();
    uflController.dispose();
    meController.dispose();
    pdiController.dispose();
    hamProteinController.dispose();
    lizinController.dispose();
    metioninController.dispose();
    kalsiyumController.dispose();
    fosforController.dispose();
    altLimitController.dispose();
    ustLimitController.dispose();
    notlarController.dispose();
    super.onClose();
  }
}
