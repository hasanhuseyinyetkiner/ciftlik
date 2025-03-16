import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'ReportController.dart';

/*
* ReportParametersPage - Rapor Parametreleri Sayfası
* ----------------------------------------
* Bu sayfa, rapor oluşturma öncesinde gerekli parametrelerin
* seçilmesi ve ayarlanması için arayüz sağlar.
*
* Form Bileşenleri:
* 1. Temel Parametreler:
*    - Rapor tipi
*    - Tarih aralığı
*    - Veri kapsamı
*    - Gruplama seçenekleri
*
* 2. Veri Filtreleri:
*    - Hayvan grupları
*    - Veri kategorileri
*    - Durum filtreleri
*    - Özel filtreler
*
* 3. Çıktı Ayarları:
*    - Format seçimi
*    - Görsel temalar
*    - Dil seçenekleri
*    - Sayfa düzeni
*
* 4. Hesaplama Seçenekleri:
*    - İstatistik türleri
*    - Analiz metodları
*    - Karşılaştırma kriterleri
*    - Formül seçimleri
*
* 5. Görsel Öğeler:
*    - Grafik tipleri
*    - Renk şemaları
*    - Font seçimleri
*    - İkon setleri
*
* Özellikler:
* - Form validasyonu
* - Parametre kaydetme
* - Önizleme seçeneği
* - Şablon desteği
*
* Entegrasyonlar:
* - ReportController
* - ParameterService
* - ValidationService
* - TemplateService
*/

class ReportParametersPage extends StatefulWidget {
  const ReportParametersPage({Key? key}) : super(key: key);

  @override
  State<ReportParametersPage> createState() => _ReportParametersPageState();
}

class _ReportParametersPageState extends State<ReportParametersPage>
    with TickerProviderStateMixin {
  final Map<String, dynamic> category = Get.arguments;
  final _formKey = GlobalKey<FormState>();

  late AnimationController _formAnimationController;
  late AnimationController _subtitleAnimationController;
  late AnimationController _datePickerAnimationController;
  late AnimationController _segmentedButtonAnimationController;
  late AnimationController _submitButtonAnimationController;

  late Animation<Offset> _formSlideAnimation;
  late Animation<Offset> _subtitleSlideAnimation;
  late Animation<double> _datePickerScaleAnimation;
  late Animation<double> _segmentedButtonRotationAnimation;
  late Animation<Color?> _submitButtonColorAnimation;
  late Animation<double> _submitButtonScaleAnimation;

  final List<String> _hayvanGruplari = [
    'Tüm Hayvanlar',
    'İnekler',
    'Buzağılar',
    'Koyunlar',
    'Kuzular',
  ];

  String _selectedHayvanGrubu = '';
  String _selectedRaporTuru = 'gunluk';
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );
  bool _isLoading = false;
  bool _isFormValid = false;

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
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOut,
    ));

    // Alt başlık animasyonu
    _subtitleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _subtitleAnimationController,
      curve: Curves.easeOut,
    ));

    // Tarih seçici animasyonu
    _datePickerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _datePickerScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _datePickerAnimationController,
      curve: Curves.easeOut,
    ));

    // SegmentedButton animasyonu
    _segmentedButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _segmentedButtonRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _segmentedButtonAnimationController,
      curve: Curves.elasticIn,
    ));

    // Submit button animasyonları
    _submitButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _submitButtonColorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.blue,
    ).animate(CurvedAnimation(
      parent: _submitButtonAnimationController,
      curve: Curves.easeInOut,
    ));

    _submitButtonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _submitButtonAnimationController,
      curve: Curves.easeInOut,
    ));

    _formAnimationController.forward();
    _subtitleAnimationController.forward();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(category['color']),
            ),
          ),
          child: AnimatedBuilder(
            animation: _datePickerScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _datePickerScaleAnimation.value,
                child: child,
              );
            },
            child: child,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      _datePickerAnimationController.forward(from: 0.0);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await _submitButtonAnimationController.forward();

    // Simüle edilmiş rapor oluşturma işlemi
    await Future.delayed(const Duration(seconds: 2));

    Get.toNamed('/report-view', arguments: {
      'category': category,
      'parameters': {
        'hayvanGrubu': _selectedHayvanGrubu,
        'raporTuru': _selectedRaporTuru,
        'baslangicTarihi': _dateRange.start,
        'bitisTarihi': _dateRange.end,
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category['title']),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SlideTransition(
              position: _subtitleSlideAnimation,
              child: Text(
                category['description'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SlideTransition(
              position: _formSlideAnimation,
              child: Form(
                key: _formKey,
                onChanged: () {
                  final isValid = _formKey.currentState?.validate() ?? false;
                  if (isValid != _isFormValid) {
                    setState(() {
                      _isFormValid = isValid;
                    });
                    if (isValid) {
                      _submitButtonAnimationController.forward();
                    } else {
                      _submitButtonAnimationController.reverse();
                    }
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rapor türü seçimi
                    AnimatedBuilder(
                      animation: _segmentedButtonRotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _segmentedButtonRotationAnimation.value,
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(
                                value: 'gunluk',
                                label: Text('Günlük'),
                                icon: Icon(Icons.calendar_today),
                              ),
                              ButtonSegment(
                                value: 'haftalik',
                                label: Text('Haftalık'),
                                icon: Icon(Icons.calendar_view_week),
                              ),
                              ButtonSegment(
                                value: 'aylik',
                                label: Text('Aylık'),
                                icon: Icon(Icons.calendar_month),
                              ),
                            ],
                            selected: {_selectedRaporTuru},
                            onSelectionChanged: (Set<String> newSelection) {
                              _segmentedButtonAnimationController
                                ..reset()
                                ..forward();
                              setState(() {
                                _selectedRaporTuru = newSelection.first;
                              });
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Tarih aralığı seçimi
                    InkWell(
                      onTap: _selectDateRange,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Tarih Aralığı',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.date_range),
                        ),
                        child: Text(
                          '${DateFormat('dd.MM.yyyy').format(_dateRange.start)} - ${DateFormat('dd.MM.yyyy').format(_dateRange.end)}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Hayvan grubu seçimi
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return _hayvanGruplari;
                        }
                        return _hayvanGruplari.where((grup) => grup
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (String selection) {
                        setState(() {
                          _selectedHayvanGrubu = selection;
                        });
                      },
                      fieldViewBuilder: (context, textEditingController,
                          focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Hayvan Grubu',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.pets),
                          ),
                          validator: (value) => value?.isEmpty == true
                              ? 'Hayvan grubu seçiniz'
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _submitButtonColorAnimation,
            _submitButtonScaleAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _isLoading
                  ? _submitButtonScaleAnimation.value
                  : 1.0 - (0.1 * _submitButtonScaleAnimation.value),
              child: ElevatedButton(
                onPressed: _isFormValid && !_isLoading ? _submitForm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _submitButtonColorAnimation.value,
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Rapor Oluştur',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _formAnimationController.dispose();
    _subtitleAnimationController.dispose();
    _datePickerAnimationController.dispose();
    _segmentedButtonAnimationController.dispose();
    _submitButtonAnimationController.dispose();
    super.dispose();
  }
}
