import 'package:flutter/material.dart';

/// Tartım Ekle Sayfası
/// Hayvanların tartım bilgilerinin girildiği ve kaydedildiği sayfa
class TartimEklePage extends StatefulWidget {
  const TartimEklePage({Key? key}) : super(key: key);

  @override
  State<TartimEklePage> createState() => _TartimEklePageState();
}

class _TartimEklePageState extends State<TartimEklePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tartım Ekle'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Tartım Ekleme Modülü',
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
