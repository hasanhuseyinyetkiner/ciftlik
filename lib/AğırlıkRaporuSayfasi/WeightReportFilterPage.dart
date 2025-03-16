import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'WeightReportController.dart';
import 'WeightReportFilterController.dart';

import '../FormFields/FormButton.dart';

class WeightReportFilterPage extends StatelessWidget {
  WeightReportFilterPage({super.key})
      : filterController = Get.put(WeightReportFilterController()),
        weightReportController = Get.put(WeightReportController());

  final WeightReportFilterController filterController;
  final WeightReportController weightReportController;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9, // Sabit yükseklik faktörü
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Divider
          Container(
            width: 30,
            height: 4.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade400,
                  width: 4.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Sol üstteki "Sıfırla" butonu
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: TextButton(
                    onPressed: () {
                      filterController.resetFilters(); // Filtreleri sıfırlar
                      weightReportController.resetReports();
                    },
                    child: const Text(
                      'Sıfırla',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                // Ortadaki "Filtreler" başlığı
                const Expanded(
                  child: Center(
                    child: Text(
                      'Filtreler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Sağ üstteki "Çıkış" butonu
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    // CheckboxListTile'ler
                    Obx(() {
                      return Column(
                        children: [
                          CheckboxListTile(
                            title: const Text('Genel Ağırlık Değişimi'),
                            value: filterController.selectedExaminations
                                .contains('Genel Ağırlık Değişimi'),
                            onChanged: (value) {
                              if (value == true) {
                                filterController.selectedExaminations
                                    .add('Genel Ağırlık Değişimi');
                              } else {
                                filterController.selectedExaminations
                                    .remove('Genel Ağırlık Değişimi');
                              }
                            },
                            activeColor: Colors.cyan.shade600,
                          ),
                          CheckboxListTile(
                            title: const Text('Son Ağırlık Değişimi'),
                            value: filterController.selectedExaminations
                                .contains('Son Ağırlık Değişimi'),
                            onChanged: (value) {
                              if (value == true) {
                                filterController.selectedExaminations
                                    .add('Son Ağırlık Değişimi');
                              } else {
                                filterController.selectedExaminations
                                    .remove('Son Ağırlık Değişimi');
                              }
                            },
                            activeColor: Colors.cyan.shade600,
                          ),
                          CheckboxListTile(
                            title:
                                const Text('Büyükten Küçüğe Ağırlık Değişimi'),
                            value: filterController.selectedExaminations
                                .contains('Büyükten Küçüğe Ağırlık Değişimi'),
                            onChanged: (value) {
                              if (value == true) {
                                filterController.selectedExaminations
                                    .add('Büyükten Küçüğe Ağırlık Değişimi');
                                filterController
                                        .isKucuktenBuyugeDisabled.value =
                                    true; // Küçükten Büyüğe inaktif yap
                              } else {
                                filterController.selectedExaminations
                                    .remove('Büyükten Küçüğe Ağırlık Değişimi');
                                filterController.isKucuktenBuyugeDisabled
                                    .value = false; // Küçükten Büyüğe aktif yap
                              }
                            },
                            activeColor: Colors.cyan.shade600,
                            enabled: !filterController
                                .isBuyuktenKucugeDisabled.value,
                          ),
                          CheckboxListTile(
                            title:
                                const Text('Küçükten Büyüğe Ağırlık Değişimi'),
                            value: filterController.selectedExaminations
                                .contains('Küçükten Büyüğe Ağırlık Değişimi'),
                            onChanged: (value) {
                              if (value == true) {
                                filterController.selectedExaminations
                                    .add('Küçükten Büyüğe Ağırlık Değişimi');
                                filterController
                                        .isBuyuktenKucugeDisabled.value =
                                    true; // Büyükten Küçüğe inaktif yap
                              } else {
                                filterController.selectedExaminations
                                    .remove('Küçükten Büyüğe Ağırlık Değişimi');
                                filterController.isBuyuktenKucugeDisabled
                                    .value = false; // Büyükten Küçüğe aktif yap
                              }
                            },
                            activeColor: Colors.cyan.shade600,
                            enabled: !filterController
                                .isKucuktenBuyugeDisabled.value,
                          ),
                        ],
                      );
                    }),
                    // Hayvan türleri CheckboxListTile
                    Obx(() {
                      return Column(
                        children: [
                          CheckboxListTile(
                            title: const Text('Kuzu'),
                            value: filterController.selectedAnimals
                                .contains('kuzu'),
                            onChanged: (value) {
                              if (value == true) {
                                filterController.selectedAnimals.add('kuzu');
                              } else {
                                filterController.selectedAnimals.remove('kuzu');
                              }
                            },
                            activeColor: Colors.cyan.shade600,
                          ),
                          CheckboxListTile(
                            title: const Text('Buzağı'),
                            value: filterController.selectedAnimals
                                .contains('buzağı'),
                            onChanged: (value) {
                              if (value == true) {
                                filterController.selectedAnimals.add('buzağı');
                              } else {
                                filterController.selectedAnimals
                                    .remove('buzağı');
                              }
                            },
                            activeColor: Colors.cyan.shade600,
                          ),
                          CheckboxListTile(
                            title: const Text('Koyun'),
                            value: filterController.selectedAnimals
                                .contains('koyun'),
                            onChanged: (value) {
                              if (value == true) {
                                filterController.selectedAnimals.add('koyun');
                              } else {
                                filterController.selectedAnimals
                                    .remove('koyun');
                              }
                            },
                            activeColor: Colors.cyan.shade600,
                          ),
                          CheckboxListTile(
                            title: const Text('Koç'),
                            value: filterController.selectedAnimals
                                .contains('koç'),
                            onChanged: (value) {
                              if (value == true) {
                                filterController.selectedAnimals.add('koç');
                              } else {
                                filterController.selectedAnimals.remove('koç');
                              }
                            },
                            activeColor: Colors.cyan.shade600,
                          ),
                          CheckboxListTile(
                            title: const Text('İnek'),
                            value: filterController.selectedAnimals
                                .contains('inek'),
                            onChanged: (value) {
                              if (value == true) {
                                filterController.selectedAnimals.add('inek');
                              } else {
                                filterController.selectedAnimals.remove('inek');
                              }
                            },
                            activeColor: Colors.cyan.shade600,
                          ),
                          CheckboxListTile(
                            title: const Text('Boğa'),
                            value: filterController.selectedAnimals
                                .contains('boğa'),
                            onChanged: (value) {
                              if (value == true) {
                                filterController.selectedAnimals.add('boğa');
                              } else {
                                filterController.selectedAnimals.remove('boğa');
                              }
                            },
                            activeColor: Colors.cyan.shade600,
                          ),
                          // Diğer hayvan türleri
                        ],
                      );
                    }),
                    const SizedBox(height: 10),
                    // Min ve Max Slider'lar
                    Obx(() {
                      return Column(
                        children: [
                          Text(
                              'Min Kg Değişimi: ${filterController.minWeight.value.toStringAsFixed(0)}'),
                          Slider(
                            inactiveColor: Colors.cyan.shade50,
                            activeColor: Colors.cyan.shade600,
                            value: filterController.minWeight.value,
                            min: -1000.0,
                            max: 1000.0,
                            divisions: 2000,
                            label: filterController.minWeight.value
                                .toStringAsFixed(0),
                            onChanged: (value) {
                              filterController.minWeight.value = value;
                            },
                          ),
                          const SizedBox(height: 10),
                          Text(
                              'Max Kg Değişimi: ${filterController.maxWeight.value.toStringAsFixed(0)}'),
                          Slider(
                            inactiveColor: Colors.cyan.shade50,
                            activeColor: Colors.cyan.shade600,
                            value: filterController.maxWeight.value,
                            min: 0.0,
                            max: 1000.0,
                            divisions: 1000,
                            label: filterController.maxWeight.value
                                .toStringAsFixed(0),
                            onChanged: (value) {
                              filterController.maxWeight.value = value;
                            },
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 10.0, left: 10, bottom: 20),
                      child: FormButton(
                        title: 'Filtreleri Uygula',
                        onPressed: () {
                          filterController.applyFilters(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
