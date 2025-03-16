import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'RationWizardController.dart';

/*
* RasyonOlusturmaPage - Rasyon Oluşturma Sayfası
* ------------------------------------
* Bu sayfa, yeni rasyon formülasyonlarının oluşturulması
* ve düzenlenmesi için arayüz sağlar.
*
* Form Bileşenleri:
* 1. Rasyon Bilgileri:
*    - Rasyon adı
*    - Hedef grup
*    - Dönem
*    - Kapasite
*
* 2. Yem Seçimi:
*    - Yem listesi
*    - Miktar girişi
*    - Stok kontrolü
*    - Alternatifler
*
* 3. Besin Hesaplama:
*    - Otomatik analiz
*    - Dengeleme
*    - Limit kontrolü
*    - Uyarı sistemi
*
* 4. Maliyet Yönetimi:
*    - Birim fiyatlar
*    - Toplam maliyet
*    - Optimizasyon
*    - Bütçe kontrolü
*
* 5. Kalite Kontrol:
*    - Besin dengesi
*    - Mineral dengesi
*    - Vitamin analizi
*    - Uygunluk kontrolü
*
* Özellikler:
* - Dinamik hesaplama
* - Anlık feedback
* - Şablon desteği
* - Veri doğrulama
*
* Entegrasyonlar:
* - RasyonController
* - StokService
* - MaliyetService
* - OptimizasyonService
*/

class RasyonOlusturmaPage extends StatefulWidget {
  const RasyonOlusturmaPage({Key? key}) : super(key: key);

  @override
  State<RasyonOlusturmaPage> createState() => _RasyonOlusturmaPageState();
}

class _RasyonOlusturmaPageState extends State<RasyonOlusturmaPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final RationWizardController controller = Get.find<RationWizardController>();

  late AnimationController _formAnimationController;
  late AnimationController _saveButtonAnimationController;
  late AnimationController _successAnimationController;
  late Animation<double> _saveButtonScaleAnimation;
  late Animation<double> _checkMarkAnimation;

  final RxList<Map<String, dynamic>> _yemBilesenleri =
      <Map<String, dynamic>>[].obs;
  final _rasyonAdiController = TextEditingController();
  final _aciklamaController = TextEditingController();
  String? _selectedHayvanGrubu;
  bool _isLoading = false;
  bool _showSuccess = false;

  // Staggered animations için offset'ler
  final List<Animation<Offset>> _slideAnimations = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _addInitialYemBileseni();
  }

  void _setupAnimations() {
    _formAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _saveButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _successAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _saveButtonScaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _saveButtonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _checkMarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Form alanları için staggered animations
    for (var i = 0; i < 4; i++) {
      _slideAnimations.add(
        Tween<Offset>(
          begin: const Offset(0.0, 0.5),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _formAnimationController,
            curve: Interval(
              i * 0.2,
              0.6 + (i * 0.2),
              curve: Curves.easeOut,
            ),
          ),
        ),
      );
    }

    _formAnimationController.forward();
  }

  void _addInitialYemBileseni() {
    _yemBilesenleri.add({
      'yem': '',
      'miktar': 0.0,
      'protein': 0.0,
      'enerji': 0.0,
    });
  }

  @override
  void dispose() {
    _formAnimationController.dispose();
    _saveButtonAnimationController.dispose();
    _successAnimationController.dispose();
    _rasyonAdiController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Rasyon'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rasyon Adı
                  SlideTransition(
                    position: _slideAnimations[0],
                    child: FadeTransition(
                      opacity: _formAnimationController,
                      child: TextFormField(
                        controller: _rasyonAdiController,
                        decoration: InputDecoration(
                          labelText: 'Rasyon Adı',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? 'Rasyon adı gerekli'
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hayvan Grubu
                  SlideTransition(
                    position: _slideAnimations[1],
                    child: FadeTransition(
                      opacity: _formAnimationController,
                      child: DropdownButtonFormField<String>(
                        value: _selectedHayvanGrubu,
                        decoration: InputDecoration(
                          labelText: 'Hayvan Grubu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Süt İneği',
                            child: Text('Süt İneği'),
                          ),
                          DropdownMenuItem(
                            value: 'Besi Sığırı',
                            child: Text('Besi Sığırı'),
                          ),
                          DropdownMenuItem(
                            value: 'Düve',
                            child: Text('Düve'),
                          ),
                          DropdownMenuItem(
                            value: 'Buzağı',
                            child: Text('Buzağı'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedHayvanGrubu = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Hayvan grubu seçiniz' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Yem Bileşenleri
                  SlideTransition(
                    position: _slideAnimations[2],
                    child: FadeTransition(
                      opacity: _formAnimationController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Yem Bileşenleri',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _yemBilesenleri.length,
                                itemBuilder: (context, index) {
                                  return _buildYemBileseniCard(index);
                                },
                              )),
                          OutlinedButton.icon(
                            onPressed: () {
                              _yemBilesenleri.add({
                                'yem': '',
                                'miktar': 0.0,
                                'protein': 0.0,
                                'enerji': 0.0,
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Yem Ekle'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Açıklama
                  SlideTransition(
                    position: _slideAnimations[3],
                    child: FadeTransition(
                      opacity: _formAnimationController,
                      child: TextFormField(
                        controller: _aciklamaController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Açıklama',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Besin Değerleri Özeti
                  _buildBesinDegerleriOzeti(),
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
                        'Rasyon Başarıyla Kaydedildi',
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
            onPressed: _isLoading ? null : _saveRasyon,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isLoading ? Colors.grey : Colors.blue,
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

  Widget _buildYemBileseniCard(int index) {
    final yem = _yemBilesenleri[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(yem['yem'].isEmpty ? 'Yeni Yem' : yem['yem']),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Yem Adı',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: yem['yem'],
                  onChanged: (value) {
                    yem['yem'] = value;
                    _yemBilesenleri.refresh();
                  },
                ),
                const SizedBox(height: 16),
                _buildAnimatedSlider(
                  label: 'Miktar (kg)',
                  value: yem['miktar'],
                  onChanged: (value) {
                    setState(() {
                      yem['miktar'] = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildAnimatedSlider(
                  label: 'Protein (%)',
                  value: yem['protein'],
                  onChanged: (value) {
                    setState(() {
                      yem['protein'] = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildAnimatedSlider(
                  label: 'Enerji (kcal/kg)',
                  value: yem['enerji'],
                  max: 5000,
                  onChanged: (value) {
                    setState(() {
                      yem['enerji'] = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    double max = 100,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                max: max,
                onChanged: onChanged,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Container(
                key: ValueKey<double>(value),
                width: 60,
                child: Text(
                  value.toStringAsFixed(1),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBesinDegerleriOzeti() {
    double toplamProtein = 0;
    double toplamEnerji = 0;
    double toplamMiktar = 0;

    for (var yem in _yemBilesenleri) {
      toplamProtein +=
          (yem['protein'] as double) * (yem['miktar'] as double) / 100;
      toplamEnerji += (yem['enerji'] as double) * (yem['miktar'] as double);
      toplamMiktar += yem['miktar'] as double;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Card(
        key: ValueKey<String>('${toplamProtein}_${toplamEnerji}_$toplamMiktar'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Besin Değerleri Özeti',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildBesinDegeriSatiri(
                'Toplam Miktar',
                '${toplamMiktar.toStringAsFixed(1)} kg',
                Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildBesinDegeriSatiri(
                'Toplam Protein',
                '${toplamProtein.toStringAsFixed(1)} kg',
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildBesinDegeriSatiri(
                'Toplam Enerji',
                '${toplamEnerji.toStringAsFixed(1)} kcal',
                Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBesinDegeriSatiri(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _saveRasyon() async {
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
