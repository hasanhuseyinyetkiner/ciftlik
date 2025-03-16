import 'package:flutter/material.dart';

/// Yem Yönetimi Sayfası
/// Hayvanların yem tüketiminin izlendiği ve yem stoklarının yönetildiği sayfa
class YemSayfasi extends StatefulWidget {
  const YemSayfasi({Key? key}) : super(key: key);

  @override
  State<YemSayfasi> createState() => _YemSayfasiState();
}

class _YemSayfasiState extends State<YemSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yem Yönetimi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fastfood,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Yem Yönetim Modülü',
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
