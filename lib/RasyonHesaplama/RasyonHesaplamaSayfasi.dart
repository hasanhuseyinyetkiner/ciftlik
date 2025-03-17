import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/overflow_handler.dart';

class RasyonHesaplamaSayfasi extends StatefulWidget {
  const RasyonHesaplamaSayfasi({Key? key}) : super(key: key);

  @override
  State<RasyonHesaplamaSayfasi> createState() => _RasyonHesaplamaSayfasiState();
}

class _RasyonHesaplamaSayfasiState extends State<RasyonHesaplamaSayfasi> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rasyon Hesaplama'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: OverflowHandler(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calculate,
                size: 80,
                color: Colors.orange.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Rasyon Hesaplama Modülü',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Bu modül geliştirme aşamasındadır',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Bu özellik çok yakında eklenecek')),
                  );
                },
                child: const Text('Rasyon Hesapla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
