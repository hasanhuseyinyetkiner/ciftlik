import 'package:flutter/material.dart';

/// Su Tüketimi Sayfası
/// Hayvanların su tüketiminin izlendiği ve yönetildiği sayfa
class SuTuketimiSayfasi extends StatefulWidget {
  const SuTuketimiSayfasi({Key? key}) : super(key: key);

  @override
  State<SuTuketimiSayfasi> createState() => _SuTuketimiSayfasiState();
}

class _SuTuketimiSayfasiState extends State<SuTuketimiSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Su Tüketimi Takibi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.water,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Su Tüketimi Takip Modülü',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Bu modül geliştirme aşamasındadır',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Geri Dön'),
            ),
          ],
        ),
      ),
    );
  }
}
