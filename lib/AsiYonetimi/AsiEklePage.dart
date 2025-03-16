import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'AsiTakvimiController.dart';

class AsiEklePage extends StatefulWidget {
  const AsiEklePage({Key? key}) : super(key: key);

  @override
  State<AsiEklePage> createState() => _AsiEklePageState();
}

class _AsiEklePageState extends State<AsiEklePage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _asiController = Get.find<AsiTakvimiController>();

  late AnimationController _titleAnimationController;
  late AnimationController _formAnimationController;
  late Animation<double> _titleOpacity;
  late List<Animation<Offset>> _formFieldSlideAnimations;

  final _hayvanController = TextEditingController();
  final _asiTuruController = TextEditingController();
  final _notlarController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedHayvanTuru;
  String? _selectedAsiTuru;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _titleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _titleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: Curves.easeOut,
    ));

    _formAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _formFieldSlideAnimations = List.generate(
      5,
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _formAnimationController,
        curve: Interval(
          index * 0.2,
          0.2 + index * 0.2,
          curve: Curves.easeOut,
        ),
      )),
    );

    _titleAnimationController.forward();
    _formAnimationController.forward();
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    _formAnimationController.dispose();
    _hayvanController.dispose();
    _asiTuruController.dispose();
    _notlarController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveAsi() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedHayvanTuru == null || _selectedAsiTuru == null) {
      Get.snackbar(
        'Hata',
        'Lutfen tum alanlari doldurun',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final yeniAsi = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'hayvanId': _hayvanController.text,
      'hayvanTuru': _selectedHayvanTuru!,
      'asiTuru': _selectedAsiTuru!,
      'tarih': _selectedDate!.toIso8601String(),
      'notlar': _notlarController.text,
      'oncelik': 'normal',
      'durum': 'bekliyor',
    };

    _asiController.addAsiKaydi(yeniAsi);

    setState(() {
      _isLoading = false;
    });

    await Future.delayed(const Duration(seconds: 1));

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Asi Kaydi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FadeTransition(
                opacity: _titleOpacity,
                child: const Text(
                  'Yeni Asi Kaydi',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              SlideTransition(
                position: _formFieldSlideAnimations[0],
                child: TextFormField(
                  controller: _hayvanController,
                  decoration: const InputDecoration(
                    labelText: 'Hayvan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lutfen hayvan bilgisini girin';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              SlideTransition(
                position: _formFieldSlideAnimations[1],
                child: DropdownButtonFormField<String>(
                  value: _selectedHayvanTuru,
                  decoration: const InputDecoration(
                    labelText: 'Hayvan Turu',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Buyukbas', 'Kucukbas', 'Kanatli']
                      .map((tur) => DropdownMenuItem<String>(
                            value: tur,
                            child: Text(tur),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedHayvanTuru = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Lutfen hayvan turunu secin';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              SlideTransition(
                position: _formFieldSlideAnimations[2],
                child: DropdownButtonFormField<String>(
                  value: _selectedAsiTuru,
                  decoration: const InputDecoration(
                    labelText: 'Asi Turu',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Sap', 'Kuduz', 'Brucella']
                      .map((tur) => DropdownMenuItem<String>(
                            value: tur,
                            child: Text(tur),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAsiTuru = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Lutfen asi turunu secin';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              SlideTransition(
                position: _formFieldSlideAnimations[3],
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Uygulama Tarihi',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? 'Tarih Secin'
                          : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SlideTransition(
                position: _formFieldSlideAnimations[4],
                child: TextFormField(
                  controller: _notlarController,
                  decoration: const InputDecoration(
                    labelText: 'Notlar',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveAsi,
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
