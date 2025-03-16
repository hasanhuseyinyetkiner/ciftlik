import 'package:flutter/material.dart';

/// Rasyon Hesaplama Sayfası
/// Hayvanlar için rasyon hesaplama ve besin değeri analizi yapmak için kullanılır
class RasyonHesaplamaSayfasi extends StatefulWidget {
  const RasyonHesaplamaSayfasi({Key? key}) : super(key: key);

  @override
  State<RasyonHesaplamaSayfasi> createState() => _RasyonHesaplamaSayfasiState();
}

class _RasyonHesaplamaSayfasiState extends State<RasyonHesaplamaSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rasyon Hesaplama'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calculate,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Rasyon Hesaplama Modülü',
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
