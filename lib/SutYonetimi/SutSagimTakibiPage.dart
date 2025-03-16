import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
* SutSagimTakibiPage - Süt Sağım Takip Sayfası
* ---------------------------------------
* Bu sayfa, süt sağım işlemlerinin detaylı takibini ve
* kayıt altına alınmasını sağlar.
*
* Temel Özellikler:
* 1. Sağım Kaydı:
*    - Sağım zamanı
*    - Sağım miktarı
*    - Sağım yöntemi
*    - Sağımcı bilgisi
*
* 2. Hayvan Takibi:
*    - Sağım sırası
*    - Sağım durumu
*    - Sağım geçmişi
*    - Verim analizi
*
* 3. Sağım Planı:
*    - Günlük program
*    - Vardiya planı
*    - Rotasyon
*    - Önceliklendirme
*
* 4. Kalite Kontrol:
*    - Hijyen kontrolü
*    - Ekipman durumu
*    - Süt kalitesi
*    - Anomali tespiti
*
* 5. Raporlama:
*    - Vardiya raporu
*    - Verimlilik analizi
*    - Kalite raporu
*    - Trend analizi
*
* Özellikler:
* - Gerçek zamanlı takip
* - Otomatik hesaplama
* - Uyarı sistemi
* - Veri senkronizasyonu
*
* Entegrasyonlar:
* - SagimController
* - KaliteService
* - PlanlamaService
* - RaporlamaService
*/

/// Süt sağım takibi sayfası
/// Bu sayfa, süt sağım sürecini, ekipman performansını ve sağım verimini
/// detaylı olarak takip etmek için kullanılır
class SutSagimTakibiPage extends StatefulWidget {
  const SutSagimTakibiPage({super.key});

  @override
  State<SutSagimTakibiPage> createState() => _SutSagimTakibiPageState();
}

class _SutSagimTakibiPageState extends State<SutSagimTakibiPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Rx<DateTime> _selectedDate = DateTime.now().obs;

  // Aktif sağım durumu
  final RxBool _sagimAktif = false.obs;
  final Rx<DateTime?> _sagimBaslangicZamani = Rx<DateTime?>(null);
  final RxString _seciliEkipman = ''.obs;
  final RxString _seciliPersonel = ''.obs;

  // Sağım öncesi kontrol listesi
  final RxList<Map<String, dynamic>> _kontrolListesi = <Map<String, dynamic>>[
    {'id': 1, 'baslik': 'Meme temizliği', 'tamamlandi': false},
    {'id': 2, 'baslik': 'Ön sağım', 'tamamlandi': false},
    {'id': 3, 'baslik': 'Ekipman kontrolü', 'tamamlandi': false},
    {'id': 4, 'baslik': 'Meme başı dezenfeksiyonu', 'tamamlandi': false},
  ].obs;

  // Sağım ekipmanları
  final List<String> _ekipmanlar = [
    'Makine 1',
    'Makine 2',
    'Makine 3',
    'Elle Sağım'
  ];

  // Sağım personeli
  final List<String> _personeller = [
    'Ahmet Yılmaz',
    'Mehmet Demir',
    'Ayşe Kaya'
  ];

  // Örnek sağım kayıtları
  final RxList<Map<String, dynamic>> _sagimKayitlari = <Map<String, dynamic>>[
    {
      'id': 1,
      'date': '25/02/2023',
      'baslangicZamani': '06:30',
      'bitisZamani': '07:45',
      'toplamSure': '1 saat 15 dk',
      'ekipman': 'Makine 1',
      'personel': 'Ahmet Yılmaz',
      'toplamSutMiktari': 145.5,
      'sagimHizi': 1.94, // Litre/dakika
      'hayvanSayisi': 12,
      'notlar': 'Normal sağım, sorun yok'
    },
    {
      'id': 2,
      'date': '25/02/2023',
      'baslangicZamani': '16:30',
      'bitisZamani': '17:40',
      'toplamSure': '1 saat 10 dk',
      'ekipman': 'Makine 1',
      'personel': 'Mehmet Demir',
      'toplamSutMiktari': 130.0,
      'sagimHizi': 1.86, // Litre/dakika
      'hayvanSayisi': 12,
      'notlar': 'Makine 1 vakum sorunları var, kontrol edilmeli'
    },
    {
      'id': 3,
      'date': '26/02/2023',
      'baslangicZamani': '06:30',
      'bitisZamani': '07:55',
      'toplamSure': '1 saat 25 dk',
      'ekipman': 'Makine 2',
      'personel': 'Ahmet Yılmaz',
      'toplamSutMiktari': 155.0,
      'sagimHizi': 1.82, // Litre/dakika
      'hayvanSayisi': 14,
      'notlar': 'Makine 1 onarımda, Makine 2 kullanıldı'
    },
  ].obs;

  // Filtreleme fonksiyonu
  RxList<Map<String, dynamic>> get filteredSagimKayitlari {
    if (_searchController.text.isEmpty) {
      // Sadece tarih filtresi uygula
      final selectedDateStr =
          '${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}';
      return _sagimKayitlari
          .where((record) => record['date'] == selectedDateStr)
          .toList()
          .obs;
    }

    // Hem tarih hem de arama filtresi uygula
    final searchTerm = _searchController.text.toLowerCase();
    final selectedDateStr =
        '${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}';

    return _sagimKayitlari
        .where((record) =>
            record['date'] == selectedDateStr &&
            (record['ekipman'].toString().toLowerCase().contains(searchTerm) ||
                record['personel']
                    .toString()
                    .toLowerCase()
                    .contains(searchTerm) ||
                record['notlar'].toString().toLowerCase().contains(searchTerm)))
        .toList()
        .obs;
  }

  // Sağım başlatma fonksiyonu
  void _sagimBaslat() {
    // Tüm kontrol listesi öğeleri tamamlanmış mı kontrol et
    bool tumKontrollerTamamlandi =
        _kontrolListesi.every((kontrol) => kontrol['tamamlandi'] == true);

    if (!tumKontrollerTamamlandi) {
      Get.snackbar(
        'Uyarı',
        'Sağım başlatmadan önce tüm kontrol listesini tamamlayın',
        backgroundColor: Colors.orange.withOpacity(0.2),
        colorText: Colors.orange[800],
      );
      return;
    }

    if (_seciliEkipman.value.isEmpty) {
      Get.snackbar(
        'Uyarı',
        'Lütfen sağım ekipmanı seçin',
        backgroundColor: Colors.orange.withOpacity(0.2),
        colorText: Colors.orange[800],
      );
      return;
    }

    if (_seciliPersonel.value.isEmpty) {
      Get.snackbar(
        'Uyarı',
        'Lütfen sağım personeli seçin',
        backgroundColor: Colors.orange.withOpacity(0.2),
        colorText: Colors.orange[800],
      );
      return;
    }

    _sagimAktif.value = true;
    _sagimBaslangicZamani.value = DateTime.now();

    Get.snackbar(
      'Bilgi',
      'Sağım başlatıldı',
      backgroundColor: Colors.green.withOpacity(0.2),
      colorText: Colors.green[800],
    );
  }

  // Sağım bitirme fonksiyonu
  void _sagimBitir(BuildContext context) {
    if (_sagimBaslangicZamani.value == null) {
      return;
    }

    _showSagimSonucDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Süt Sağım Takibi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarih seçici
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Obx(() => Text(
                          '${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate.value,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );

                        if (picked != null) {
                          _selectedDate.value = picked;
                        }
                      },
                      child: const Text('Tarih Seç'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Arama
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              cursorColor: Colors.black54,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Ekipman, personel veya not ara',
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

            const SizedBox(height: 16),

            // Sağım Yönetimi Kartı
            Obx(() => Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _sagimAktif.value
                          ? Colors.green
                          : Colors.grey.shade300,
                      width: _sagimAktif.value ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Sağım Yönetimi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: _sagimAktif.value
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                              ),
                              child: Text(
                                _sagimAktif.value
                                    ? 'Sağım Aktif'
                                    : 'Sağım Beklemede',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _sagimAktif.value
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (!_sagimAktif.value) ...[
                          // Sağım yapılmıyorsa kontroller ve başlat butonu
                          _buildEkipmanSecimi(),
                          const SizedBox(height: 12),
                          _buildPersonelSecimi(),
                          const SizedBox(height: 16),

                          const Text(
                            'Sağım Öncesi Kontrol Listesi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Kontrol listesi
                          ...List.generate(_kontrolListesi.length, (index) {
                            final kontrol = _kontrolListesi[index];
                            return CheckboxListTile(
                              title: Text(kontrol['baslik']),
                              value: kontrol['tamamlandi'] as bool,
                              activeColor: Colors.green,
                              onChanged: (value) {
                                _kontrolListesi[index]['tamamlandi'] = value;
                                setState(() {});
                              },
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            );
                          }),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _sagimBaslat,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Sağımı Başlat'),
                            ),
                          ),
                        ] else ...[
                          // Sağım aktifken süre ve durum gösterimi
                          Row(
                            children: [
                              _buildInfoItem('Ekipman', _seciliEkipman.value),
                              const SizedBox(width: 16),
                              _buildInfoItem('Personel', _seciliPersonel.value),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              const Icon(Icons.timer, color: Colors.blue),
                              const SizedBox(width: 8),
                              const Text(
                                'Başlangıç: ',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                _formatDateTime(_sagimBaslangicZamani.value!),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    // Sağımı iptal et
                                    _sagimAktif.value = false;
                                    _sagimBaslangicZamani.value = null;

                                    // Kontrol listesini sıfırla
                                    for (var i = 0;
                                        i < _kontrolListesi.length;
                                        i++) {
                                      _kontrolListesi[i]['tamamlandi'] = false;
                                    }

                                    Get.snackbar(
                                      'Bilgi',
                                      'Sağım iptal edildi',
                                      backgroundColor:
                                          Colors.red.withOpacity(0.2),
                                      colorText: Colors.red[800],
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: const Text('İptal Et'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _sagimBitir(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: const Text('Sağımı Bitir'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                )),

            const SizedBox(height: 16),

            // Sağım Kayıtları (ListView)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sağım Kayıtları',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Obx(() {
                      final filtered = filteredSagimKayitlari;

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text('Bu tarih için sağım kaydı bulunamadı'),
                        );
                      }

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final record = filtered[index];
                          return _buildSagimKayitCard(record);
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ekipman seçimi dropdown'ı
  Widget _buildEkipmanSecimi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ekipman Seçimi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Sağım Ekipmanı Seçin'),
              value: _seciliEkipman.value.isEmpty ? null : _seciliEkipman.value,
              items: _ekipmanlar.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _seciliEkipman.value = value;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // Personel seçimi dropdown'ı
  Widget _buildPersonelSecimi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personel Seçimi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Sağım Personeli Seçin'),
              value:
                  _seciliPersonel.value.isEmpty ? null : _seciliPersonel.value,
              items: _personeller.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _seciliPersonel.value = value;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // Info item builder
  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Sağım kaydı kartı
  Widget _buildSagimKayitCard(Map<String, dynamic> record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${record['baslangicZamani']} - ${record['bitisZamani']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record['toplamSure'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Sağım detayları
            Row(
              children: [
                Expanded(
                  child: _buildSagimDetay('Ekipman', record['ekipman']),
                ),
                Expanded(
                  child: _buildSagimDetay('Personel', record['personel']),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildSagimDetay(
                      'Toplam Süt', '${record['toplamSutMiktari']} L'),
                ),
                Expanded(
                  child: _buildSagimDetay(
                      'Sağım Hızı', '${record['sagimHizi']} L/dk'),
                ),
                Expanded(
                  child: _buildSagimDetay(
                      'Hayvan Sayısı', '${record['hayvanSayisi']}'),
                ),
              ],
            ),

            if (record['notlar'] != null &&
                record['notlar'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Not: ${record['notlar']}',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Sağım detay builder
  Widget _buildSagimDetay(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Sağım bitiş diyaloğunu göster
  void _showSagimSonucDialog(BuildContext context) {
    final TextEditingController hayvanSayisiController =
        TextEditingController();
    final TextEditingController sutMiktariController = TextEditingController();
    final TextEditingController notlarController = TextEditingController();

    final DateTime baslangicZamani = _sagimBaslangicZamani.value!;
    final DateTime bitisZamani = DateTime.now();

    // Süreyi hesapla
    final Duration sure = bitisZamani.difference(baslangicZamani);
    final int saat = sure.inHours;
    final int dakika = sure.inMinutes % 60;
    final String sureText = '$saat saat $dakika dk';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sağım Sonucu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogInfoRow(
                  'Başlangıç', _formatDateTime(baslangicZamani)),
              _buildDialogInfoRow('Bitiş', _formatDateTime(bitisZamani)),
              _buildDialogInfoRow('Toplam Süre', sureText),
              _buildDialogInfoRow('Ekipman', _seciliEkipman.value),
              _buildDialogInfoRow('Personel', _seciliPersonel.value),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              TextField(
                controller: hayvanSayisiController,
                decoration: const InputDecoration(
                  labelText: 'Sağılan Hayvan Sayısı',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sutMiktariController,
                decoration: const InputDecoration(
                  labelText: 'Toplam Süt Miktarı (Litre)',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notlarController,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                  border: OutlineInputBorder(),
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
              // Başka doğrulamalar eklenebilir
              if (hayvanSayisiController.text.isEmpty ||
                  sutMiktariController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Hayvan sayısı ve süt miktarı gereklidir')),
                );
                return;
              }

              // Yeni kaydı ekle
              final int hayvanSayisi = int.parse(hayvanSayisiController.text);
              final double sutMiktari = double.parse(sutMiktariController.text);

              // Sağım hızını hesapla (litre/dakika)
              final double sagimHizi = sutMiktari / sure.inMinutes;

              _sagimKayitlari.add({
                'id': _sagimKayitlari.length + 1,
                'date':
                    '${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}',
                'baslangicZamani':
                    '${baslangicZamani.hour.toString().padLeft(2, '0')}:${baslangicZamani.minute.toString().padLeft(2, '0')}',
                'bitisZamani':
                    '${bitisZamani.hour.toString().padLeft(2, '0')}:${bitisZamani.minute.toString().padLeft(2, '0')}',
                'toplamSure': sureText,
                'ekipman': _seciliEkipman.value,
                'personel': _seciliPersonel.value,
                'toplamSutMiktari': sutMiktari,
                'sagimHizi': double.parse(sagimHizi.toStringAsFixed(2)),
                'hayvanSayisi': hayvanSayisi,
                'notlar': notlarController.text,
              });

              // Sağım durumunu sıfırla
              _sagimAktif.value = false;
              _sagimBaslangicZamani.value = null;

              // Kontrol listesini sıfırla
              for (var i = 0; i < _kontrolListesi.length; i++) {
                _kontrolListesi[i]['tamamlandi'] = false;
              }

              Navigator.pop(context);

              Get.snackbar(
                'Başarılı',
                'Sağım kaydı eklendi',
                backgroundColor: Colors.green.withOpacity(0.2),
                colorText: Colors.green[800],
              );
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  // Dialog info row
  Widget _buildDialogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  // Tarih saat formatla
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
