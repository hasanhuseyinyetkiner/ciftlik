import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çiftlik Yönetim Sistemi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Get.toNamed('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed('/profile'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Menü',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Ana Sayfa'),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Hayvanlar'),
              onTap: () => Get.toNamed('/animals'),
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Sağlık'),
              onTap: () => Get.toNamed('/health'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ayarlar'),
              onTap: () => Get.toNamed('/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış'),
              onTap: () => controller.logout(),
            ),
          ],
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMenuCard(
            icon: Icons.pets,
            title: 'Hayvanlar',
            onTap: () => Get.toNamed('/animals'),
          ),
          _buildMenuCard(
            icon: Icons.medical_services,
            title: 'Sağlık',
            onTap: () => Get.toNamed('/health'),
          ),
          _buildMenuCard(
            icon: Icons.water_drop,
            title: 'Süt Yönetimi',
            onTap: () => Get.toNamed('/milk'),
          ),
          _buildMenuCard(
            icon: Icons.monitor_weight,
            title: 'Tartım',
            onTap: () => Get.toNamed('/weight'),
          ),
          _buildMenuCard(
            icon: Icons.restaurant,
            title: 'Yem Yönetimi',
            onTap: () => Get.toNamed('/feed'),
          ),
          _buildMenuCard(
            icon: Icons.calculate,
            title: 'Rasyon Hesaplama',
            onTap: () => Get.toNamed('/ration'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4.0,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48.0,
              color: Colors.green,
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
