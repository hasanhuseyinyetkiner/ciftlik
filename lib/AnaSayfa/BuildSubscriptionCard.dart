import 'package:flutter/material.dart';

/*
* BuildSubscriptionCard - Abonelik Kartı Widget'ı
* -----------------------------------------
* Bu widget, kullanıcının abonelik durumunu ve
* mevcut paket bilgilerini gösteren kartı oluşturur.
*
* Kart Bileşenleri:
* 1. Abonelik Bilgileri:
*    - Paket adı
*    - Kalan süre
*    - Fiyat bilgisi
*    - Durum göstergesi
*
* 2. Özellik Listesi:
*    - Aktif özellikler
*    - Kullanım limitleri
*    - Ek hizmetler
*    - Premium avantajlar

*/

class BuildSubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final int color_a;
  const BuildSubscriptionCard(
      {super.key,
      required this.title,
      required this.price,
      required this.color_a});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Padding(
        padding: const EdgeInsets.only(right: 4.0, left: 4, top: 8),
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(color_a).withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  Text(price, style: const TextStyle(color: Colors.blue)),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(color_a)),
                    onPressed: () {},
                    child: const Text(
                      'Abone Ol',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
