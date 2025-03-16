import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../HayvanAgirlikSayfasi/AnimalWeightPage.dart';
import '../HayvanAgirlikSayfasi/DatabaseAddAnimalWeightHelper.dart';
import '../HayvanAsiSayfasi/AnimalVaccinePage.dart';
import '../HayvanGebelikKontrolSayfasi/PregnancyCheckPage.dart';
import '../HayvanGrupSayfasi/AnimalGroupPage.dart';
import '../HayvanHastalikSayfasi/AnimalDiseasePage.dart';
import '../HayvanKonumSayfasi/AnimalLocationPage.dart';
import '../HayvanMuayeneSayfasi/AnimalExaminationPage.dart';
import '../HayvanNotSayfasi/AnimalNotePage.dart';
import 'ActionCard.dart';
import 'AnimalDetailController.dart';

class ActionsGrid extends StatelessWidget {
  ActionsGrid({super.key}) : controller = Get.put(AnimalDetailController());

  final AnimalDetailController controller;

  // Veriyi geciktirerek döndüren bir stream oluşturuyoruz
  Stream<double?> getLastWeightStream(int animalId) async* {
    while (true) {
      Map<String, dynamic>? lastWeightRecord =
          await DatabaseAddAnimalWeightHelper.instance
              .getLastWeightByAnimalId(animalId);

      if (lastWeightRecord != null) {
        yield lastWeightRecord[
            'weight']; // Son alınan ağırlık verisini döndürüyoruz
      } else {
        yield 0.0; // Veri yoksa sıfır olarak döndürüyoruz
      }

      await Future.delayed(const Duration(seconds: 2)); // 2 saniyelik gecikme
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 2 / 2.5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        ActionCard(
          title: 'Laktasyon',
          assetPath: 'icons/sheep_with_vaccine_icon_black.png',
          subtitle: 'Lak.no: 1\nGün: 0',
          onTap: () {
            print('Laktasyon tapped');
          },
        ),
        ActionCard(
          title: 'Tohumlama',
          assetPath: 'icons/sheep_with_vaccine_icon_black.png',
          onTap: () {
            print('Tohumlama tapped');
          },
        ),
        ActionCard(
          title: 'Gebelik Kontrolü',
          assetPath: 'icons/cow_with_magnifying_glass_icon.png',
          onTap: () {
            Get.to(
                () => PregnancyCheckPage(
                    tagNo: controller.animalDetails['tagNo'] ?? ''),
                duration: const Duration(milliseconds: 650));
          },
        ),
        StreamBuilder<double?>(
          stream: getLastWeightStream(controller.animalDetails['id'] ?? 0),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Yalnızca ağırlık için yükleniyor göstergesi
            } else if (snapshot.hasError) {
              return Text('Hata: ${snapshot.error}');
            } else {
              final lastWeight = snapshot.data;

              // Ağırlık verisi yoksa Son Ağırlık Bulunamadı mesajını göster
              if (lastWeight == null || lastWeight == 0.0) {
                return ActionCard(
                  title: 'Son Ağırlık Bulunamadı',
                  assetPath: 'icons/scale_icon_black.png',
                  onTap: () {
                    int animalId = controller.animalDetails['id'] ?? 0;
                    if (animalId != 0) {
                      Get.to(() => AnimalWeightPage(animalId: animalId),
                          duration: const Duration(milliseconds: 650));
                    } else {
                      Get.snackbar('Hata', 'Animal ID bulunamadı.');
                    }
                  },
                );
              } else {
                return ActionCard(
                  title: 'Son Ağırlık: ${lastWeight.toStringAsFixed(2)} kg',
                  assetPath: 'icons/scale_icon_black.png',
                  onTap: () {
                    int animalId = controller.animalDetails['id'] ?? 0;
                    if (animalId != 0) {
                      Get.to(() => AnimalWeightPage(animalId: animalId),
                          duration: const Duration(milliseconds: 650));
                    } else {
                      Get.snackbar('Hata', 'Animal ID bulunamadı.');
                    }
                  },
                );
              }
            }
          },
        ),
        ActionCard(
          title: 'Hastalık',
          assetPath: 'icons/sheep_with_illness_icon_black.png',
          onTap: () {
            Get.to(
                () => AnimalDiseasePage(
                    tagNo: controller.animalDetails['tagNo'] ?? ''),
                duration: const Duration(milliseconds: 650));
          },
        ),
        ActionCard(
          title: 'Kuruda',
          assetPath: 'icons/sheep_with_vaccine_icon_black.png',
          onTap: () {
            print('Kuruda tapped');
          },
        ),
        ActionCard(
          title: 'Muayene',
          assetPath: 'icons/stethoscope_icon_black.png',
          onTap: () {
            Get.to(
                () => AnimalExaminationPage(
                    tagNo: controller.animalDetails['tagNo'] ?? ''),
                duration: const Duration(milliseconds: 650));
          },
        ),
        ActionCard(
          title: 'Aşılama',
          assetPath: 'icons/vaccine_syringe_icon_black.png',
          onTap: () {
            Get.to(
                () => AnimalVaccinePage(
                    tagNo: controller.animalDetails['tagNo'] ?? ''),
                duration: const Duration(milliseconds: 650));
          },
        ),
        ActionCard(
          title: 'Doğum Ekle',
          assetPath: 'icons/sheep_with_lamb_and_plus_icon_black.png',
          onTap: () {
            print('Doğum Ekle tapped');
          },
        ),
        ActionCard(
          title: 'Lokasyon',
          assetPath: 'icons/barn_with_location_icon_black.png',
          onTap: () {
            Get.to(
                () => AnimalLocationPage(
                    tagNo: controller.animalDetails['tagNo'] ?? ''),
                duration: const Duration(milliseconds: 650));
          },
        ),
        ActionCard(
          title: 'Grup',
          assetPath: 'icons/sheep_and_cow_side_by_side_icon.png',
          onTap: () {
            Get.to(
                () => AnimalGroupPage(
                    tagNo: controller.animalDetails['tagNo'] ?? ''),
                duration: const Duration(milliseconds: 650));
          },
        ),
        ActionCard(
          title: 'Notlar',
          assetPath: 'icons/notes_icon_black.png',
          onTap: () {
            Get.to(
                () => AnimalNotePage(
                    tagNo: controller.animalDetails['tagNo'] ?? ''),
                duration: const Duration(milliseconds: 650));
          },
        ),
      ],
    );
  }
}
