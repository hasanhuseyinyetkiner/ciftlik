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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finansal Özet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart,
              size: 80,
              color: Colors.purple.shade700.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Finansal Özet Raporu',
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
    );
  }
}
