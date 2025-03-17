import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/overflow_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _sync = true;
  String _language = 'Türkçe';
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: OverflowHandler(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Genel Ayarlar',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Theme settings
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Karanlık Mod'),
                    subtitle: const Text('Karanlık temayı kullan'),
                    secondary: const Icon(Icons.dark_mode),
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Dil'),
                    subtitle: Text(_language),
                    leading: const Icon(Icons.language),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showLanguageDialog,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Text(
              'Bildirimler',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Notification settings
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Bildirimler'),
                    subtitle: const Text('Bildirimleri etkinleştir'),
                    secondary: const Icon(Icons.notifications),
                    value: _notifications,
                    onChanged: (value) {
                      setState(() {
                        _notifications = value;
                      });
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Bildirim Sesi'),
                    subtitle: const Text('Varsayılan'),
                    leading: const Icon(Icons.volume_up),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Show notification sound options
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Text(
              'Veri Senkronizasyonu',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Sync settings
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Otomatik Senkronizasyon'),
                    subtitle: const Text('Verileri otomatik senkronize et'),
                    secondary: const Icon(Icons.sync),
                    value: _sync,
                    onChanged: (value) {
                      setState(() {
                        _sync = value;
                      });
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Veri Yedekleme'),
                    subtitle: const Text('Verileri yedekle ve geri yükle'),
                    leading: const Icon(Icons.backup),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Show backup options
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Text(
              'Uygulama Bilgileri',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // App info
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Uygulama Sürümü'),
                    subtitle: const Text('1.0.0'),
                    leading: const Icon(Icons.info),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Lisans Bilgileri'),
                    leading: const Icon(Icons.description),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Show license info
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Hakkında'),
                    leading: const Icon(Icons.help),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Show about dialog
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showLanguageDialog() {
    final languages = ['Türkçe', 'English', 'Deutsch', 'Español'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dil Seçin'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final language = languages[index];
              return ListTile(
                title: Text(language),
                trailing: language == _language ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    _language = language;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }
}