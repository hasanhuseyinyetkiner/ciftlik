import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'WeightController.dart';
import 'AddWeightPage.dart';

/*
* WeightHistoryPage - Tartım Geçmişi Sayfası
* ------------------------------------
* Bu sayfa, hayvanların tartım geçmişini ve
* detaylı kayıtlarını görüntüler.
*
* Sayfa Bileşenleri:
* 1. Tartım Listesi:
*    - Tarih ve saat
*    - Ağırlık değeri
*    - Değişim oranı
*    - Notlar
*
* 2. Filtreleme Araçları:
*    - Tarih aralığı
*    - Hayvan/Grup
*    - Değer aralığı
*    - Durum filtresi
*
* 3. Detaylı Görünüm:
*    - Tartım detayları
*    - Önceki değerler
*    - Trend analizi
*    - Karşılaştırma
*
* 4. Veri İşlemleri:
*    - Düzenleme
*    - Silme
*    - Dışa aktarma
*    - Toplu işlem
*
* 5. Analiz Araçları:
*    - Büyüme hızı
*    - Ortalama değişim
*    - Hedef takibi
*    - Anomali tespiti
*
* Özellikler:
* - Sıralama seçenekleri
* - Arama fonksiyonu
* - Sayfalama
* - Veri doğrulama
*
* Entegrasyonlar:
* - WeightController
* - HistoryService
* - FilterService
* - ExportService
*/

class WeightHistoryPage extends StatefulWidget {
  final String? hayvanId;
  
  const WeightHistoryPage({Key? key, this.hayvanId}) : super(key: key);

  @override
  State<WeightHistoryPage> createState() => _WeightHistoryPageState();
}

class _WeightHistoryPageState extends State<WeightHistoryPage>
    with SingleTickerProviderStateMixin {
  final WeightController controller = Get.find();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    // Set the selected animal if hayvanId is provided
    if (widget.hayvanId != null) {
      controller.selectedAnimal.value = widget.hayvanId;
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tartım Geçmişi',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => IconButton(
                icon: controller.isSyncing.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black87))
                    : const Icon(Icons.sync, color: Colors.black87),
                onPressed: controller.isSyncing.value
                    ? null
                    : () async {
                        final result = await controller.syncWithSupabase();
                        if (result) {
                          Get.snackbar(
                            'Senkronizasyon Başarılı',
                            'Veriler başarıyla Supabase ile senkronize edildi.',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } else {
                          Get.snackbar(
                            'Senkronizasyon Hatası',
                            'Veriler senkronize edilirken bir hata oluştu.',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
              )),
          IconButton(
            icon: Obx(() => Icon(
                  controller.isAscending.value
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  color: Colors.black87,
                )),
            onPressed: () {
              controller.isAscending.value = !controller.isAscending.value;
            },
          ),
          // Only show filter button if not viewing a specific animal
          if (widget.hayvanId == null)
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.black87),
              onPressed: () => _showFilterDialog(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // Only show filter section if not viewing a specific animal
          if (widget.hayvanId == null) _buildFilterSection(),
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Obx(() {
                  final tartimlar = widget.hayvanId != null 
                      ? controller.getTartimKayitlariByHayvanId(widget.hayvanId!)
                      : controller.getFilteredTartimKayitlari();
                  
                  if (tartimlar.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildTartimList(tartimlar);
                }),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddWeightPage(hayvanId: widget.hayvanId)),
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: const Text('Filtrele'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAnimalDropdown(),
                const SizedBox(height: 16),
                _buildDateRangePicker(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalDropdown() {
    return DropdownButtonFormField<String>(
      value: controller.selectedAnimal.value,
      decoration: InputDecoration(
        labelText: 'Hayvan Seçin',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Tüm Hayvanlar'),
        ),
        /*...controller.hayvanlar.map((hayvan) {
          return DropdownMenuItem(
            value: hayvan['id'],
            child: Text(hayvan['ad']),
          );
        }).toList(),*/
      ],
      onChanged: (value) {
        controller.selectedAnimal.value = value;
      },
    );
  }

  Widget _buildDateRangePicker() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                initialDateRange: controller.startDate.value != null &&
                        controller.endDate.value != null
                    ? DateTimeRange(
                        start: controller.startDate.value!,
                        end: controller.endDate.value!,
                      )
                    : null,
              );
              if (picked != null) {
                controller.startDate.value = picked.start;
                controller.endDate.value = picked.end;
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range, color: Colors.grey),
                  const SizedBox(width: 8),
                  Obx(() {
                    if (controller.startDate.value == null ||
                        controller.endDate.value == null) {
                      return const Text('Tarih Aralığı Seçin');
                    }
                    return Text(
                      '${DateFormat('dd/MM/yyyy').format(controller.startDate.value!)} - '
                      '${DateFormat('dd/MM/yyyy').format(controller.endDate.value!)}',
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            controller.startDate.value = null;
            controller.endDate.value = null;
          },
        ),
      ],
    );
  }

  Widget _buildTartimList(List<Map<String, dynamic>> tartimlar) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tartimlar.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildTartimCard(tartimlar[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTartimCard(Map<String, dynamic> tartim) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToTartimEdit(tartim),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.scale,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tartim['hayvanAd'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(tartim['tarih']),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${tartim['agirlik']} ${tartim['birim']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              if (tartim['notlar']?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                Text(
                  tartim['notlar'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.scale_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tartım Kaydı Bulunamadı',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Henüz kayıtlı bir tartım bulunmuyor.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showTartimDetails(Map<String, dynamic> tartim) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.scale,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tartim['hayvanAd'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(tartim['tarih']),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailItem(
                'Ağırlık', '${tartim['agirlik']} ${tartim['birim']}'),
            if (tartim['notlar']?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              _buildDetailItem('Notlar', tartim['notlar']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtreleme Seçenekleri'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimalDropdown(),
                const SizedBox(height: 16),
                _buildDateRangePicker(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Uygula',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToTartimEdit(Map<String, dynamic> tartim) {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      Get.back();
      Get.to(
        () => AddWeightPage(editData: tartim),
        transition: Transition.rightToLeft,
      );
    });
  }
}
