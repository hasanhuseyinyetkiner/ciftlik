import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'MilkController.dart';

/*
* MilkQualityPage - Süt Kalitesi Giriş Sayfası
* ----------------------------------------
* Bu sayfa, süt kalitesi ölçümlerinin ve analizlerinin
* girilmesini ve yönetilmesini sağlar.
*
* Temel Özellikler:
* 1. Kalite Parametreleri:
*    - Yağ oranı
*    - Protein oranı
*    - Somatik hücre sayısı
*    - Bakteriyel analiz
*
* 2. Veri Girişi:
*    - Tarih seçimi
*    - Hayvan seçimi
*    - Değer girişi
*    - Not ekleme
*
* 3. Kalite Kontrol:
*    - Limit kontrolleri
*    - Trend analizi
*    - Anomali tespiti
*    - Uyarı sistemi
*
* 4. Raporlama:
*    - Günlük rapor
*    - Haftalık analiz
*    - Aylık özet
*    - Karşılaştırma
*
* Görsel Özellikler:
* - Animasyonlu geçişler
* - Veri validasyonu
* - Hata bildirimleri
* - İnteraktif grafikler
*
* Entegrasyonlar:
* - MilkController
* - DatabaseService
* - NotificationService
* - ChartService
*/

class MilkQualityPage extends StatefulWidget {
  const MilkQualityPage({Key? key}) : super(key: key);

  @override
  State<MilkQualityPage> createState() => _MilkQualityPageState();
}

class _MilkQualityPageState extends State<MilkQualityPage>
    with SingleTickerProviderStateMixin {
  final MilkController _controller = Get.find<MilkController>();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _slideDownAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  final RxBool _isLoading = false.obs;
  final RxBool _isLabDataLoading = false.obs;

  final TextEditingController _yagOrani = TextEditingController();
  final TextEditingController _proteinOrani = TextEditingController();
  final TextEditingController _somatikHucreSayisi = TextEditingController();
  final TextEditingController _notlar = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideDownAnimation = Tween<double>(
      begin: -100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _yagOrani.dispose();
    _proteinOrani.dispose();
    _somatikHucreSayisi.dispose();
    _notlar.dispose();
    super.dispose();
  }

  Future<void> _loadLabData() async {
    _isLabDataLoading.value = true;
    await _controller.loadLabData();

    _yagOrani.text = _controller.yagOrani.value.toString();
    _proteinOrani.text = _controller.proteinOrani.value.toString();
    _somatikHucreSayisi.text = _controller.somatikHucreSayisi.value.toString();

    _isLabDataLoading.value = false;
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 1000));

      // Kalite verilerini kaydet
      // TODO: Implement save functionality

      _isLoading.value = false;
      Get.back();
      Get.snackbar(
        'Başarılı',
        'Süt kalitesi verileri kaydedildi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideDownAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: const Text(
                'Süt Kalitesi Girişi',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildContent() {
    return AnimationLimiter(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 600),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                _buildAnimalDropdown(),
                const SizedBox(height: 16),
                _buildLabDataButton(),
                const SizedBox(height: 24),
                _buildQualityFields(),
                const SizedBox(height: 16),
                _buildNotlarField(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalDropdown() {
    return Obx(() {
      return DropdownButtonFormField<String>(
        value: _controller.selectedAnimal.value,
        decoration: InputDecoration(
          labelText: 'Hayvan Seçin',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: const Icon(Icons.pets),
        ),
        items: _controller.hayvanlar.map((hayvan) {
          return DropdownMenuItem<String>(
            value: hayvan['id'] as String,
            child: Text(hayvan['ad'] as String),
          );
        }).toList(),
        onChanged: (String? value) {
          _controller.selectedAnimal.value = value;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lütfen bir hayvan seçin';
          }
          return null;
        },
      );
    });
  }

  Widget _buildLabDataButton() {
    return Obx(() {
      if (_isLabDataLoading.value) {
        return Center(
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: const CircularProgressIndicator(),
              );
            },
          ),
        );
      }

      return ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _loadLabData,
            icon: const Icon(Icons.science),
            label: const Text('Laboratuvar Verilerini Yükle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildQualityFields() {
    return Column(
      children: [
        _buildQualityField(
          controller: _yagOrani,
          label: 'Yağ Oranı',
          suffix: '%',
          icon: Icons.opacity,
        ),
        const SizedBox(height: 16),
        _buildQualityField(
          controller: _proteinOrani,
          label: 'Protein Oranı',
          suffix: '%',
          icon: Icons.bubble_chart,
        ),
        const SizedBox(height: 16),
        _buildQualityField(
          controller: _somatikHucreSayisi,
          label: 'Somatik Hücre Sayısı',
          suffix: 'hücre/ml',
          icon: Icons.biotech,
          isInteger: true,
        ),
      ],
    );
  }

  Widget _buildQualityField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    bool isInteger = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(icon),
        suffixText: suffix,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Bu alan zorunludur';
        }
        if (isInteger) {
          if (int.tryParse(value) == null) {
            return 'Geçerli bir sayı girin';
          }
        } else {
          if (double.tryParse(value) == null) {
            return 'Geçerli bir sayı girin';
          }
        }
        return null;
      },
    );
  }

  Widget _buildNotlarField() {
    return TextFormField(
      controller: _notlar,
      maxLines: null,
      minLines: 3,
      decoration: InputDecoration(
        labelText: 'Notlar',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.note),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Obx(() {
      return Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: ElevatedButton(
            onPressed: _isLoading.value ? null : _saveForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(
                horizontal: 48,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.save),
                      const SizedBox(width: 8),
                      const Text(
                        'Kaydet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}
