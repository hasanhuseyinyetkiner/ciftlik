import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/overflow_handler.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelir-Gider'),
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
                Icons.account_balance_wallet,
                size: 80,
                color: Colors.purple.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Gelir-Gider Takibi',
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
                child: const Text('Kayıt Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
