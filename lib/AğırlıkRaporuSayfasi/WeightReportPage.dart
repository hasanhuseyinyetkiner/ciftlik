import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'WeightReportController.dart';
import 'WeightReportCard.dart';
import 'WeightReportFilterController.dart';
import 'WeightReportFilterPage.dart'; // Buraya FilterPage'i ekleyin

class WeightReportPage extends StatelessWidget {
  final String tagNo;
  final WeightReportController controller = Get.put(WeightReportController());

  WeightReportPage({Key? key, required this.tagNo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sayfa yüklendiğinde raporları getir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (tagNo == 'all') {
        controller.fetchAllReports();
      } else {
        controller.fetchReportsByTagNo(tagNo);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(tagNo == 'all'
            ? 'Tüm Ağırlık Raporları'
            : 'Ağırlık Raporu - $tagNo'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.reports.isEmpty) {
          return const Center(child: Text('Rapor bulunamadı'));
        }

        return ListView.builder(
          itemCount: controller.filteredReports.length,
          itemBuilder: (context, index) {
            final report = controller.filteredReports[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text('Küpe No: ${report['tagNo']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ağırlık: ${report['weight']} kg'),
                    Text('Tarih: ${report['date']}'),
                    Text('Tür: ${report['animaltype']}'),
                  ],
                ),
                trailing: report['weaned'] == 1
                    ? const Chip(label: Text('Sütten Kesilmiş'))
                    : null,
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni ağırlık raporu ekleme sayfasına yönlendir
          Get.toNamed('/add-weight', arguments: {'tagNo': tagNo});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
