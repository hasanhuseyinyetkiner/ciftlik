import 'package:flutter/material.dart';

/// Hastalık Takip Sayfası
/// Hayvanların hastalık kayıtlarını ve takiplerini yönetmek için kullanılır
class HastalikSayfasi extends StatefulWidget {
  const HastalikSayfasi({Key? key}) : super(key: key);

  @override
  State<HastalikSayfasi> createState() => _HastalikSayfasiState();
}

class _HastalikSayfasiState extends State<HastalikSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hastalık Takibi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Hastalık Takip Modülü',
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
