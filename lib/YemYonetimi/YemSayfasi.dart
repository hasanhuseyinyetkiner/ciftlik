import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/overflow_handler.dart';

class YemSayfasi extends StatefulWidget {
  const YemSayfasi({Key? key}) : super(key: key);

  @override
  State<YemSayfasi> createState() => _YemSayfasiState();
}

class _YemSayfasiState extends State<YemSayfasi> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yem Yönetimi'),
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
                Icons.fastfood,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Yem Yönetimi Modülü',
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
                child: const Text('Yem Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
