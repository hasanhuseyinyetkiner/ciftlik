import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ciftlik_yonetim/EklemeSayfalari/OlcumEkleme/OlcumController.dart';
import 'package:ciftlik_yonetim/FormUtils/FormUtils.dart';
import '../../FormFields/BuildSelectionField.dart';
import '../../FormFields/FormButton.dart';
import '../../FormFields/WeightField.dart';

class OlcumPage extends StatelessWidget {
  final OlcumController controller = Get.put(OlcumController());
  final FormUtils utils = FormUtils();

  OlcumPage({Key? key}) : super(key: key);

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
            controller.resetForm();
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Yapmak istediğiniz işlemi seçiniz.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const WeightField(),
              const SizedBox(height: 25),
              BuildSelectionField(
                label: 'İşlemi Seçiniz *',
                value: controller.selectedType,
                options: controller.types,
                onSelected: (value) {
                  controller.selectedType.value = value;
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 8, left: 8),
                child: FormButton(
                  title: 'Devam Et',
                  onPressed: () {
                    if (controller.formKey.currentState!.validate()) {
                      String? selectedType = controller.selectedType.value;
                      String? routeName;
                      if (selectedType != null) {
                        switch (selectedType) {
                          case 'Kuzu Ölçüm':
                            routeName = '/addBirthKuzuPage';
                            break;
                          case 'Buzağı Ölçüm':
                            routeName = '/addBirthBuzagiPage';
                            break;
                          case 'Koyun Ölçüm':
                            routeName = '/addSheepPage';
                            break;
                          case 'Koç Ölçüm':
                            routeName = '/addKocPage';
                            break;
                          case 'İnek Ölçüm':
                            routeName = '/addInekPage';
                            break;
                          case 'Boğa Ölçüm':
                            routeName = '/addBogaPage';
                            break;
                          case 'Koyun Süt Ölçüm':
                            routeName = '/koyunSutOlcumPage';
                            break;
                          case 'İnek Süt Ölçüm':
                            routeName = '/inekSutOlcumPage';
                            break;
                          case 'Sütten Kesilmiş Kuzu Ölçüm':
                            routeName = '/weanedKuzuOlcumPage';
                            break;
                          case 'Sütten Kesilmiş Buzağı Ölçüm':
                            routeName = '/weanedBuzagiOlcumPage';
                            break;
                          default:
                            routeName = null;
                            break;
                        }

                        if (routeName != null) {
                          Get.snackbar(
                            'Başarılı',
                            'Sayfaya yönlendiriliyorsunuz...',
                          );
                          Future.delayed(const Duration(seconds: 1), () {
                            Get.toNamed(routeName!);
                          });
                        }
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 8, left: 8),
                child: FormButton(
                  title: 'Ölçümü Başlat',
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
