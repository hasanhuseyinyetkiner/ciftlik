import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'HastalikController.dart';

class HastalikKayitFormu extends StatefulWidget {
  const HastalikKayitFormu({Key? key}) : super(key: key);

  @override
  State<HastalikKayitFormu> createState() => _HastalikKayitFormuState();
}

class _HastalikKayitFormuState extends State<HastalikKayitFormu>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final HastalikController _hastalikController = Get.find<HastalikController>();

  late AnimationController _formAnimationController;
  late AnimationController _saveButtonAnimationController;
  late AnimationController _successAnimationController;

  late List<Animation<Offset>> _formFieldSlideAnimations;
  late Animation<double> _saveButtonScale;
  late Animation<double> _saveButtonFill;
  late Animation<double> _checkMarkScale;

  final TextEditingController _hayvanIdController = TextEditingController();
  final TextEditingController _tedaviController = TextEditingController();
  final List<String> _seciliBelirtiler = [];
  DateTime? _baslangicTarihi;
  String? _selectedHayvanTuru;
  String? _selectedHastalikTuru;
  bool _isLoading = false;
  bool _showSuccess = false;

  final List<String> _hayvanTurleri = ['İnek', 'Buzağı', 'Koyun', 'Kuzu'];
  final Map<String, List<String>> _belirtiKategorileri = {
    'Genel': ['Ateş', 'İştahsızlık', 'Halsizlik', 'Kilo kaybı'],
    'Sindirim': ['İshal', 'Kabızlık', 'Kusma', 'Şişkinlik'],
    'Solunum': ['Öksürük', 'Burun akıntısı', 'Nefes darlığı'],
    'Hareket': ['Topallık', 'Yürüme güçlüğü', 'Eklem şişliği'],
    'Deri': ['Yaralar', 'Döküntü', 'Kaşıntı', 'Tüy dökülmesi'],
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Form animasyonları
    _formAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _formFieldSlideAnimations = List.generate(
      6, // Form alanı sayısı
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _formAnimationController,
        curve: Interval(
          index * 0.1,
          0.1 + index * 0.1,
          curve: Curves.easeOut,
        ),
      )),
    );

    // Kaydet butonu animasyonları
    _saveButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _saveButtonScale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _saveButtonAnimationController,
      curve: Curves.easeInOut,
    ));

    _saveButtonFill = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _saveButtonAnimationController,
      curve: Curves.easeInOut,
    ));

    // Başarı animasyonu
    _successAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _checkMarkScale = Tween<double>(
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
    _saveButtonAnimationController.dispose();
    _successAnimationController.dispose();
    _hayvanIdController.dispose();
    _tedaviController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _baslangicTarihi ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _baslangicTarihi) {
      setState(() {
        _baslangicTarihi = picked;
      });
    }
  }

  void _showBelirtiSecimi() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _belirtiKategorileri.length,
                  itemBuilder: (context, index) {
                    final kategori = _belirtiKategorileri.keys.elementAt(index);
                    final belirtiler = _belirtiKategorileri[kategori]!;
                    return ExpansionTile(
                      title: Text(kategori),
                      children: belirtiler.map((belirti) {
                        return CheckboxListTile(
                          title: Text(belirti),
                          value: _seciliBelirtiler.contains(belirti),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _seciliBelirtiler.add(belirti);
                              } else {
                                _seciliBelirtiler.remove(belirti);
                              }
                            });
                            this.setState(() {});
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveHastalik() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    await _saveButtonAnimationController.forward();

    // Simüle edilmiş kaydetme işlemi
    await Future.delayed(const Duration(seconds: 1));

    final yeniKayit = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'hayvanId': _hayvanIdController.text,
      'hayvanTuru': _selectedHayvanTuru,
      'hastalikId': _selectedHastalikTuru,
      'baslangicTarihi': _baslangicTarihi,
      'belirtiler': _seciliBelirtiler,
      'tedavi': _tedaviController.text,
      'durum': 'devam',
    };

    _hastalikController.addHastalikKaydi(yeniKayit);

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
        title: const Text('Yeni Hastalık Kaydı'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hayvan seçimi
                  SlideTransition(
                    position: _formFieldSlideAnimations[0],
                    child: DropdownButtonFormField<String>(
                      value: _selectedHayvanTuru,
                      decoration: InputDecoration(
                        labelText: 'Hayvan Türü',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.pets),
                      ),
                      items: _hayvanTurleri
                          .map((tur) => DropdownMenuItem(
                                value: tur,
                                child: Text(tur),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedHayvanTuru = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Hayvan türü seçiniz' : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hayvan ID
                  SlideTransition(
                    position: _formFieldSlideAnimations[1],
                    child: TextFormField(
                      controller: _hayvanIdController,
                      decoration: InputDecoration(
                        labelText: 'Hayvan ID/Küpe No',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.tag),
                      ),
                      validator: (value) =>
                          value?.isEmpty == true ? 'Hayvan ID giriniz' : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hastalık türü seçimi
                  SlideTransition(
                    position: _formFieldSlideAnimations[2],
                    child: DropdownButtonFormField<String>(
                      value: _selectedHastalikTuru,
                      decoration: InputDecoration(
                        labelText: 'Hastalık Türü',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.medical_services),
                      ),
                      items: _hastalikController.hastalikTurleri
                          .map((hastalik) => DropdownMenuItem(
                                value: hastalik['id'] as String,
                                child: Text(hastalik['ad'] as String),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedHastalikTuru = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Hastalık türü seçiniz' : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Başlangıç tarihi
                  SlideTransition(
                    position: _formFieldSlideAnimations[3],
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Başlangıç Tarihi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _baslangicTarihi == null
                              ? 'Tarih Seçiniz'
                              : '${_baslangicTarihi!.day}/${_baslangicTarihi!.month}/${_baslangicTarihi!.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Belirtiler
                  SlideTransition(
                    position: _formFieldSlideAnimations[4],
                    child: InkWell(
                      onTap: _showBelirtiSecimi,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Belirtiler',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.medical_information),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _seciliBelirtiler.isEmpty
                              ? [const Text('Belirti Seçiniz')]
                              : _seciliBelirtiler
                                  .map(
                                    (belirti) => Chip(
                                      label: Text(belirti),
                                      onDeleted: () {
                                        setState(() {
                                          _seciliBelirtiler.remove(belirti);
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tedavi
                  SlideTransition(
                    position: _formFieldSlideAnimations[5],
                    child: TextFormField(
                      controller: _tedaviController,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: 'Tedavi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.medication),
                      ),
                      validator: (value) => value?.isEmpty == true
                          ? 'Tedavi bilgisi giriniz'
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showSuccess)
            Center(
              child: ScaleTransition(
                scale: _checkMarkScale,
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
                      const Text(
                        'Hastalık Kaydı Başarıyla Oluşturuldu',
                        style: TextStyle(
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
          scale: _saveButtonScale,
          child: AnimatedBuilder(
            animation: _saveButtonFill,
            builder: (context, child) {
              return ElevatedButton(
                onPressed: _isLoading ? null : _saveHastalik,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.lerp(
                    Colors.blue,
                    Colors.green,
                    _saveButtonFill.value,
                  ),
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
                        'Kaydet',
                        style: TextStyle(fontSize: 16),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
