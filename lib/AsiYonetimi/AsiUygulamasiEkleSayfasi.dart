import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'AsiUygulamasiController.dart';

class AsiUygulamasiEkleSayfasi extends StatelessWidget {
  final AsiUygulamasiController controller = Get.find<AsiUygulamasiController>();

  AsiUygulamasiEkleSayfasi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aşı Uygulaması Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hayvan seçimi
            const Text(
              'Hayvan Seçimi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Hayvan Seçiniz',
                border: OutlineInputBorder(),
              ),
              value: controller.selectedHayvan,
              items: controller.hayvanlar.map((hayvan) {
                return DropdownMenuItem<String>(
                  value: hayvan,
                  child: Text(hayvan),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedHayvan = value;
                }
              },
            ),
            const SizedBox(height: 16),

            // Aşı seçimi
            const Text(
              'Aşı Bilgileri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Aşı Seçiniz',
                border: OutlineInputBorder(),
              ),
              value: controller.selectedAsi,
              items: controller.asilar.map((asi) {
                return DropdownMenuItem<String>(
                  value: asi,
                  child: Text(asi),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedAsi = value;
                  controller.updateAsiId(value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Uygulama yolu
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Uygulama Yolu',
                border: OutlineInputBorder(),
              ),
              value: controller.uygulamaYoluSecimi,
              items: controller.uygulamaYollari.map((yol) {
                return DropdownMenuItem<String>(
                  value: yol,
                  child: Text(yol),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.uygulamaYoluSecimi = value;
                }
              },
            ),
            const SizedBox(height: 16),

            // Tarih seçimi
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedAsiTarihi ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        controller.setSelectedAsiTarihi(picked);
                        controller.updateSonrakiAsiTarihi();
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Aşı Tarihi',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        controller.selectedAsiTarihi != null
                            ? DateFormat('dd/MM/yyyy').format(controller.selectedAsiTarihi!)
                            : 'Tarih Seçiniz',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedSonrakiAsiTarihi ?? DateTime.now().add(const Duration(days: 90)),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        controller.setSelectedSonrakiAsiTarihi(picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Sonraki Aşı Tarihi',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        controller.selectedSonrakiAsiTarihi != null
                            ? DateFormat('dd/MM/yyyy').format(controller.selectedSonrakiAsiTarihi!)
                            : 'Otomatik Hesaplanır',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Veteriner hekim
            TextField(
              controller: controller.veterinerHekimController,
              decoration: const InputDecoration(
                labelText: 'Veteriner Hekim',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Uygulama bölgesi
            TextField(
              controller: controller.uygulamaBolgesiController,
              decoration: const InputDecoration(
                labelText: 'Uygulama Bölgesi',
                border: OutlineInputBorder(),
                hintText: 'Örn: Boyun, Kas içi, vb.',
              ),
            ),
            const SizedBox(height: 16),

            // Yan etkiler
            TextField(
              controller: controller.yanEtkilerController,
              decoration: const InputDecoration(
                labelText: 'Gözlemlenen Yan Etkiler',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Notlar
            TextField(
              controller: controller.notlarController,
              decoration: const InputDecoration(
                labelText: 'Notlar',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Kaydet butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.validateForm()) {
                    controller.saveAsiUygulamasi();
                    Get.back();
                  } else {
                    Get.snackbar(
                      'Hata',
                      'Lütfen gerekli alanları doldurunuz',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                child: const Text('Aşı Uygulamasını Kaydet'),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
