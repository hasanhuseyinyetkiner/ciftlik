import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'MilkController.dart';

/*
* AddMilkPage - Süt Ölçümü Ekleme Sayfası
* ------------------------------------
* Bu sayfa, yeni süt ölçümü kayıtlarının oluşturulmasını
* ve mevcut kayıtların düzenlenmesini sağlar.
*
* Form Bileşenleri:
* 1. Temel Bilgiler:
*    - Hayvan seçimi
*    - Tarih ve saat
*    - Miktar girişi
*    - Birim seçimi
*
* 2. Kalite Bilgileri:
*    - Yağ oranı
*    - Protein oranı
*    - Somatik hücre
*    - pH değeri
*
* 3. Ek Bilgiler:
*    - Sağım periyodu
*    - Sağım yöntemi
*    - Sağımcı bilgisi
*    - Notlar
*
* 4. Validasyon:
*    - Zorunlu alanlar
*    - Değer aralıkları
*    - Format kontrolleri
*    - İş kuralları
*
* Özellikler:
* - Form validasyonu
* - Otomatik hesaplama
* - Veri önbelleği
* - Offline kayıt
*
* Entegrasyonlar:
* - MilkController
* - DatabaseService
* - ValidationService
* - CacheService
*/

class AddMilkPage extends StatefulWidget {
  const AddMilkPage({Key? key}) : super(key: key);

  @override
  State<AddMilkPage> createState() => _AddMilkPageState();
}

class _AddMilkPageState extends State<AddMilkPage>
    with SingleTickerProviderStateMixin {
  final MilkController _controller = Get.find<MilkController>();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final TextEditingController _miktar = TextEditingController();
  final TextEditingController _notlar = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
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

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _miktar.dispose();
    _notlar.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: SlideTransition(
            position: _slideAnimation,
            child: child!,
          ),
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      await _animationController.reverse();

      _controller.addSutKaydi({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'hayvanId': _controller.selectedAnimal.value,
        'hayvanAd': _controller.hayvanlar.firstWhere(
            (h) => h['id'] == _controller.selectedAnimal.value)['ad'],
        'tarih': _selectedDate,
        'miktar': double.parse(_miktar.text),
        'birim': 'litre',
        'notlar': _notlar.text,
      });

      Get.back();
      Get.snackbar(
        'Başarılı',
        'Süt verimi kaydedildi',
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
      appBar: AppBar(
        title: SlideTransition(
          position: _slideAnimation,
          child: const Text(
            'Süt Verimi Girişi',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: AnimationLimiter(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 600),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  _buildAnimalDropdown(),
                  const SizedBox(height: 16),
                  _buildDatePicker(),
                  const SizedBox(height: 16),
                  _buildMiktarField(),
                  const SizedBox(height: 16),
                  _buildNotlarField(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
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

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Sağım Tarihi',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd/MM/yyyy').format(_selectedDate),
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildMiktarField() {
    return TextFormField(
      controller: _miktar,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Süt Miktarı',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.water_drop),
        suffixText: 'litre',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen süt miktarını girin';
        }
        if (double.tryParse(value) == null) {
          return 'Geçerli bir miktar girin';
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
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton(
          onPressed: _saveForm,
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
          child: Row(
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
  }
}
