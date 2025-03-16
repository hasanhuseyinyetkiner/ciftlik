import 'package:flutter/material.dart';

/// Finansal Özet Sayfası
/// İşletmenin finansal durumunu özet olarak gösteren ve analiz eden sayfa
class FinansalOzetSayfasi extends StatefulWidget {
  const FinansalOzetSayfasi({Key? key}) : super(key: key);

  @override
  State<FinansalOzetSayfasi> createState() => _FinansalOzetSayfasiState();
}

class _FinansalOzetSayfasiState extends State<FinansalOzetSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finansal Özet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Finansal Özet Modülü',
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
