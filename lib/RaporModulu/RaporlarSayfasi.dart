import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/overflow_handler.dart';

/// Raporlar Sayfası
/// İşletme performansına dair çeşitli raporların görüntülendiği ve oluşturulduğu sayfa
class RaporlarSayfasi extends StatefulWidget {
  const RaporlarSayfasi({Key? key}) : super(key: key);

  @override
  State<RaporlarSayfasi> createState() => _RaporlarSayfasiState();
}

class _RaporlarSayfasiState extends State<RaporlarSayfasi> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raporlar'),
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
                Icons.bar_chart,
                size: 80,
                color: Colors.purple.shade300.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Çiftlik Raporları',
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
                child: const Text('Rapor Oluştur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
