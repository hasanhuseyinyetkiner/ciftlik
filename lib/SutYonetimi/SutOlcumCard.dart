import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'SutOlcumController.dart';

/*
* SutOlcumCard - Süt Ölçüm Kartı Widget'ı
* ----------------------------------
* Bu widget, süt ölçüm kayıtlarını görüntülemek için
* kullanılan kart bileşenini oluşturur.
*
* Kart Bileşenleri:
* 1. Temel Bilgiler:
*    - Hayvan bilgisi
*    - Ölçüm tarihi
*    - Miktar
*    - Birim
*
* 2. Kalite Göstergeleri:
*    - Yağ oranı
*    - Protein oranı
*    - Kalite sınıfı
*    - Durum ikonu
*
* 3. İnteraktif Öğeler:
*    - Detay görüntüleme
*    - Düzenleme butonu
*    - Silme butonu
*    - Hızlı işlemler
*
* 4. Görsel Özellikler:
*    - Renk kodlaması
*    - İkon setleri
*    - Gölge efekti
*    - Animasyonlar
*
* Kullanım:
* - Liste görünümü
* - Grid görünümü
* - Dashboard widget'ı
* - Özet kartı
*
* Özellikler:
* - Material Design
* - Responsive tasarım
* - Tema desteği
* - Özelleştirilebilir yapı
*/

/// Süt ölçüm kartı widget'ı
/// Bu widget, bir süt ölçüm kaydını kart şeklinde gösterir ve silme işlemi için kaydırma özelliği sunar
class SutOlcumCard extends StatelessWidget {
  final Map<String, dynamic> sutOlcum;
  final String tableName;

  const SutOlcumCard(
      {Key? key, required this.sutOlcum, required this.tableName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SutOlcumController controller = Get.find();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Image.asset(
                'icons/milk_bucket_icon_black.png',
                width: 55,
                height: 55,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Küpe No: ${sutOlcum['type']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4.0),
                  Text('Ağırlık: ${sutOlcum['weight']} kg'),
                  const SizedBox(height: 4.0),
                  Text('Tarih: ${sutOlcum['date']}'),
                  const SizedBox(height: 4.0),
                  Text('Saat: ${sutOlcum['time']}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
