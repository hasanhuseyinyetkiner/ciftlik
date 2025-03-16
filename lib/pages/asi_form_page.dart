import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/asi_controller.dart';
import '../models/asi_model.dart';
import '../widgets/forms/form_builder.dart';

class AsiFormPage extends StatelessWidget {
  final AsiController controller = Get.find<AsiController>();
  final Asi? asi;
  final bool isEditing;

  AsiFormPage({Key? key, this.asi})
      : isEditing = asi != null,
        super(key: key) {
    // If editing, load data into form
    if (isEditing) {
      controller.loadVaccineForEdit(asi!);
    } else {
      controller.resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Aşı Düzenle' : 'Yeni Aşı Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              FormBuilder.buildSectionTitle('Temel Bilgiler'),
              FormBuilder.buildTextField(
                label: 'Aşı Adı',
                controller: controller.asiAdiController,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen aşı adını girin';
                  }
                  return null;
                },
                prefixIcon: Icons.medical_services,
              ),
              FormBuilder.buildTextField(
                label: 'Üretici',
                controller: controller.ureticiController,
                prefixIcon: Icons.business,
              ),
              FormBuilder.buildTextField(
                label: 'Seri Numarası',
                controller: controller.seriNumarasiController,
                prefixIcon: Icons.qr_code,
              ),

              // Expiry Date
              Obx(() => FormBuilder.buildDatePicker(
                    label: 'Son Kullanma Tarihi',
                    selectedDate: controller.sonKullanmaTarihi.value,
                    onDateSelected: (date) =>
                        controller.sonKullanmaTarihi.value = date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365 * 5)),
                    prefixIcon: Icons.event,
                  )),

              // Description
              FormBuilder.buildTextField(
                label: 'Açıklama',
                controller: controller.aciklamaController,
                maxLines: 5,
                prefixIcon: Icons.description,
              ),

              // Submit Button
              Obx(() => FormBuilder.buildSubmitButton(
                    label: isEditing ? 'Güncelle' : 'Kaydet',
                    onPressed: _handleSubmit,
                    isLoading: controller.isLoading.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (controller.formKey.currentState!.validate()) {
      if (isEditing) {
        final updatedAsi =
            controller.createVaccineFromForm(existingId: asi!.asiId);
        controller.updateItem(updatedAsi);
      } else {
        final newAsi = controller.createVaccineFromForm();
        controller.addItem(newAsi);
      }
      Get.back();
    }
  }
}
