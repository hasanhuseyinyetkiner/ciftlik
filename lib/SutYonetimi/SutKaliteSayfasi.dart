import 'package:flutter/material.dart';

/// Süt Kalitesi Sayfası
/// Süt kalitesi analizlerinin yapıldığı ve raporlandığı sayfa
class SutKaliteSayfasi extends StatefulWidget {
  const SutKaliteSayfasi({Key? key}) : super(key: key);

  @override
  State<SutKaliteSayfasi> createState() => _SutKaliteSayfasiState();
}

class _SutKaliteSayfasiState extends State<SutKaliteSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Süt Kalitesi Analizi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.science,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Süt Kalite Analiz Modülü',
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
