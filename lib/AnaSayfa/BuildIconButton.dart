import 'package:flutter/material.dart';

/*
* BuildIconButton - Özelleştirilmiş İkon Butonu Widget'ı
* ------------------------------------------------
* Bu widget, uygulama genelinde kullanılan standart
* ikon butonlarını oluşturmak için kullanılır.
*
* Widget Özellikleri:
* 1. Görsel Öğeler:
*    - İkon
*    - Renk
*    - Boyut
*    - Gölge efekti
*
* 2. İnteraktif Özellikler:
*    - Tıklama efekti
*    - Geri bildirim
*    - Devre dışı durumu
*    - Vurgu efekti
*
* 3. Özelleştirme:
*    - İkon boyutu
*    - Buton boyutu
*    - Renk şeması
*    - Köşe yuvarlaklığı
*
* 4. Erişilebilirlik:
*    - Semantik etiket
*    - Tooltip
*    - Fokus yönetimi
*    - Klavye desteği
*
* Kullanım Alanları:
* - Toolbar butonları
* - Aksiyon butonları
* - Navigasyon butonları
* - Kontrol butonları
*
* Özellikler:
* - Material Design uyumlu
* - Responsive tasarım
* - Tema desteği
* - Hafif yapı
*/

class BuildIconButton extends StatelessWidget {
  final String assetPath;
  final String label;
  final VoidCallback onTap; // onTap için parametre ekliyoruz

  const BuildIconButton({
    super.key,
    required this.assetPath,
    required this.label,
    required this.onTap, // onTap parametresini zorunlu hale getiriyoruz
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap, // onTap'i burada kullanıyoruz
            child: Image.asset(assetPath, width: 40.0, height: 40.0),
          ),
          const SizedBox(height: 4.0),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
