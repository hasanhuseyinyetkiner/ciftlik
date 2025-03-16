import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'GraphicPage.dart';

/*
* SuruDetayPage - Sürü Detay Sayfası
* ---------------------------------
* Bu sayfa, seçilen sürünün detaylı bilgilerini ve 
* yönetim arayüzünü sunar.
*
* Sayfa Bileşenleri:
* 1. Üst Bilgi Alanı:
*    - Sürü adı ve ID
*    - Hayvan sayısı
*    - Oluşturulma tarihi
*    - Durum göstergesi
*
* 2. İstatistik Kartları:
*    - Toplam hayvan sayısı
*    - Yaş dağılımı
*    - Cinsiyet dağılımı
*    - Sağlık durumu
*
* 3. Hızlı İşlem Menüsü:
*    - Hayvan ekle/çıkar
*    - Toplu işlemler
*    - Raporlama
*    - Sürü düzenleme
*
* 4. Detay Sekmeleri:
*    - Hayvan listesi
*    - Sağlık kayıtları
*    - Üreme bilgileri
*    - Verimlilik analizi
*
* 5. Alt Menü:
*    - Filtreleme seçenekleri
*    - Sıralama seçenekleri
*    - Dışa aktarma
*    - Yazdırma
*
* Widget Yapısı:
* - StatelessWidget tabanlı
* - GetX state management
* - Responsive tasarım
* - Material Design 3
*
* Bağımlılıklar:
* - SuruYonetimController
* - HayvanController
* - CustomWidgets
*/

class SuruDetayPage extends StatelessWidget {
  final Suru suru;
  final SuruController controller;
  final searchController = TextEditingController();

  SuruDetayPage({
    super.key,
    required this.suru,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Get.back(),
          ),
          title: Text(
            suru.ad,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Implement edit
                Get.snackbar('Bilgi', 'Sürü düzenleme yakında!');
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Genel Bilgi'),
              Tab(text: 'Hayvanlar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Genel Bilgi Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    'Sürü Bilgileri',
                    [
                      _buildInfoRow('Sürü Adı', suru.ad),
                      _buildInfoRow('Açıklama', suru.aciklama),
                      _buildInfoRow(
                          'Hayvan Sayısı', suru.hayvanSayisi.toString()),
                      _buildInfoRow(
                        'Oluşturma Tarihi',
                        DateFormat('dd.MM.yyyy').format(suru.olusturmaTarihi),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    'İstatistikler',
                    [
                      _buildInfoRow('Toplam Büyükbaş', '0'),
                      _buildInfoRow('Toplam Küçükbaş', '0'),
                      _buildInfoRow('Aktif Hayvanlar', '0'),
                      _buildInfoRow('Satılan Hayvanlar', '0'),
                    ],
                  ),
                ],
              ),
            ),

            // Hayvanlar Tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Hayvan Ara (Küpe No, İsim)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      // TODO: Implement search
                    },
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.hayvanListesi.isEmpty) {
                      return const Center(
                        child: Text('Bu sürüde henüz hayvan bulunmuyor.'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.hayvanListesi.length,
                      itemBuilder: (context, index) {
                        final hayvan = controller.hayvanListesi[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              hayvan.kupeNo,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '${hayvan.tur} - ${hayvan.irk}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Doğum: ${DateFormat('dd.MM.yyyy').format(hayvan.dogumTarihi)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed: () {
                                // TODO: Navigate to HayvanDetayPage
                                Get.snackbar(
                                  'Bilgi',
                                  'Hayvan detay sayfası yakında!',
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Implement add animal
            Get.snackbar('Bilgi', 'Hayvan ekleme yakında!');
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
