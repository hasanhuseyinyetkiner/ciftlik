import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'AnimalWeightController.dart';

class AnimalWeightDetailCard extends StatelessWidget {
  final int animalId;
  final AnimalWeightController controller = Get.put(AnimalWeightController());

  AnimalWeightDetailCard({Key? key, required this.animalId}) : super(key: key);

  Widget formatData(dynamic value, String label, String suffix, {bool isPercentageOrKg = false}) {
    if (value == null || value.toString().contains("gerekli") || value.toString().contains("bulunamadı")) {
      return Text(value.toString());
    } else {
      // Eğer `isPercentageOrKg` true ise, pozitif ve negatif durumlara göre renk ayarla
      Color textColor = Colors.black;
      if (isPercentageOrKg && (value is double || value is int)) {
        textColor = value >= 0 ? Colors.green.shade700 : Colors.red;
      }

      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(color: Colors.black), // Varsayılan metin rengi
            ),
            TextSpan(
              text: value.toString(),
              style: TextStyle(color: textColor), // Sayı için renk
            ),
            TextSpan(
              text: ' $suffix',
              style: TextStyle(color: textColor), // Suffix için de aynı renk
            ),
          ],
        ),
        softWrap: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 2.0,
      shadowColor: Colors.cyan,
      margin: const EdgeInsets.only(bottom: 10.0, right: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: controller.getAnimalWeightDetails(animalId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              ); // Bekleme sırasında gösterilecek widget
            }
            if (snapshot.hasError) {
              return const Text('Veriler yüklenirken bir hata oluştu');
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Text('Veri bulunamadı'); // Veri yoksa gösterilecek widget
            }

            var data = snapshot.data as Map<String, dynamic>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.label_outline_rounded, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Küpe No: ${data['tagNo']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        softWrap: true, // Metnin sarılmasını sağlar
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.scale, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: formatData(data['weight_diff'], 'Son Ağırlık Değişimi', 'kg', isPercentageOrKg: true),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: formatData(data['weight_percentage_change'], 'Son Ağırlık Değişimi Yüzdesi', '%', isPercentageOrKg: true),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: formatData(data['date_difference'], 'Gün Farkı', 'gün'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
