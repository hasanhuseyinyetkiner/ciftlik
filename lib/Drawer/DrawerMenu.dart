import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../BildirimSayfasi/NotificationPage.dart';
import '../KullaniciSayfasi/UsersPage.dart';
import '../widgets/sync_button.dart';
import '../services/data_service.dart';
import 'DrawerController.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final DrawerMenuController drawerController = Get.put(
      DrawerMenuController(),
    );

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: <Widget>[
          // Drawer Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: BoxDecoration(color: Colors.blue.shade50),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo_v2.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Çiftlik Yönetim',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Hayvanlarınızı kolayca yönetin',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _buildDrawerItem(
                  icon: Icons.home,
                  title: 'Ana Sayfa',
                  onTap: () {
                    Get.back();
                    Get.toNamed('/home');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person,
                  title: 'Profil',
                  onTap: () {
                    Get.back();
                    drawerController.navigateTo('/profil');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.event_note,
                  title: 'Ajanda',
                  onTap: () {
                    Get.back();
                    drawerController.navigateTo('/calendar');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.notifications,
                  title: 'Bildirimler',
                  onTap: () {
                    Get.back();
                    Get.to(() => const NotificationPage());
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Yönetim',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.people_alt,
                  title: 'Kullanıcılar',
                  onTap: () {
                    Get.back();
                    Get.to(() => UsersPage());
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Ayarlar',
                  onTap: () {
                    Get.back();
                    // Ayarlar sayfasına yönlendirme
                  },
                ),
              ],
            ),
          ),

          // Logout Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              elevation: 0,
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.sync, color: Colors.green.shade700),
                title: Text(
                  'Verileri Senkronize Et',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  Get.back(); // Close drawer
                  final DataService dataService = Get.find<DataService>();

                  if (!dataService.isUsingSupabase) {
                    Get.snackbar(
                      'Senkronizasyon Hatası',
                      'Çevrimdışı modda senkronizasyon yapılamaz.',
                      backgroundColor: Colors.red.withOpacity(0.7),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  Get.dialog(
                    AlertDialog(
                      title: Text('Senkronizasyon'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(child: CircularProgressIndicator()),
                          SizedBox(height: 20),
                          Text('Veriler Supabase ile senkronize ediliyor...')
                        ],
                      ),
                    ),
                    barrierDismissible: false,
                  );

                  final success = await dataService.syncDataWithSupabase();

                  Get.back(); // Close dialog

                  if (success) {
                    Get.snackbar(
                      'Başarılı',
                      'Veriler başarıyla senkronize edildi.',
                      backgroundColor: Colors.green.withOpacity(0.7),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  } else {
                    Get.snackbar(
                      'Hata',
                      'Senkronizasyon sırasında bir hata oluştu.',
                      backgroundColor: Colors.orange.withOpacity(0.7),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              ),
            ),
          ),

          // Logout Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              elevation: 0,
              color: Colors.red.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red.shade700),
                title: Text(
                  'Çıkış Yap',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Get.back();
                  drawerController.logout();
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Drawer item builder
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 0,
        color: isSelected ? Colors.blue.shade50 : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.blue.shade700 : Colors.black87,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
