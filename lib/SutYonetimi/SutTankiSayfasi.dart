import 'package:flutter/material.dart';

/// Süt Tankı Yönetim Sayfası
/// Süt tanklarının doluluk, temizlik ve bakım işlemlerinin takip edildiği sayfa
class SutTankiSayfasi extends StatefulWidget {
  const SutTankiSayfasi({Key? key}) : super(key: key);

  @override
  State<SutTankiSayfasi> createState() => _SutTankiSayfasiState();
}

class _SutTankiSayfasiState extends State<SutTankiSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Süt Tankı Yönetimi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storage,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Süt Tankı Takip Modülü',
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
