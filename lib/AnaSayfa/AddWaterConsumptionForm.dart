import 'package:flutter/material.dart';

class AddWaterConsumptionForm extends StatelessWidget {
  const AddWaterConsumptionForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Su Tüketimi Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Hayvan Grubu/Ahır'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Ölçüm Tarihi'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Tüketim Miktarı'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Birim'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Notlar'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Kaydı eklemek için gerekli işlemler burada yapılacak.
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
