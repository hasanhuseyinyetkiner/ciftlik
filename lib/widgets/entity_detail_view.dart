import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/base_model.dart';
import 'custom_button.dart';

class EntityDetailView extends StatelessWidget {
  final String title;
  final BaseModel entity;
  final Map<String, String> displayFields;
  final List<Widget> extraWidgets;
  final Function()? onEditPressed;
  final Function()? onDeletePressed;
  final Function()? onBackPressed;

  const EntityDetailView({
    Key? key,
    required this.title,
    required this.entity,
    required this.displayFields,
    this.extraWidgets = const [],
    this.onEditPressed,
    this.onDeletePressed,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: onBackPressed ?? () => Get.back(),
        ),
        actions: [
          if (onEditPressed != null)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEditPressed,
            ),
          if (onDeletePressed != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(),
            ...extraWidgets,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...displayFields.entries
                .map((entry) => _buildDetailItem(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Divider(),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Silme Onayı'),
        content: Text(
            'Bu kaydı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('İptal'),
          ),
          CustomButton(
            label: 'Sil',
            onPressed: () {
              Navigator.of(context).pop();
              if (onDeletePressed != null) {
                onDeletePressed!();
              }
            },
            type: CustomButtonType.danger,
          ),
        ],
      ),
    );
  }
}
