import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/asilama_controller.dart';
import '../models/asilama_model.dart';
import '../models/hayvan_model.dart';
import '../models/asi_model.dart';
import '../widgets/forms/form_builder.dart';

class AsilamaFormPage extends StatelessWidget {
  final AsilamaController controller = Get.find<AsilamaController>();
  final Asilama? asilama;
  final Hayvan? hayvan;
  final Asi? asi;
  final bool isEditing;

  AsilamaFormPage({Key? key, this.asilama, this.hayvan, this.asi})
      : isEditing = asilama != null,
        super(key: key) {
    // If editing, load data into form
    if (isEditing) {
      controller.loadVaccinationForEdit(asilama!);
    } else {
      controller.resetForm();
      // If coming from animal or vaccine details, set the related data
      if (hayvan != null) {
        controller.hayvanId.value = hayvan!.hayvanId;
      }
      if (asi != null) {
        controller.asiId.value = asi!.asiId;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Aşılama Düzenle' : 'Yeni Aşılama Ekle'),
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

              // Vaccine ID field - required
              Obx(() => FormBuilder.buildTextField(
                    label: 'Aşı ID',
                    controller: TextEditingController(
                      text: controller.asiId.value?.toString() ?? '',
                    ),
                    isRequired: true,
                    keyboardType: TextInputType.number,
                    isEnabled: false, // Use dropdown or selector in real app
                    prefixIcon: Icons.medical_services,
                  )),

              // Vaccination date picker
              Obx(() => FormBuilder.buildDatePicker(
                    label: 'Uygulama Tarihi',
                    selectedDate: controller.uygulamaTarihi.value,
                    onDateSelected: (date) => controller.uygulamaTarihi.value =
                        date ?? DateTime.now(),
                    isRequired: true,
                    prefixIcon: Icons.calendar_today,
                  )),

              // Dosage field
              FormBuilder.buildTextField(
                label: 'Doz Miktarı',
                controller: controller.dozMiktariController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.science,
              ),

              // Application Status dropdown
              Obx(() => FormBuilder.buildDropdown<String>(
                    label: 'Aşılama Durumu',
                    value: controller.asilamaDurumu.value,
                    items: controller.asilamaDurumuOptions
                        .map((option) => DropdownMenuItem(
                            value: option, child: Text(option)))
                        .toList(),
                    onChanged: (value) =>
                        controller.asilamaDurumu.value = value,
                    isRequired: true,
                    prefixIcon: Icons.assignment_turned_in,
                  )),

              // Result dropdown
              Obx(() => FormBuilder.buildDropdown<String>(
                    label: 'Aşılama Sonucu',
                    value: controller.asilamaSonucu.value,
                    items: controller.asilamaSonucuOptions
                        .map((option) => DropdownMenuItem(
                            value: option, child: Text(option)))
                        .toList(),
                    onChanged: (value) =>
                        controller.asilamaSonucu.value = value,
                    prefixIcon: Icons.check_circle,
                  )),

              // Financial Information Section
              FormBuilder.buildSectionTitle('Finansal Bilgiler'),

              // Cost field
              FormBuilder.buildTextField(
                label: 'Maliyet (TL)',
                controller: controller.maliyetController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.attach_money,
              ),

              // Applier ID field (would be dropdown with names in real app)
              FormBuilder.buildTextField(
                label: 'Uygulayan ID',
                controller: TextEditingController(
                  text: controller.uygulayanId.value?.toString() ?? '',
                ),
                keyboardType: TextInputType.number,
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    controller.uygulayanId.value = int.tryParse(value);
                  } else {
                    controller.uygulayanId.value = null;
                  }
                  return null;
                },
              ),

              // Notes
              FormBuilder.buildTextField(
                label: 'Notlar',
                controller: controller.notlarController,
                maxLines: 5,
                prefixIcon: Icons.note,
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

      if (controller.asiId.value == null) {
        controller.showError('Lütfen bir aşı seçin');
        return;
      }

      if (isEditing) {
        final updatedAsilama = controller.createVaccinationFromForm(
            existingId: asilama!.asilamaId);
        controller.updateItem(updatedAsilama);
      } else {
        final newAsilama = controller.createVaccinationFromForm();
        controller.addItem(newAsilama);
      }
      Get.back();
    }
  }
}
