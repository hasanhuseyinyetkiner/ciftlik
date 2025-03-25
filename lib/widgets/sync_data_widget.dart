import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/data_service.dart';

/// SyncDataWidget - Veri senkronizasyon widget'ı
///
/// Bu widget, belirli tablolardaki verileri Supabase ile senkronize etmek için kullanılır.
/// Özellikle veri giriş formlarının altına eklenebilir.
///
/// Kullanım örneği:
/// ```
/// SyncDataWidget(
///   tables: ['hayvanlar', 'hayvan_not'],
///   showLabel: true,
/// )
/// ```
class SyncDataWidget extends StatefulWidget {
  /// Senkronize edilecek tablolar
  final List<String> tables;

  /// Açıklama etiketi gösterilsin mi?
  final bool showLabel;

  /// Otomatik senkronizasyon
  final bool autoSync;

  /// Label metni
  final String labelText;

  /// Widget genişliği
  final double? width;

  const SyncDataWidget({
    Key? key,
    required this.tables,
    this.showLabel = true,
    this.autoSync = false,
    this.labelText = 'Değişiklikleri senkronize et',
    this.width,
  }) : super(key: key);

  @override
  State<SyncDataWidget> createState() => _SyncDataWidgetState();
}

class _SyncDataWidgetState extends State<SyncDataWidget> {
  final DataService _dataService = Get.find<DataService>();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();

    // Otomatik senkronizasyon yapılacaksa
    if (widget.autoSync) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        syncData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: _isSyncing ? null : syncData,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: _dataService.isUsingSupabase
                ? Colors.blue.shade50
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _dataService.isUsingSupabase
                  ? Colors.blue.shade300
                  : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isSyncing
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _dataService.isUsingSupabase
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.sync,
                      color: _dataService.isUsingSupabase
                          ? Colors.blue
                          : Colors.grey,
                      size: 16,
                    ),
              const SizedBox(width: 8),
              if (widget.showLabel)
                Text(
                  widget.labelText,
                  style: TextStyle(
                    color: _dataService.isUsingSupabase
                        ? Colors.blue.shade700
                        : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> syncData() async {
    // Çevrimdışı modda veya Supabase devre dışıysa işlem yapmıyoruz
    if (!_dataService.isUsingSupabase) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Çevrimdışı modda senkronizasyon yapılamaz.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      final success = await _dataService.syncAfterUserInteraction(
        specificTables: widget.tables,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veriler başarıyla senkronize edildi.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senkronizasyon sırasında bir hata oluştu.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }
}
