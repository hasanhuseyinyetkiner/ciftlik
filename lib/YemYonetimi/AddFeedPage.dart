import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../FormFields/BuildNumberField.dart'; // Import BuildNumberField
import '../FormFields/BuildTextField.dart'; // Import BuildTextField
import '../FormFields/FormButton.dart'; // Import FormButton
import '../FormFields/BuildSelectionField.dart'; // Import BuildSelectionField
import 'AddFeedController.dart'; // Import AddFeedController
import 'FeedController.dart';

class AddFeedPage extends StatelessWidget {
  AddFeedPage({super.key})
      : controller = Get.put(AddFeedController()),
        feedController = Get.find();

  final AddFeedController controller;
  final FeedController feedController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 60.0),
            child: Container(
              height: 40,
              width: 130,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('resimler/Merlab.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                BuildTextField(
                  label: 'Yeni Yem Adı *',
                  hint: '',
                  controller: controller.yemAdiController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BuildNumberField(
                  label: 'Kuru Madde (%) *',
                  hint: '',
                  controller: controller.kuruMaddeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BuildNumberField(
                  label: 'UFL (kg başına) *',
                  hint: '',
                  controller: controller.uflController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BuildNumberField(
                  label: 'Metabolizable Enerji, ME (kcal/kg) *',
                  hint: '',
                  controller: controller.meController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BuildNumberField(
                  label: 'PDI (g/kg) *',
                  hint: '',
                  controller: controller.pdiController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BuildNumberField(
                  label: 'Ham Protein CP (%) *',
                  hint: '',
                  controller: controller.hamProteinController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BuildNumberField(
                  label: 'Lizin (%/PDI) *',
                  hint: '',
                  controller: controller.lizinController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BuildNumberField(
                  label: 'Metionin (%/PDI) *',
                  hint: '',
                  controller: controller.metioninController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BuildNumberField(
                  label: 'Kalsiyum abs (g/kg) *',
                  hint: '',
                  controller: controller.kalsiyumController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BuildNumberField(
                  label: 'Fosfor abs (g/kg) *',
                  hint: '',
                  controller: controller.fosforController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BuildNumberField(
                  label: 'Alt Limit (kg) *',
                  hint: '',
                  controller: controller.altLimitController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BuildNumberField(
                  label: 'Üst Limit (kg) *',
                  hint: '',
                  controller: controller.ustLimitController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                BuildTextField(
                  label: 'Notlar',
                  hint: '',
                  controller: controller.notlarController,
                  // Eğer "Notlar" alanı opsiyonel olacaksa validator'u kaldırın:
                  // validator: (value) => null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan boş bırakılamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Obx(
                  () => BuildSelectionField(
                    label: 'Tür',
                    value: controller.selectedTur,
                    options: const ['Kaba Yem', 'Konsantre Yem', 'Diğer'],
                    onSelected: (value) {
                      controller.selectedTur.value = value;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FormButton(
                      title: 'Ekle',
                      onPressed: () async {
                        if (controller.formKey.currentState!.validate()) {
                          await controller.saveFeedStock();
                          await feedController.fetchFeedStocks();
                          Get.back();
                          Get.snackbar('Başarılı', 'Yem Stoğu Eklendi');
                        } else {
                          Get.snackbar(
                            'Hata',
                            'Lütfen tüm alanları doldurunuz',
                            colorText: Colors.black,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
