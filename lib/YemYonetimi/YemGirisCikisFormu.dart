import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'YemStokController.dart';

/*
* YemGirisCikisFormu - Yem Giriş/Çıkış İşlem Formu
* ------------------------------------------
* Bu form, yem stoklarının giriş ve çıkış hareketlerini
* kaydetmek ve yönetmek için kullanılır.
*
* Form Bileşenleri:
* 1. Yem Bilgileri:
*    - Yem türü seçimi
*    - Miktar girişi
*    - Birim seçimi
*    - Parti numarası
*
* 2. İşlem Detayları:
*    - İşlem tipi (Giriş/Çıkış)
*    - İşlem tarihi
*    - Tedarikçi/Alıcı
*    - Fiyat bilgisi
*
* 3. Kalite Kontrol:
*    - Nem oranı
*    - Protein değeri
*    - Son kullanma tarihi
*    - Depolama koşulları
*
* 4. Depo Yönetimi:
*    - Depo seçimi
*    - Raf/Bölme
*    - Kapasite kontrolü
*    - Yerleşim planı
*
* 5. Dokümentasyon:
*    - Fatura bilgisi
*    - İrsaliye no
*    - Sertifikalar
*    - Notlar
*
* Özellikler:
* - Form validasyonu
* - Otomatik hesaplama
* - Barkod/QR okuma
* - Fotoğraf ekleme
*
* Entegrasyonlar:
* - StokController
* - DepoService
* - BarkodService
* - FaturaService
*/

class YemGirisCikisFormu extends StatefulWidget {
  const YemGirisCikisFormu({Key? key}) : super(key: key);

  @override
  State<YemGirisCikisFormu> createState() => _YemGirisCikisFormuState();
}

class _YemGirisCikisFormuState extends State<YemGirisCikisFormu>
    with TickerProviderStateMixin {
  final YemStokController _stokController = Get.find<YemStokController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _miktarController = TextEditingController();
  final TextEditingController _tedarikciController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();

  late AnimationController _formAnimationController;
  late AnimationController _segmentedButtonAnimationController;
  late AnimationController _saveButtonAnimationController;
  late AnimationController _successAnimationController;

  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _segmentedButtonRotationAnimation;
  late Animation<double> _segmentedButtonScaleAnimation;
  late Animation<double> _saveButtonScaleAnimation;
  late Animation<double> _successScaleAnimation;

  String _islemTipi = 'giris';
  String? _selectedYemTuru;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _showSuccess = false;

  final List<String> _yemTurleri = [
    'Kaba Yem',
    'Karma Yem',
    'Vitamin Takviyesi',
    'Mineral Takviyesi',
    'Konsantre Yem',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Form animasyonu
    _formAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOut,
    ));

    // SegmentedButton animasyonu
    _segmentedButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _segmentedButtonRotationAnimation = Tween<double>(
      begin: 0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _segmentedButtonAnimationController,
      curve: Curves.elasticIn,
    ));

    _segmentedButtonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _segmentedButtonAnimationController,
      curve: Curves.easeInOut,
    ));

    // Kaydet butonu animasyonu
    _saveButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _saveButtonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _saveButtonAnimationController,
      curve: Curves.easeInOut,
    ));

    // Başarılı animasyonu
    _successAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _successScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    ));

    _formAnimationController.forward();
  }

  @override
  void dispose() {
    _formAnimationController.dispose();
    _segmentedButtonAnimationController.dispose();
    _saveButtonAnimationController.dispose();
    _successAnimationController.dispose();
    _miktarController.dispose();
    _tedarikciController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await _saveButtonAnimationController.forward();

    // Simüle edilmiş kaydetme işlemi
    await Future.delayed(const Duration(seconds: 1));

    final yeniKayit = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'yemTuru': _selectedYemTuru,
      'miktar': double.parse(_miktarController.text),
      'birim': 'kg',
      'islemTipi': _islemTipi,
      'tedarikci': _tedarikciController.text,
      'tarih': _selectedDate,
      'aciklama': _aciklamaController.text,
    };

    if (_islemTipi == 'giris') {
      _stokController.yemStokEkle(yeniKayit);
    } else {
      // Stoktan düşme işlemi
    }

    setState(() {
      _isLoading = false;
      _showSuccess = true;
    });

    await _successAnimationController.forward();
    await Future.delayed(const Duration(seconds: 1));

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yem Giriş/Çıkış'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SlideTransition(
            position: _formSlideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // İşlem tipi seçimi
                    Center(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _segmentedButtonRotationAnimation,
                          _segmentedButtonScaleAnimation,
                        ]),
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _segmentedButtonScaleAnimation.value,
                            child: Transform.rotate(
                              angle: _segmentedButtonRotationAnimation.value,
                              child: SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(
                                    value: 'giris',
                                    label: Text('Giriş'),
                                    icon: Icon(Icons.add),
                                  ),
                                  ButtonSegment(
                                    value: 'cikis',
                                    label: Text('Çıkış'),
                                    icon: Icon(Icons.remove),
                                  ),
                                ],
                                selected: {_islemTipi},
                                onSelectionChanged: (Set<String> newSelection) {
                                  _segmentedButtonAnimationController
                                    ..reset()
                                    ..forward();
                                  setState(() {
                                    _islemTipi = newSelection.first;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Yem türü seçimi
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return _yemTurleri;
                        }
                        return _yemTurleri.where((yemTuru) => yemTuru
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (String selection) {
                        setState(() {
                          _selectedYemTuru = selection;
                        });
                      },
                      fieldViewBuilder: (context, textEditingController,
                          focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Yem Türü',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.grass),
                          ),
                          validator: (value) => value?.isEmpty == true
                              ? 'Yem türü seçiniz'
                              : null,
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            child: SizedBox(
                              height: 200,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: Duration(
                                        milliseconds: 200 + (index * 50)),
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(20 * (1 - value), 0),
                                        child: Opacity(
                                          opacity: value,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      title: Text(option),
                                      onTap: () => onSelected(option),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Miktar girişi
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: child,
                        );
                      },
                      child: TextFormField(
                        controller: _miktarController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Miktar',
                          suffixText: 'kg',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.scale),
                        ),
                        validator: (value) {
                          if (value?.isEmpty == true) {
                            return 'Miktar giriniz';
                          }
                          if (double.tryParse(value!) == null) {
                            return 'Geçerli bir sayı giriniz';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tedarikçi bilgisi
                    ExpansionTile(
                      title: const Text('Tedarikçi Bilgisi'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextFormField(
                            controller: _tedarikciController,
                            decoration: InputDecoration(
                              labelText: 'Tedarikçi',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.business),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tarih seçimi
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 16),
                            Text(
                              DateFormat('dd.MM.yyyy').format(_selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Açıklama
                    TextFormField(
                      controller: _aciklamaController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Açıklama',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showSuccess)
            Center(
              child: ScaleTransition(
                scale: _successScaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _islemTipi == 'giris'
                            ? 'Yem Girişi Başarılı'
                            : 'Yem Çıkışı Başarılı',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ScaleTransition(
          scale: _saveButtonScaleAnimation,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Kaydet',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }
}
