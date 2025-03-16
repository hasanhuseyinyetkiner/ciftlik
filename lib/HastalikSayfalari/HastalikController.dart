import 'package:get/get.dart';

class HastalikController extends GetxController {
  // Hastalık kayıtları
  final RxList<Map<String, dynamic>> hastalikKayitlari =
      <Map<String, dynamic>>[].obs;

  // Hastalık türleri
  final RxList<Map<String, dynamic>> hastalikTurleri = <Map<String, dynamic>>[
    {
      'id': '1',
      'ad': 'Şap Hastalığı',
      'tur': 'Solunum',
      'belirtiler': 'Ateş, ağız ve ayaklarda yaralar, topallık',
      'aciklama':
          'Viral bir hastalıktır. Hızlı yayılır ve ciddi ekonomik kayıplara neden olabilir.',
    },
    {
      'id': '2',
      'ad': 'Mastitis',
      'tur': 'Metabolik',
      'belirtiler': 'Memede şişlik, sütte değişiklik, ateş',
      'aciklama':
          'Meme dokusunun iltihaplanmasıdır. Süt verimini ve kalitesini etkiler.',
    },
    {
      'id': '3',
      'ad': 'İç Parazitler',
      'tur': 'Paraziter',
      'belirtiler': 'Kilo kaybı, ishal, tüylerde matlaşma',
      'aciklama':
          'Sindirim sisteminde yaşayan parazitlerin neden olduğu hastalıklardır.',
    },
    {
      'id': '4',
      'ad': 'Enterit',
      'tur': 'Sindirim',
      'belirtiler': 'İshal, iştahsızlık, halsizlik',
      'aciklama': 'Bağırsak iltihabıdır. Viral veya bakteriyel olabilir.',
    },
  ].obs;

  // Filtreler
  final RxString searchQuery = ''.obs;
  final RxString selectedHastalikTuru = 'Tümü'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Örnek hastalık kayıtları
    hastalikKayitlari.addAll([
      {
        'id': '1',
        'hayvanId': '1234',
        'hayvanTuru': 'İnek',
        'hastalikId': '1',
        'baslangicTarihi': DateTime.now().subtract(const Duration(days: 5)),
        'belirtiler': ['Ateş', 'Topallık', 'Ağızda yaralar'],
        'tedavi': 'Antibiyotik tedavisi ve yara bakımı',
        'durum': 'devam',
      },
      {
        'id': '2',
        'hayvanId': '5678',
        'hayvanTuru': 'Koyun',
        'hastalikId': '3',
        'baslangicTarihi': DateTime.now().subtract(const Duration(days: 10)),
        'belirtiler': ['Kilo kaybı', 'İshal'],
        'tedavi': 'Antiparaziter ilaç uygulaması',
        'durum': 'tamamlandi',
      },
    ]);
  }

  // CRUD işlemleri
  void addHastalikKaydi(Map<String, dynamic> kayit) {
    hastalikKayitlari.add(kayit);
    hastalikKayitlari.refresh();
  }

  void updateHastalikKaydi(String id, Map<String, dynamic> yeniKayit) {
    final index = hastalikKayitlari.indexWhere((kayit) => kayit['id'] == id);
    if (index != -1) {
      hastalikKayitlari[index] = yeniKayit;
      hastalikKayitlari.refresh();
    }
  }

  void deleteHastalikKaydi(String id) {
    hastalikKayitlari.removeWhere((kayit) => kayit['id'] == id);
    hastalikKayitlari.refresh();
  }

  // Filtreleme işlemleri
  List<Map<String, dynamic>> getFilteredHastalikTurleri() {
    if (searchQuery.isEmpty) {
      return hastalikTurleri;
    }
    return hastalikTurleri.where((hastalik) {
      return hastalik['ad']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          hastalik['aciklama']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> getFilteredHastalikKayitlari() {
    if (selectedHastalikTuru.value == 'Tümü') {
      return hastalikKayitlari.toList();
    }

    return hastalikKayitlari.where((kayit) {
      final hastalik = hastalikTurleri.firstWhere(
        (h) => h['id'] == kayit['hastalikId'],
        orElse: () => {'tur': ''},
      );
      return hastalik['tur'] == selectedHastalikTuru.value;
    }).toList();
  }

  // İstatistikler
  Map<String, int> getHastalikIstatistikleri() {
    int aktif = 0;
    int tamamlanan = 0;
    int toplam = 0;

    for (var kayit in hastalikKayitlari) {
      if (kayit['durum'] == 'devam') {
        aktif++;
      } else if (kayit['durum'] == 'tamamlandi') {
        tamamlanan++;
      }
      toplam++;
    }

    return {
      'aktif': aktif,
      'tamamlanan': tamamlanan,
      'toplam': toplam,
    };
  }

  // Yardımcı metodlar
  Map<String, dynamic>? getHastalikById(String id) {
    try {
      return hastalikTurleri.firstWhere((hastalik) => hastalik['id'] == id);
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> getHastalikGecmisi(String hayvanId) {
    return hastalikKayitlari
        .where((kayit) => kayit['hayvanId'] == hayvanId)
        .toList()
      ..sort((a, b) => (b['baslangicTarihi'] as DateTime)
          .compareTo(a['baslangicTarihi'] as DateTime));
  }
}
