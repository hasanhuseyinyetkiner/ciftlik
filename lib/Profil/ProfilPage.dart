import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Drawer/DrawerMenu.dart';
import 'profil_controller.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfilController profilController = Get.put(ProfilController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Ayarlar sayfasına yönlendirme
              Get.snackbar('Bilgi', 'Ayarlar sayfası yakında eklenecek');
            },
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profil Fotoğrafı Bölümü
                GestureDetector(
                  onTap: () {
                    _showImagePickerDialog(context, profilController);
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Obx(() =>
                            profilController.imagePath.value.isNotEmpty
                                ? _imageWidget(profilController.imagePath.value)
                                : _addPhotoIcon()),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Kullanıcı Bilgileri Bölümü
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Kullanıcı Bilgileri",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email Alanı
                        TextField(
                          controller: profilController.emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 16),

                        // Kullanıcı Adı Alanı (Örnek olarak ekledim)
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Kullanıcı Adı',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Telefon Alanı (Örnek olarak ekledim)
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Telefon',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Veri Senkronizasyon Bölümü
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Veri Senkronizasyonu",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Senkronizasyon Butonları
                        _buildSyncButton(
                          context,
                          "Kullanıcı Verilerini Senkronize Et",
                          Icons.sync,
                          () async {
                            await profilController
                                .syncUsersFromApiToDatabase(context);
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildSyncButton(
                          context,
                          "Hayvan Türlerini İndir",
                          Icons.download_outlined,
                          () async {
                            await profilController.syncAnimalTypes(context);
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildSyncButton(
                          context,
                          "Hayvan Türlerini Yükle",
                          Icons.upload_outlined,
                          () async {
                            await profilController
                                .syncAnimalTypesToMySQL(context);
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildSyncButton(
                          context,
                          "Alt Türleri İndir",
                          Icons.download_outlined,
                          () async {
                            await profilController.syncAnimalSubtypes(context);
                          },
                        ),

                        const SizedBox(height: 12),

                        _buildSyncButton(
                          context,
                          "Alt Türleri Yükle",
                          Icons.upload_outlined,
                          () async {
                            await profilController
                                .syncAnimalSubtypesToMySQL(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Çıkış Yap Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Çıkış işlemi
                      Get.offAllNamed('/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Çıkış Yap"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _imageWidget(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Image.file(
        File(imagePath),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _addPhotoIcon() {
    return const Center(
      child: Icon(
        Icons.add_a_photo,
        size: 40,
        color: Colors.black54,
      ),
    );
  }

  Future<void> _showImagePickerDialog(
      BuildContext context, ProfilController profilController) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Fotoğraf Ekle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galeriden Seç"),
              onTap: () {
                profilController.getImageFromGallery();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Fotoğraf Çek"),
              onTap: () {
                profilController.getImageFromCamera();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("İptal"),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
