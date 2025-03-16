import 'package:flutter/material.dart';

/// Gelir-Gider Sayfası
/// İşletmenin gelir ve giderlerinin kaydedildiği ve raporlandığı sayfa
class GelirGiderSayfasi extends StatefulWidget {
  const GelirGiderSayfasi({Key? key}) : super(key: key);

  @override
  State<GelirGiderSayfasi> createState() => _GelirGiderSayfasiState();
}

class _GelirGiderSayfasiState extends State<GelirGiderSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelir-Gider Yönetimi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Gelir-Gider Takip Modülü',
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
