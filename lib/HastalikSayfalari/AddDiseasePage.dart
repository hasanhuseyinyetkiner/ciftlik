import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'DiseaseController.dart';

class AddDiseasePage extends StatefulWidget {
  const AddDiseasePage({Key? key}) : super(key: key);

  @override
  State<AddDiseasePage> createState() => _AddDiseasePageState();
}

class _AddDiseasePageState extends State<AddDiseasePage>
    with SingleTickerProviderStateMixin {
  final DiseaseController controller = Get.find();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;

  final Map<String, dynamic> _formData = {
    'ad': '',
    'belirtiler': <String>[],
    'riskSeviyesi': 'Orta',
    'aciklama': '',
    'hayvanTurleri': <String>[],
  };

  final List<String> _riskSeviyeleri = ['Düşük', 'Orta', 'Yüksek', 'Kritik'];
  final List<String> _tumBelirtiler = [
    'Ateş',
    'İştahsızlık',
    'Halsizlik',
    'Öksürük',
    'İshal',
    'Kusma',
    'Topallık',
    'Nefes Darlığı',
    'Kilo Kaybı',
    'Tüy Dökülmesi',
  ];
  final List<String> _hayvanTurleri = [
    'İnek',
    'Koyun',
    'Keçi',
    'Buzağı',
    'Kuzu',
    'Oğlak'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
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
          'Yeni Hastalık Kaydı',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: AnimationLimiter(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 600),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                _buildTextField(
                  label: 'Hastalık Adı',
                  onSaved: (value) => _formData['ad'] = value,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Hastalık adı gerekli' : null,
                ),
                const SizedBox(height: 16),
                _buildRiskLevelDropdown(),
                const SizedBox(height: 16),
                _buildSymptomsExpansionPanel(),
                const SizedBox(height: 16),
                _buildAnimalTypesExpansionPanel(),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Açıklama',
                  maxLines: 4,
                  onSaved: (value) => _formData['aciklama'] = value,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Açıklama gerekli' : null,
                ),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    int maxLines = 1,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildRiskLevelDropdown() {
    return DropdownButtonFormField<String>(
      value: _formData['riskSeviyesi'],
      decoration: InputDecoration(
        labelText: 'Risk Seviyesi',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: _riskSeviyeleri.map((seviye) {
        return DropdownMenuItem(
          value: seviye,
          child: Text(seviye),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _formData['riskSeviyesi'] = value;
        });
      },
    );
  }

  Widget _buildSymptomsExpansionPanel() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: const Text('Belirtiler'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tumBelirtiler.map((belirti) {
                return FilterChip(
                  label: Text(belirti),
                  selected: _formData['belirtiler'].contains(belirti),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _formData['belirtiler'].add(belirti);
                      } else {
                        _formData['belirtiler'].remove(belirti);
                      }
                    });
                  },
                  selectedColor: Colors.red.withOpacity(0.2),
                  checkmarkColor: Colors.red,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalTypesExpansionPanel() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: const Text('Hayvan Türleri'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _hayvanTurleri.map((tur) {
                return FilterChip(
                  label: Text(tur),
                  selected: _formData['hayvanTurleri'].contains(tur),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _formData['hayvanTurleri'].add(tur);
                      } else {
                        _formData['hayvanTurleri'].remove(tur);
                      }
                    });
                  },
                  selectedColor: Colors.red.withOpacity(0.2),
                  checkmarkColor: Colors.red,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Kaydet',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_formData['belirtiler'].isEmpty) {
        Get.snackbar(
          'Hata',
          'En az bir belirti seçmelisiniz',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (_formData['hayvanTurleri'].isEmpty) {
        Get.snackbar(
          'Hata',
          'En az bir hayvan türü seçmelisiniz',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final yeniHastalik = {
        'id': DateTime.now().millisecondsSinceEpoch,
        ..._formData,
      };

      controller.addHastalik(yeniHastalik);

      Get.back(result: true);
      Get.snackbar(
        'Başarılı',
        'Hastalık kaydı oluşturuldu',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }
}
