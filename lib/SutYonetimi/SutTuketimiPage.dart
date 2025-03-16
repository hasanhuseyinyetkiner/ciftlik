import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
* SutTuketimiPage - Süt Tüketimi Takip Sayfası
* --------------------------------------
* Bu sayfa, süt tüketiminin izlenmesi ve analiz
* edilmesini sağlar.
*
* Temel Özellikler:
* 1. Tüketim Kaydı:
*    - Tüketim miktarı
*    - Tüketim tarihi
*    - Tüketim tipi
*    - Alıcı bilgisi
*
* 2. Tüketim Analizi:
*    - Günlük tüketim
*    - Haftalık trend
*    - Aylık rapor
*    - Yıllık özet
*
* 3. Stok Yönetimi:
*    - Mevcut stok
*    - Minimum stok
*    - Stok rotasyonu
*    - Raf ömrü takibi
*
* 4. Satış Takibi:
*    - Müşteri bazlı
*    - Ürün bazlı
*    - Fiyat analizi
*    - Karlılık raporu
*
* 5. Planlama:
*    - Üretim planı
*    - Satış tahmini
*    - Tedarik zinciri
*    - Kapasite planı
*
* Özellikler:
* - Otomatik hesaplama
* - Stok uyarıları
* - Trend analizi
* - Tahminleme
*
* Entegrasyonlar:
* - StokController
* - SatisService
* - RaporlamaService
* - TahminlemeService
*/

/// Süt tüketimi takip sayfası
/// Bu sayfa, çiftlikte üretilen sütün nasıl tüketildiğini (iç tüketim, satış, kayıp)
/// detaylı olarak kaydetmek ve analiz etmek için kullanılır
class SutTuketimiPage extends StatefulWidget {
  const SutTuketimiPage({super.key});

  @override
  State<SutTuketimiPage> createState() => _SutTuketimiPageState();
}

class _SutTuketimiPageState extends State<SutTuketimiPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  // Tüketim tipleri
  final List<String> _tuketimTipleri = ['İç Tüketim', 'Satış', 'Kayıp'];
  String _selectedTuketimTipi = 'Tümü';

  // Örnek süt tüketim verileri
  final RxList<Map<String, dynamic>> _sutTuketimRecords =
      <Map<String, dynamic>>[
    {
      'id': 1,
      'date': '25/02/2023',
      'tuketimTipi': 'İç Tüketim',
      'miktar': 25.5,
      'birimFiyat': 0.0,
      'toplamDeger': 0.0,
      'notes': 'Buzağı beslemesi için'
    },
    {
      'id': 2,
      'date': '25/02/2023',
      'tuketimTipi': 'Satış',
      'miktar': 120.0,
      'birimFiyat': 12.50,
      'toplamDeger': 1500.0,
      'notes': 'Yerel mandıraya satış'
    },
    {
      'id': 3,
      'date': '26/02/2023',
      'tuketimTipi': 'Kayıp',
      'miktar': 5.0,
      'birimFiyat': 0.0,
      'toplamDeger': 0.0,
      'notes': 'Soğutma sistemi arızası'
    },
    {
      'id': 4,
      'date': '27/02/2023',
      'tuketimTipi': 'Satış',
      'miktar': 140.0,
      'birimFiyat': 13.0,
      'toplamDeger': 1820.0,
      'notes': 'Yerel mandıraya satış'
    },
  ].obs;

  // Filtreleme
  RxList<Map<String, dynamic>> get filteredRecords {
    if (_searchController.text.isEmpty && _selectedTuketimTipi == 'Tümü') {
      return _sutTuketimRecords;
    }

    final searchTerm = _searchController.text.toLowerCase();
    return _sutTuketimRecords
        .where((record) {
          // Önce tip filtresi uygula
          bool typeMatch = _selectedTuketimTipi == 'Tümü' ||
              record['tuketimTipi'] == _selectedTuketimTipi;

          // Sonra arama terimi filtresi uygula
          bool searchMatch = searchTerm.isEmpty ||
              record['date'].toString().toLowerCase().contains(searchTerm) ||
              record['tuketimTipi']
                  .toString()
                  .toLowerCase()
                  .contains(searchTerm) ||
              record['notes'].toString().toLowerCase().contains(searchTerm);

          return typeMatch && searchMatch;
        })
        .toList()
        .obs;
  }

  // Özet istatistikler
  Map<String, dynamic> get tuketimOzeti {
    double toplamSatis = 0;
    double toplamIcTuketim = 0;
    double toplamKayip = 0;
    double toplamGelir = 0;

    for (var record in _sutTuketimRecords) {
      if (record['tuketimTipi'] == 'Satış') {
        toplamSatis += record['miktar'] as double;
        toplamGelir += record['toplamDeger'] as double;
      } else if (record['tuketimTipi'] == 'İç Tüketim') {
        toplamIcTuketim += record['miktar'] as double;
      } else if (record['tuketimTipi'] == 'Kayıp') {
        toplamKayip += record['miktar'] as double;
      }
    }

    double toplamUretim = toplamSatis + toplamIcTuketim + toplamKayip;

    return {
      'toplamUretim': toplamUretim,
      'toplamSatis': toplamSatis,
      'toplamIcTuketim': toplamIcTuketim,
      'toplamKayip': toplamKayip,
      'toplamGelir': toplamGelir,
      'satisOrani': toplamUretim > 0 ? (toplamSatis / toplamUretim * 100) : 0,
      'icTuketimOrani':
          toplamUretim > 0 ? (toplamIcTuketim / toplamUretim * 100) : 0,
      'kayipOrani': toplamUretim > 0 ? (toplamKayip / toplamUretim * 100) : 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Süt Tüketimi Takibi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Arama ve filtreleme
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    cursorColor: Colors.black54,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Tarih veya not ara',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {}); // Arama terimine göre listeyi filtrele
                    },
                    onTapOutside: (event) {
                      _searchFocusNode.unfocus();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 56, // TextField ile aynı yükseklik
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedTuketimTipi,
                        items: ['Tümü', ..._tuketimTipleri].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTuketimTipi = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tüketim özeti kartı
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Süt Tüketimi Özeti',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatColumn(
                            'Toplam Üretim',
                            '${tuketimOzeti['toplamUretim'].toStringAsFixed(1)} L',
                            Icons.water_drop,
                            Colors.blue),
                        _buildStatColumn(
                            'Toplam Satış',
                            '${tuketimOzeti['toplamSatis'].toStringAsFixed(1)} L',
                            Icons.monetization_on,
                            Colors.green),
                        _buildStatColumn(
                            'İç Tüketim',
                            '${tuketimOzeti['toplamIcTuketim'].toStringAsFixed(1)} L',
                            Icons.home,
                            Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatColumn(
                              'Kayıp',
                              '${tuketimOzeti['toplamKayip'].toStringAsFixed(1)} L',
                              Icons.cancel,
                              Colors.red),
                        ),
                        Expanded(
                          child: _buildStatColumn(
                              'Toplam Gelir',
                              '${tuketimOzeti['toplamGelir'].toStringAsFixed(2)} TL',
                              Icons.attach_money,
                              Colors.deepPurple),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Dağılım çubuğu
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          // Satış
                          Flexible(
                            flex: tuketimOzeti['satisOrani'].round(),
                            child: Container(color: Colors.green),
                          ),
                          // İç tüketim
                          Flexible(
                            flex: tuketimOzeti['icTuketimOrani'].round(),
                            child: Container(color: Colors.orange),
                          ),
                          // Kayıp
                          Flexible(
                            flex: tuketimOzeti['kayipOrani'].round(),
                            child: Container(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Lejant
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem('Satış', Colors.green),
                        const SizedBox(width: 16),
                        _buildLegendItem('İç Tüketim', Colors.orange),
                        const SizedBox(width: 16),
                        _buildLegendItem('Kayıp', Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tüketim kayıtları listesi
            Expanded(
              child: Obx(() {
                if (filteredRecords.isEmpty) {
                  return const Center(
                    child: Text('Süt tüketimi kaydı bulunamadı'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    return _buildTuketimCard(record);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTuketimDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatColumn(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTuketimCard(Map<String, dynamic> record) {
    Color typeColor;
    IconData typeIcon;

    // Tüketim tipine göre renk ve ikon belirleme
    switch (record['tuketimTipi']) {
      case 'Satış':
        typeColor = Colors.green;
        typeIcon = Icons.monetization_on;
        break;
      case 'İç Tüketim':
        typeColor = Colors.orange;
        typeIcon = Icons.home;
        break;
      case 'Kayıp':
        typeColor = Colors.red;
        typeIcon = Icons.cancel;
        break;
      default:
        typeColor = Colors.blue;
        typeIcon = Icons.water_drop;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(typeIcon, color: typeColor, size: 36),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        record['tuketimTipi'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                      Text(
                        record['date'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Miktar: ${record['miktar']} Litre',
                    style: const TextStyle(fontSize: 15),
                  ),
                  if (record['tuketimTipi'] == 'Satış') ...[
                    const SizedBox(height: 4),
                    Text(
                      'Birim Fiyat: ${record['birimFiyat']} TL/L',
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toplam Değer: ${record['toplamDeger']} TL',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                  if (record['notes'] != null &&
                      record['notes'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Not: ${record['notes']}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTuketimDialog(BuildContext context) {
    final tuketimTipiController = TextEditingController();
    final miktarController = TextEditingController();
    final birimFiyatController = TextEditingController();
    final notesController = TextEditingController();
    String selectedType = _tuketimTipleri[0]; // Varsayılan olarak ilk tipi seç

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: const Text('Yeni Süt Tüketimi Kaydı'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Tüketim Tipi',
                  ),
                  value: selectedType,
                  items: _tuketimTipleri.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                TextField(
                  controller: miktarController,
                  decoration: const InputDecoration(
                    labelText: 'Miktar (Litre)',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                if (selectedType == 'Satış')
                  TextField(
                    controller: birimFiyatController,
                    decoration: const InputDecoration(
                      labelText: 'Birim Fiyat (TL/L)',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notlar',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                // Basit doğrulama
                if (miktarController.text.isEmpty ||
                    (selectedType == 'Satış' &&
                        birimFiyatController.text.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gerekli alanları doldurun')),
                  );
                  return;
                }

                // Miktar ve birim fiyat hesaplama
                final double miktar = double.parse(miktarController.text);
                double birimFiyat = 0;
                double toplamDeger = 0;

                if (selectedType == 'Satış') {
                  birimFiyat = double.parse(birimFiyatController.text);
                  toplamDeger = miktar * birimFiyat;
                }

                // Yeni kayıt ekle
                _sutTuketimRecords.add({
                  'id': _sutTuketimRecords.length + 1,
                  'date':
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  'tuketimTipi': selectedType,
                  'miktar': miktar,
                  'birimFiyat': birimFiyat,
                  'toplamDeger': toplamDeger,
                  'notes': notesController.text,
                });

                Navigator.pop(context);

                // Başarı mesajı göster
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Süt tüketimi kaydı eklendi')),
                );
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      }),
    );
  }
}
