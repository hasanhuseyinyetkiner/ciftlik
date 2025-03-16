import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'GelirGiderController.dart';
import 'GelirGiderGirisPage.dart';

class GelirGiderListesiPage extends StatefulWidget {
  const GelirGiderListesiPage({Key? key}) : super(key: key);

  @override
  State<GelirGiderListesiPage> createState() => _GelirGiderListesiPageState();
}

class _GelirGiderListesiPageState extends State<GelirGiderListesiPage>
    with TickerProviderStateMixin {
  final _listKey = GlobalKey<AnimatedListState>();
  late AnimationController _filterAnimationController;
  late AnimationController _emptyStateAnimationController;
  late Animation<double> _emptyStateAnimation;

  final RxString _selectedCategory = 'Tümü'.obs;
  final RxString _selectedDateFilter = 'Tümü'.obs;
  bool _isFilterExpanded = false;

  // Örnek işlem listesi
  final RxList<Map<String, dynamic>> _islemler = <Map<String, dynamic>>[
    {
      'id': '1',
      'tur': 'gelir',
      'kategori': 'Süt Satışı',
      'miktar': 5000.0,
      'tarih': DateTime.now().subtract(const Duration(days: 2)),
      'aciklama': 'Aylık süt satışı geliri',
    },
    {
      'id': '2',
      'tur': 'gider',
      'kategori': 'Yem Alımı',
      'miktar': 3000.0,
      'tarih': DateTime.now().subtract(const Duration(days: 1)),
      'aciklama': 'Kaba yem alımı',
    },
  ].obs;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _filterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _emptyStateAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _emptyStateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _emptyStateAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    if (_islemler.isEmpty) {
      _emptyStateAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _filterAnimationController.dispose();
    _emptyStateAnimationController.dispose();
    super.dispose();
  }

  Color _getKategoriRengi(String kategori) {
    switch (kategori) {
      case 'Süt Satışı':
        return Colors.green;
      case 'Yem Alımı':
        return Colors.orange;
      case 'Veteriner':
        return Colors.red;
      case 'Ekipman':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelir & Gider'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtreler
          Card(
            margin: const EdgeInsets.all(16),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: ExpansionTile(
                title: const Text('Filtreler'),
                onExpansionChanged: (expanded) {
                  setState(() {
                    _isFilterExpanded = expanded;
                  });
                  if (expanded) {
                    _filterAnimationController.forward();
                  } else {
                    _filterAnimationController.reverse();
                  }
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Kategori filtresi
                        DropdownButtonFormField<String>(
                          value: _selectedCategory.value,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            'Tümü',
                            'Süt Satışı',
                            'Yem Alımı',
                            'Veteriner',
                            'Ekipman'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            _selectedCategory.value = value!;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Tarih filtresi
                        DropdownButtonFormField<String>(
                          value: _selectedDateFilter.value,
                          decoration: const InputDecoration(
                            labelText: 'Tarih',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            'Tümü',
                            'Bugün',
                            'Bu Hafta',
                            'Bu Ay',
                            'Son 3 Ay'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            _selectedDateFilter.value = value!;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // İşlem Listesi
          Expanded(
            child: Obx(() {
              if (_islemler.isEmpty) {
                return ScaleTransition(
                  scale: _emptyStateAnimation,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'İşlem Kaydı Bulunamadı',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Yeni işlem eklemek için + butonuna tıklayın',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return AnimatedList(
                key: _listKey,
                initialItemCount: _islemler.length,
                itemBuilder: (context, index, animation) {
                  final islem = _islemler[index];
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getKategoriRengi(islem['kategori'])
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                islem['tur'] == 'gelir'
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: _getKategoriRengi(islem['kategori']),
                              ),
                            ),
                            title: Text(
                              islem['kategori'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${islem['tarih'].toString().split(' ')[0]}\n${islem['aciklama']}',
                            ),
                            trailing: Text(
                              '${islem['tur'] == 'gelir' ? '+' : '-'}${islem['miktar'].toStringAsFixed(2)} ₺',
                              style: TextStyle(
                                color: islem['tur'] == 'gelir'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            isThreeLine: true,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const GelirGiderGirisPage());
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
