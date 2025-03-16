import 'package:flutter/material.dart';

class WaterConsumptionDetailPage extends StatelessWidget {
  final String recordId;

  const WaterConsumptionDetailPage({Key? key, required this.recordId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Su Tüketimi Detayı'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Detaylar burada gösterilecek.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Kaydı düzenlemek için gerekli işlemler burada yapılacak.
              },
              child: const Text('Düzenle'),
            ),
            ElevatedButton(
              onPressed: () {
                // Kaydı silmek için gerekli işlemler burada yapılacak.
              },
              child: const Text('Sil'),
            ),
          ],
        ),
      ),
    );
  }
}
