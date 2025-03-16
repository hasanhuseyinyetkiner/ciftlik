import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'FeedController.dart';
import 'FeedModel.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Yem Yönetimi'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Yem Kayıt'),
              Tab(text: 'Stok Takibi'),
              Tab(text: 'Raporlar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFeedRegistrationTab(controller),
            _buildStockTrackingTab(controller),
            _buildReportsTab(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedRegistrationTab(FeedController controller) {
    return Obx(() {
      return Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Temel Bilgiler'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: controller.nameController,
                            decoration: const InputDecoration(
                              labelText: 'Yem Adı *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Yem adı boş olamaz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Yem Türü *',
                              border: OutlineInputBorder(),
                            ),
                            value: controller.selectedType,
                            items: controller.feedTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controller.selectedType = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Yem türü seçiniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.brandController,
                            decoration: const InputDecoration(
                              labelText: 'Marka',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.batchNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Parti/Lot No',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Miktar ve Fiyat Bilgileri'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: controller.quantityController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Miktar *',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Miktar boş olamaz';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Geçerli bir sayı giriniz';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Birim *',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: controller.selectedUnit,
                                  items: controller.units.map((unit) {
                                    return DropdownMenuItem(
                                      value: unit,
                                      child: Text(unit),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    controller.selectedUnit = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Birim seçiniz';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: controller.unitPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Birim Fiyat *',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Birim fiyat boş olamaz';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Geçerli bir sayı giriniz';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Para Birimi *',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: controller.selectedCurrency,
                                  items: controller.currencies.map((currency) {
                                    return DropdownMenuItem(
                                      value: currency,
                                      child: Text(currency),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    controller.selectedCurrency = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Para birimi seçiniz';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Depolama ve Stok Bilgileri'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: controller.storageLocationController,
                            decoration: const InputDecoration(
                              labelText: 'Depo Lokasyonu *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Depo lokasyonu boş olamaz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.minimumStockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Minimum Stok Seviyesi *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Minimum stok seviyesi boş olamaz';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Geçerli bir sayı giriniz';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Tarih Bilgileri'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: Get.context!,
                                initialDate: controller.selectedPurchaseDate ??
                                    DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                controller.selectedPurchaseDate = picked;
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Alım Tarihi *',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                controller.selectedPurchaseDate != null
                                    ? controller.formatDate(
                                        controller.selectedPurchaseDate!)
                                    : 'Tarih Seçiniz',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: Get.context!,
                                initialDate: controller.selectedExpiryDate ??
                                    DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                controller.selectedExpiryDate = picked;
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Son Kullanma Tarihi',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                controller.selectedExpiryDate != null
                                    ? controller.formatDate(
                                        controller.selectedExpiryDate!)
                                    : 'Tarih Seçiniz',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Yemleme Bilgileri'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Hayvan Grubu *',
                              border: OutlineInputBorder(),
                            ),
                            value: controller.selectedAnimalGroup,
                            items: controller.animalGroups.map((group) {
                              return DropdownMenuItem(
                                value: group,
                                child: Text(group),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controller.selectedAnimalGroup = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Hayvan grubu seçiniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Yemleme Zamanı',
                              border: OutlineInputBorder(),
                            ),
                            value: controller.selectedFeedingTime,
                            items: controller.feedingTimes.map((time) {
                              return DropdownMenuItem(
                                value: time,
                                child: Text(time),
                              );
                            }).toList(),
                            onChanged: (value) {
                              controller.selectedFeedingTime = value;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Notlar'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: controller.notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Notlar',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed:
                            controller.isLoading ? null : controller.resetForm,
                        icon: const Icon(Icons.clear),
                        label: const Text('Temizle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed:
                            controller.isLoading ? null : controller.saveFeed,
                        icon: const Icon(Icons.save),
                        label: const Text('Kaydet'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (controller.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildStockTrackingTab(FeedController controller) {
    return Obx(() {
      if (controller.feeds.isEmpty) {
        return const Center(
          child: Text('Kayıtlı yem bulunmamaktadır.'),
        );
      }

      return ListView.builder(
        itemCount: controller.feeds.length,
        itemBuilder: (context, index) {
          final feed = controller.feeds[index];
          final isLowStock = controller.lowStockFeeds
              .any((lowStockFeed) => lowStockFeed.id == feed.id);
          final isExpiring = controller.expiringFeeds
              .any((expiringFeed) => expiringFeed.id == feed.id);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(feed.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tür: ${feed.type}'),
                  Text(
                      'Miktar: ${feed.quantity} ${feed.unit} / Min: ${feed.minimumStock} ${feed.unit}'),
                  Text(
                      'Fiyat: ${controller.formatCurrency(feed.unitPrice, feed.currency)}'),
                  if (feed.expiryDate != null)
                    Text('SKT: ${controller.formatDate(feed.expiryDate!)}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLowStock)
                    const Icon(Icons.warning, color: Colors.orange),
                  if (isExpiring)
                    const Icon(Icons.access_time, color: Colors.red),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // TODO: Implement edit functionality
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildReportsTab(FeedController controller) {
    return const Center(
      child: Text('Raporlar yakında eklenecek...'),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
