import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'GelirGiderController.dart';

class GelirGiderGirisPage extends StatefulWidget {
  const GelirGiderGirisPage({Key? key}) : super(key: key);

  @override
  State<GelirGiderGirisPage> createState() => _GelirGiderGirisPageState();
}

class _GelirGiderGirisPageState extends State<GelirGiderGirisPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _miktarFocusNode = FocusNode();
  final _notlarFocusNode = FocusNode();
  final _miktarController = TextEditingController();
  final _notlarController = TextEditingController();

  late AnimationController _segmentedButtonAnimationController;
  late AnimationController _miktarAnimationController;
  late AnimationController _paraBirimiAnimationController;
  late AnimationController _saveButtonAnimationController;
  late AnimationController _successAnimationController;

  late Animation<double> _miktarScaleAnimation;
  late Animation<Offset> _paraBirimiSlideAnimation;
  late Animation<double> _saveButtonScaleAnimation;
  late Animation<double> _checkMarkAnimation;

  Set<String> _selectedTur = {'gelir'};
  String? _selectedKategori;
  bool _isLoading = false;
  bool _showSuccess = false;

  final List<String> _kategoriler = [
    'Süt Satışı',
    'Hayvan Satışı',
    'Yem Alımı',
    'Veteriner',
    'Ekipman',
    'İşçilik',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupFocusListeners();
  }

  void _setupAnimations() {
    // SegmentedButton animasyonu
    _segmentedButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Miktar TextField animasyonu
    _miktarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _miktarScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _miktarAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Para birimi animasyonu
    _paraBirimiAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _paraBirimiSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _paraBirimiAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Kaydet butonu animasyonları
    _saveButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _saveButtonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _saveButtonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _successAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _checkMarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  void _setupFocusListeners() {
    _miktarFocusNode.addListener(() {
      if (_miktarFocusNode.hasFocus) {
        _miktarAnimationController.forward();
        _paraBirimiAnimationController.forward();
      } else {
        _miktarAnimationController.reverse();
        _paraBirimiAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _segmentedButtonAnimationController.dispose();
    _miktarAnimationController.dispose();
    _paraBirimiAnimationController.dispose();
    _saveButtonAnimationController.dispose();
    _successAnimationController.dispose();
    _miktarFocusNode.dispose();
    _notlarFocusNode.dispose();
    _miktarController.dispose();
    _notlarController.dispose();
    super.dispose();
  }

  void _showFotoEkleBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Fotoğraf Çek'),
              onTap: () {
                Navigator.pop(context);
                // Kamera işlemleri
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(context);
                // Galeri işlemleri
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni İşlem'),
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
                  // İşlem Türü Seçimi
                  Center(
                    child: AnimatedBuilder(
                      animation: _segmentedButtonAnimationController,
                      builder: (context, child) {
                        return SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(
                              value: 'gelir',
                              label: Text('Gelir'),
                              icon: Icon(Icons.arrow_upward),
                            ),
                            ButtonSegment<String>(
                              value: 'gider',
                              label: Text('Gider'),
                              icon: Icon(Icons.arrow_downward),
                            ),
                          ],
                          selected: _selectedTur,
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _selectedTur = newSelection;
                            });
                            _segmentedButtonAnimationController.forward().then(
                                (_) => _segmentedButtonAnimationController
                                    .reset());
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                              (states) {
                                if (states.contains(MaterialState.selected)) {
                                  return _selectedTur.first == 'gelir'
                                      ? Colors.green.shade100
                                      : Colors.red.shade100;
                                }
                                return null;
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Kategori Seçimi
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return _kategoriler;
                      }
                      return _kategoriler.where((String option) {
                        return option
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      setState(() {
                        _selectedKategori = selection;
                      });
                    },
                    fieldViewBuilder: (context, textEditingController,
                        focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.category),
                        ),
                        validator: (value) =>
                            value?.isEmpty == true ? 'Kategori seçiniz' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Miktar
                  ScaleTransition(
                    scale: _miktarScaleAnimation,
                    child: TextFormField(
                      controller: _miktarController,
                      focusNode: _miktarFocusNode,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Miktar',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: SlideTransition(
                          position: _paraBirimiSlideAnimation,
                          child: const Icon(Icons.attach_money),
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty == true) return 'Miktar giriniz';
                        if (double.tryParse(value!) == null)
                          return 'Geçerli bir sayı giriniz';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fatura/Fiş Fotoğrafı
                  Row(
                    children: [
                      IconButton(
                        onPressed: _showFotoEkleBottomSheet,
                        icon: const Icon(Icons.add_a_photo),
                        tooltip: 'Fatura/Fiş Fotoğrafı Ekle',
                      ),
                      const Text('Fatura/Fiş Fotoğrafı Ekle'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Notlar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _notlarFocusNode.hasFocus ? 120 : 80,
                    child: TextFormField(
                      controller: _notlarController,
                      focusNode: _notlarFocusNode,
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        labelText: 'Notlar',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showSuccess)
            Center(
              child: ScaleTransition(
                scale: _checkMarkAnimation,
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
                        'İşlem Başarıyla Kaydedildi',
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
          scale: _saveButtonScaleAnimation,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveIslem,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _selectedTur.first == 'gelir' ? Colors.green : Colors.red,
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

  Future<void> _saveIslem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    await _saveButtonAnimationController.forward();

    // Simüle edilmiş kaydetme işlemi
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _showSuccess = true;
    });

    await _successAnimationController.forward();
    await Future.delayed(const Duration(seconds: 1));

    Get.back();
  }
}
