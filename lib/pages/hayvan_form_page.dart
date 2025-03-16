import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/hayvan_controller.dart';
import '../models/hayvan_model.dart';
import '../widgets/forms/form_builder.dart';

class HayvanFormPage extends StatelessWidget {
  final HayvanController controller = Get.find<HayvanController>();
  final Hayvan? hayvan;
  final bool isEditing;

  HayvanFormPage({Key? key, this.hayvan})
      : isEditing = hayvan != null,
        super(key: key) {
    // If editing, load data into form
    if (isEditing) {
      controller.loadAnimalForEdit(hayvan!);
    } else {
      controller.resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Hayvan Düzenle' : 'Yeni Hayvan Ekle'),
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
                label: 'İsim',
                controller: controller.isimController,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen hayvan ismini girin';
                  }
                  return null;
                },
                prefixIcon: Icons.pets,
              ),
              FormBuilder.buildTextField(
                label: 'Küpe No',
                controller: controller.kupeNoController,
                prefixIcon: Icons.label,
              ),
              FormBuilder.buildTextField(
                label: 'RFID Tag',
                controller: controller.rfidTagController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.nfc,
              ),

              // Breed & Gender Section
              FormBuilder.buildSectionTitle('Irk ve Cinsiyet'),
              Obx(() => FormBuilder.buildDropdown<String>(
                    label: 'Irk',
                    value: controller.irkController.text.isEmpty
                        ? null
                        : controller.irkController.text,
                    items: controller.irkOptions
                        .map((option) => DropdownMenuItem(
                            value: option, child: Text(option)))
                        .toList(),
                    onChanged: (value) {
                      controller.irkController.text = value ?? '';
                    },
                    prefixIcon: Icons.category,
                  )),
              Obx(() => FormBuilder.buildDropdown<String>(
                    label: 'Cinsiyet',
                    value: controller.cinsiyet.value,
                    items: controller.cinsiyetOptions
                        .map((option) => DropdownMenuItem(
                            value: option, child: Text(option)))
                        .toList(),
                    onChanged: (value) => controller.cinsiyet.value = value,
                    prefixIcon: Icons.male,
                  )),

              // Birth & Pedigree Section
              FormBuilder.buildSectionTitle('Doğum ve Soy Bilgileri'),
              Obx(() => FormBuilder.buildDatePicker(
                    label: 'Doğum Tarihi',
                    selectedDate: controller.dogumTarihi.value,
                    onDateSelected: (date) =>
                        controller.dogumTarihi.value = date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  )),

              // Additional Information
              FormBuilder.buildSectionTitle('Ek Bilgiler'),
              Obx(() => FormBuilder.buildDropdown<String>(
                    label: 'Damızlık Kalite',
                    value: controller.damizlikKalite.value,
                    items: controller.damizlikKaliteOptions
                        .map((option) => DropdownMenuItem(
                            value: option, child: Text(option)))
                        .toList(),
                    onChanged: (value) =>
                        controller.damizlikKalite.value = value,
                  )),
              Obx(() => FormBuilder.buildDropdown<String>(
                    label: 'Sahiplik Durumu',
                    value: controller.sahiplikDurumu.value,
                    items: controller.sahiplikDurumuOptions
                        .map((option) => DropdownMenuItem(
                            value: option, child: Text(option)))
                        .toList(),
                    onChanged: (value) =>
                        controller.sahiplikDurumu.value = value,
                  )),
              Obx(() => FormBuilder.buildCheckbox(
                    label: 'Hayvan Aktif',
                    value: controller.aktifMi.value,
                    onChanged: (value) =>
                        controller.aktifMi.value = value ?? true,
                    helperText: 'Hayvan çiftlikte aktif olarak bulunuyor mu?',
                  )),

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
        final updatedHayvan =
            controller.createAnimalFromForm(existingId: hayvan!.hayvanId);
        controller.updateItem(updatedHayvan);
      } else {
        final newHayvan = controller.createAnimalFromForm();
        controller.addItem(newHayvan);
      }
      Get.back();
    }
  }
}
