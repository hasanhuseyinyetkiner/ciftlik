import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'WeightController.dart';

/*
* AddWeightPage - Tartım Ekleme Sayfası
* --------------------------------
* Bu sayfa, yeni tartım kayıtlarının oluşturulmasını
* ve mevcut kayıtların düzenlenmesini sağlar.
*
* Form Bileşenleri:
* 1. Temel Bilgiler:
*    - Hayvan seçimi
*    - Tarih ve saat
*    - Ağırlık değeri
*    - Birim seçimi
*
* 2. Ek Bilgiler:
*    - Tartım yöntemi
*    - Tartım yeri
*    - Tartım yapan
*    - Notlar
*
* 3. Otomatik Hesaplamalar:
*    - Önceki tartımdan fark
*    - Günlük kazanç
*    - Hedef karşılaştırma
*    - Yaşa göre analiz
*
* 4. Validasyon:
*    - Değer kontrolleri
*    - Mantıksal kontroller
*    - Zorunlu alanlar
*    - Format kontrolleri
*
* 5. Özel Özellikler:
*    - Bluetooth tartı desteği
*    - Otomatik doldurma
*    - Veri önbelleği
*    - Offline kayıt
*
* Özellikler:
* - Form validasyonu
* - Otomatik hesaplama
* - Veri doğrulama
* - Hata yönetimi
*
* Entegrasyonlar:
* - WeightController
* - ValidationService
* - BluetoothService
* - CacheService
*/

class AddWeightPage extends StatefulWidget {
  const AddWeightPage({Key? key}) : super(key: key);

  @override
  State<AddWeightPage> createState() => _AddWeightPageState();
}

class _AddWeightPageState extends State<AddWeightPage>
    with SingleTickerProviderStateMixin {
  final WeightController controller = Get.find();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final Map<String, dynamic> _formData = {
    'hayvanId': '',
    'hayvanAd': '',
    'tarih': DateTime.now(),
    'agirlik': 0.0,
    'birim': 'kg',
    'notlar': '',
  };

  bool _isLoading = false;
  bool _isSaving = false;
  final FocusNode _weightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yeni Tartım Kaydı',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AnimationLimiter(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 600),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    _buildAnimalDropdown(),
                    const SizedBox(height: 16),
                    _buildDatePicker(),
                    const SizedBox(height: 16),
                    _buildWeightField(),
                    const SizedBox(height: 16),
                    _buildNotesField(),
                    const SizedBox(height: 24),
                    _buildBluetoothButton(),
                    const SizedBox(height: 16),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalDropdown() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _formData['hayvanId'] == '' ? null : _formData['hayvanId'],
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
        items: controller.hayvanlar.map((hayvan) {
          return DropdownMenuItem<String>(
            value: hayvan['id'] as String,
            child: Text(hayvan['ad']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _formData['hayvanId'] = value;
            _formData['hayvanAd'] =
                controller.hayvanlar.firstWhere((h) => h['id'] == value)['ad'];
          });
        },
        validator: (value) =>
            value == null || value.isEmpty ? 'Lütfen bir hayvan seçin' : null,
      ),
    );
  }

  Widget _buildDatePicker() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _formData['tarih'],
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() {
              _formData['tarih'] = picked;
            });
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.grey),
              const SizedBox(width: 12),
              Text(
                '${_formData['tarih'].day}/${_formData['tarih'].month}/${_formData['tarih'].year}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        focusNode: _weightFocusNode,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Ağırlık',
          suffixText: 'kg',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        onChanged: (value) {
          _formData['agirlik'] = double.tryParse(value) ?? 0.0;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lütfen ağırlık girin';
          }
          if (double.tryParse(value) == null) {
            return 'Geçerli bir sayı girin';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNotesField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        maxLines: 4,
        decoration: InputDecoration(
          labelText: 'Notlar',
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        onChanged: (value) {
          _formData['notlar'] = value;
        },
      ),
    );
  }

  Widget _buildBluetoothButton() {
    return Obx(() {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 56,
        decoration: BoxDecoration(
          color: controller.isBluetoothConnected.value
              ? Colors.green
              : Colors.blue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              if (!controller.isBluetoothConnected.value) {
                await controller.connectBluetooth();
              }
            },
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    controller.isBluetoothConnected.value
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.isBluetoothConnected.value
                        ? 'Bağlantı Kuruldu'
                        : 'Bluetooth Tartı Bağla',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (controller.isBluetoothLoading.value) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      decoration: BoxDecoration(
        color: _isSaving ? Colors.grey : Colors.red,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isSaving ? null : _submitForm,
          child: Center(
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Kaydet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_formData['agirlik'] <= 0) {
        Get.snackbar('Hata', 'Ağırlık pozitif bir değer olmalıdır.');
        return;
      }
      setState(() {
        _isSaving = true;
      });

      await Future.delayed(const Duration(milliseconds: 1000));

      _formData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      controller.addTartimKaydi(_formData);

      setState(() {
        _isSaving = false;
      });

      Get.back();
      Get.snackbar(
        'Başarılı',
        'Tartım kaydı oluşturuldu',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Hata',
        'Lütfen tüm alanları doğru bir şekilde doldurun.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
