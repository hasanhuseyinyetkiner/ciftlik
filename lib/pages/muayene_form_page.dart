import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/muayene_controller.dart';
import '../models/muayene_model.dart';
import '../models/hayvan_model.dart';
import '../widgets/forms/form_builder.dart';

class MuayeneFormPage extends StatelessWidget {
  final MuayeneController controller = Get.find<MuayeneController>();
  final Muayene? muayene;
  final Hayvan? hayvan;
  final bool isEditing;

  MuayeneFormPage({Key? key, this.muayene, this.hayvan})
      : isEditing = muayene != null,
        super(key: key) {
    // If editing, load data into form
    if (isEditing) {
      controller.loadExaminationForEdit(muayene!);
    } else {
      controller.resetForm();
      // If coming from animal details, set the animal
      if (hayvan != null) {
        controller.hayvanId.value = hayvan!.hayvanId;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Muayene Düzenle' : 'Yeni Muayene Ekle'),
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
              // Animal ID field - required
              Obx(() => FormBuilder.buildTextField(
                    label: 'Hayvan ID',
                    controller: TextEditingController(
                      text: controller.hayvanId.value?.toString() ?? '',
                    ),
                    isRequired: true,
                    keyboardType: TextInputType.number,
                    isEnabled: false, // Use dropdown or selector in real app
                    prefixIcon: Icons.pets,
                  )),

              // Examination date picker
              Obx(() => FormBuilder.buildDatePicker(
                    label: 'Muayene Tarihi',
                    selectedDate: controller.muayeneTarihi.value,
                    onDateSelected: (date) =>
                        controller.muayeneTarihi.value = date ?? DateTime.now(),
                    isRequired: true,
                    prefixIcon: Icons.calendar_today,
                  )),

              // Examination Type dropdown
              Obx(() => FormBuilder.buildDropdown<String>(
                    label: 'Muayene Tipi',
                    value: controller.muayeneTipi.value,
                    items: controller.muayeneTipiOptions
                        .map((option) => DropdownMenuItem(
                            value: option, child: Text(option)))
                        .toList(),
                    onChanged: (value) => controller.muayeneTipi.value = value,
                    isRequired: true,
                    prefixIcon: Icons.category,
                  )),

              // Examination Status dropdown
              Obx(() => FormBuilder.buildDropdown<String>(
                    label: 'Muayene Durumu',
                    value: controller.muayeneDurumu.value,
                    items: controller.muayeneDurumuOptions
                        .map((option) => DropdownMenuItem(
                            value: option, child: Text(option)))
                        .toList(),
                    onChanged: (value) =>
                        controller.muayeneDurumu.value = value,
                    isRequired: true,
                    prefixIcon: Icons.assignment_turned_in,
                  )),

              // Examination Findings multiline text field
              FormBuilder.buildTextField(
                label: 'Muayene Bulguları',
                controller: controller.muayeneBulgulariController,
                maxLines: 5,
                isRequired: true,
                prefixIcon: Icons.description,
              ),

              // Financial Information Section
              FormBuilder.buildSectionTitle('Finansal Bilgiler'),

              // Cost field
              FormBuilder.buildTextField(
                label: 'Ücret (TL)',
                controller: controller.ucretController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.attach_money,
              ),

              // Payment Status dropdown
              Obx(() => FormBuilder.buildDropdown<String>(
                    label: 'Ödeme Durumu',
                    value: controller.odemeDurumu.value,
                    items: controller.odemeDurumuOptions
                        .map((option) => DropdownMenuItem(
                            value: option, child: Text(option)))
                        .toList(),
                    onChanged: (value) => controller.odemeDurumu.value = value,
                    prefixIcon: Icons.payment,
                  )),

              // Veterinarian ID field (would be dropdown with names in real app)
              FormBuilder.buildTextField(
                label: 'Veteriner ID',
                controller: TextEditingController(
                  text: controller.veterinerId.value?.toString() ?? '',
                ),
                keyboardType: TextInputType.number,
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    controller.veterinerId.value = int.tryParse(value);
                  } else {
                    controller.veterinerId.value = null;
                  }
                  return null;
                },
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
      if (controller.hayvanId.value == null) {
        controller.showError('Lütfen bir hayvan seçin');
        return;
      }

      if (isEditing) {
        final updatedMuayene = controller.createExaminationFromForm(
            existingId: muayene!.muayeneId);
        controller.updateItem(updatedMuayene);
      } else {
        final newMuayene = controller.createExaminationFromForm();
        controller.addItem(newMuayene);
      }
      Get.back();
    }
  }
}
