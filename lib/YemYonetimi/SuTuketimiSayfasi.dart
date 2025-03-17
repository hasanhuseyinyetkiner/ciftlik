import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/overflow_handler.dart';

class SuTuketimiSayfasi extends StatefulWidget {
  const SuTuketimiSayfasi({Key? key}) : super(key: key);

  @override
  State<SuTuketimiSayfasi> createState() => _SuTuketimiSayfasiState();
}

class _SuTuketimiSayfasiState extends State<SuTuketimiSayfasi> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Su Tüketimi'),
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
                Icons.water,
                size: 80,
                color: Colors.blue.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Su Tüketimi Takibi',
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
                child: const Text('Su Tüketimi Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
