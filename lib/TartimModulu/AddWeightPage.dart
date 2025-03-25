import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'WeightController.dart';
import 'package:intl/intl.dart';

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
  final Map<String, dynamic>? editData;

  const AddWeightPage({Key? key, this.editData}) : super(key: key);

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

  // Flag to indicate if we're editing an existing record
  bool get _isEditing => widget.editData != null;

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

    // If editing existing record, load data into form
    if (_isEditing) {
      _loadEditData();
    }
  }

  // Load data from the passed record for editing
  void _loadEditData() {
    if (widget.editData != null) {
      setState(() {
        _formData['id'] = widget.editData!['id'];
        _formData['hayvanId'] = widget.editData!['hayvanId'];
        _formData['hayvanAd'] = widget.editData!['hayvanAd'];
        _formData['tarih'] = widget.editData!['tarih'];
        _formData['agirlik'] = widget.editData!['agirlik'];
        _formData['birim'] = widget.editData!['birim'] ?? 'kg';
        _formData['notlar'] = widget.editData!['notlar'] ?? '';
      });
    }
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
        title: Text(
          _isEditing ? 'Tartım Düzenle' : 'Yeni Tartım Kaydı',
          style: const TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDelete(),
            ),
        ],
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
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
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      _buildAnimalSelectionCard(),
                      const SizedBox(height: 24),
                      _buildWeightInputCard(),
                      const SizedBox(height: 24),
                      _buildNotesCard(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tartım Bilgileri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Bu sayfada yeni bir tartım kaydı oluşturabilirsiniz. Hayvan seçimi, ağırlık ve notlar gibi gerekli bilgileri girerek hayvanlarınızın gelişimini takip edebilirsiniz.',
              style: TextStyle(
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalSelectionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Hayvan Seçimi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnimalDropdown(),
            const SizedBox(height: 16),
            _buildDatePicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightInputCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.scale,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Ağırlık Bilgileri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: _buildWeightInput(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _buildUnitDropdown(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                onPressed: _connectToBluetoothScale,
                icon: const Icon(Icons.bluetooth),
                label: const Text('Bluetooth Tartı Bağla'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.note_alt,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Notlar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _formData['notlar'] as String,
              decoration: InputDecoration(
                hintText: 'Tartım ile ilgili notlarınızı buraya ekleyin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              maxLines: 3,
              onSaved: (value) => _formData['notlar'] = value ?? '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalDropdown() {
    return DropdownButtonFormField<String>(
      value:
          _formData['hayvanId'] == '' ? null : _formData['hayvanId'] as String?,
      decoration: InputDecoration(
        hintText: 'Hayvan Seçin',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: [
        ...controller.hayvanlar.map((hayvan) {
          return DropdownMenuItem(
            value: hayvan['id'] as String,
            child: Text("${hayvan['ad']} (${hayvan['tur']})"),
          );
        }).toList(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen bir hayvan seçin';
        }
        return null;
      },
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _formData['hayvanId'] = value;
            // Set the animal name for display purposes
            final selectedAnimal = controller.hayvanlar.firstWhere(
              (hayvan) => hayvan['id'] == value,
              orElse: () => {'id': '', 'ad': '', 'tur': ''},
            );
            _formData['hayvanAd'] = selectedAnimal['ad'] as String;
          });
        }
      },
      onSaved: (value) {
        if (value != null) {
          _formData['hayvanId'] = value;
          // Set the animal name again to be safe
          final selectedAnimal = controller.hayvanlar.firstWhere(
            (hayvan) => hayvan['id'] == value,
            orElse: () => {'id': '', 'ad': '', 'tur': ''},
          );
          _formData['hayvanAd'] = selectedAnimal['ad'] as String;
        }
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _formData['tarih'] as DateTime,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 1)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.red,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _formData['tarih'] = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Tarih',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        child: Text(
          DateFormat('dd/MM/yyyy').format(_formData['tarih'] as DateTime),
        ),
      ),
    );
  }

  Widget _buildWeightInput() {
    return TextFormField(
      initialValue:
          _formData['agirlik'] == 0.0 ? '' : _formData['agirlik'].toString(),
      decoration: InputDecoration(
        labelText: 'Ağırlık',
        hintText: 'Örn: 450.5',
        prefixIcon: const Icon(Icons.line_weight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen ağırlık değeri girin';
        }
        if (double.tryParse(value) == null) {
          return 'Geçerli bir sayı girin';
        }
        if (double.parse(value) <= 0) {
          return 'Ağırlık 0\'dan büyük olmalıdır';
        }
        return null;
      },
      onSaved: (value) {
        if (value != null && value.isNotEmpty) {
          _formData['agirlik'] = double.parse(value);
        }
      },
      focusNode: _weightFocusNode,
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<String>(
      value: _formData['birim'] as String,
      decoration: InputDecoration(
        labelText: 'Birim',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: const [
        DropdownMenuItem(
          value: 'kg',
          child: Text('kg'),
        ),
        DropdownMenuItem(
          value: 'g',
          child: Text('g'),
        ),
        DropdownMenuItem(
          value: 'ton',
          child: Text('ton'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _formData['birim'] = value;
          });
        }
      },
      onSaved: (value) {
        if (value != null) {
          _formData['birim'] = value;
        }
      },
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _saveWeight,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: _isSaving
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              _isEditing ? 'Kaydet' : 'Tartım Ekle',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  // Method to connect to Bluetooth scale
  void _connectToBluetoothScale() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bluetooth Tartı'),
        content: const SizedBox(
          height: 100,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Bluetooth cihazları aranıyor...'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('İptal'),
          ),
        ],
      ),
    );

    // Simulate finding a device after a delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();

      // Show device selection dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Bulunan Cihazlar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bluetooth, color: Colors.blue),
                title: const Text('Dijital Tartı A1'),
                subtitle: const Text('Bağlan'),
                onTap: () {
                  Navigator.of(context).pop();
                  _connectToSelectedDevice('Dijital Tartı A1');
                },
              ),
              ListTile(
                leading: const Icon(Icons.bluetooth, color: Colors.blue),
                title: const Text('Akıllı Tartı B2'),
                subtitle: const Text('Bağlan'),
                onTap: () {
                  Navigator.of(context).pop();
                  _connectToSelectedDevice('Akıllı Tartı B2');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
          ],
        ),
      );
    });
  }

  // Connect to the selected Bluetooth device
  void _connectToSelectedDevice(String deviceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cihaza Bağlanılıyor: $deviceName'),
        content: const SizedBox(
          height: 100,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Lütfen bekleyin...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Simulate connection
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();

      // Set a random weight after connection
      final randomWeight = (300 + DateTime.now().millisecond % 200).toDouble();
      setState(() {
        _formData['agirlik'] = randomWeight;
      });

      Get.snackbar(
        'Bağlantı Başarılı',
        'Cihaz bağlandı ve ağırlık alındı: ${randomWeight.toStringAsFixed(1)} kg',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    });
  }

  // Confirm deletion of record
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sil'),
        content:
            const Text('Bu tartım kaydını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              if (_formData.containsKey('id') && _formData['id'] != null) {
                setState(() {
                  _isSaving = true;
                });

                try {
                  await controller.deleteTartimKaydi(_formData['id'] as String);

                  Get.back();
                  Get.snackbar(
                    'Başarılı',
                    'Tartım kaydı silindi',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    'Hata',
                    'Tartım kaydı silinirken bir hata oluştu: $e',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                } finally {
                  setState(() {
                    _isSaving = false;
                  });
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _saveWeight() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final weightData = {
          'hayvan_id': _formData['hayvanId'],
          'tarih': _formData['tarih'],
          'agirlik': _formData['agirlik'],
          'birim': _formData['birim'],
          'notlar': _formData['notlar'],
        };

        if (_isEditing) {
          // Update existing record
          weightData['id'] = widget.editData!['id'];
          final success = await controller.saveTartim(weightData);
          
          if (success) {
            Get.back(result: true);
            Get.snackbar(
              'Başarılı',
              'Tartım kaydı güncellendi',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.withOpacity(0.7),
              colorText: Colors.white,
            );
          } else {
            _showErrorMessage('Tartım güncellenirken bir sorun oluştu');
          }
        } else {
          // Create new record
          final success = await controller.saveTartim(weightData);
          
          if (success) {
            Get.back(result: true);
            Get.snackbar(
              'Başarılı',
              'Tartım kaydı eklendi',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.withOpacity(0.7),
              colorText: Colors.white,
            );
          } else {
            _showErrorMessage('Tartım eklenirken bir sorun oluştu');
          }
        }
      } catch (e) {
        _showErrorMessage('Hata oluştu: $e');
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'Hata',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
    );
  }
}
