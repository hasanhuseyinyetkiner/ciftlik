import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'DatabaseFeedStockHelper.dart';

class FeedDetailEditController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // TextEditingController'lar
  var yemAdiController = TextEditingController();
  var kuruMaddeController = TextEditingController();
  var uflController = TextEditingController();
  var meController = TextEditingController();
  var pdiController = TextEditingController();
  var hamProteinController = TextEditingController();
  var lizinController = TextEditingController();
  var metioninController = TextEditingController();
  var kalsiyumController = TextEditingController();
  var fosforController = TextEditingController();
  var altLimitController = TextEditingController();
  var ustLimitController = TextEditingController();
  var notlarController = TextEditingController();

  // Rx değişkenler (Seçim alanları için)
  var selectedTur = Rxn<String>();

  void loadFeedDetails(int feedId) async {
    var details = await DatabaseFeedStockHelper.instance.getFeedStockById(feedId);
    if (details != null) {
      yemAdiController.text = details['feedName'] ?? '';
      kuruMaddeController.text = details['kuruMadde'].toString();
      uflController.text = details['ufl'].toString();
      meController.text = details['me'].toString();
      pdiController.text = details['pdi'].toString();
      hamProteinController.text = details['hamProtein'].toString();
      lizinController.text = details['lizin'].toString();
      metioninController.text = details['metionin'].toString();
      kalsiyumController.text = details['kalsiyum'].toString();
      fosforController.text = details['fosfor'].toString();
      altLimitController.text = details['altLimit'].toString();
      ustLimitController.text = details['ustLimit'].toString();
      notlarController.text = details['notlar'] ?? '';
      selectedTur.value = details['tur'] ?? '';
    }
  }

  void updateFeedDetails(int feedId) async {
    if (formKey.currentState!.validate()) {
      var updatedDetails = {
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
      await DatabaseFeedStockHelper.instance.updateFeedStock(feedId, updatedDetails);
    }
  }
}
