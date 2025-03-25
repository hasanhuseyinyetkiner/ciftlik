import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/data_service.dart';

class SyncButton extends StatefulWidget {
  final List<String>? specificTables;
  final bool showText;

  const SyncButton({
    Key? key,
    this.specificTables,
    this.showText = true,
  }) : super(key: key);

  @override
  State<SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<SyncButton> {
  final DataService _dataService = Get.find<DataService>();
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isSyncing ? null : _syncData,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isSyncing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync, color: Colors.green),
            if (widget.showText)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  _isSyncing ? 'Senkronize ediliyor...' : 'Senkronize Et',
                  style: TextStyle(
                    color: _isSyncing ? Colors.grey : Colors.green,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncData() async {
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
        specificTables: widget.specificTables,
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
