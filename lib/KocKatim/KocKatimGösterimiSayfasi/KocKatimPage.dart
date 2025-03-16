import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../AddKocKatimPage.dart';
import 'KocKatimCard.dart';
import 'KocKatimController.dart';

class KocKatimPage extends StatefulWidget {
  const KocKatimPage({Key? key}) : super(key: key);

  @override
  _KocKatimPageState createState() => _KocKatimPageState();
}

class _KocKatimPageState extends State<KocKatimPage> {
  final KocKatimController controller = Get.put(KocKatimController());
  final FocusNode searchFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 60.0),
            child: Container(
              height: 40,
              width: 130,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('resimler/Merlab.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              focusNode: searchFocusNode,
              cursorColor: Colors.black54,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Küpe No, Hayvan Adı',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              onChanged: (value) {
                controller.searchQuery.value = value;
              },
              onTapOutside: (event) {
                searchFocusNode
                    .unfocus(); // Dışarı tıklanırsa klavyeyi kapat ve imleci gizle
              },
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    final result = await Get.to(() => AddKocKatimPage(),
                        duration: const Duration(milliseconds: 650));
                    if (result == true) {
                      controller.fetchKocKatimData();
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: const Row(
                    children: [
                      Text('Koç Katımı Ekle',
                          style: TextStyle(color: Colors.black)),
                      Icon(Icons.add, color: Colors.black),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.black));
                } else if (controller.filteredKocKatimData.isEmpty) {
                  return const Center(child: Text('Koç katımı bulunamadı'));
                } else {
                  return ListView.builder(
                    itemCount: controller.filteredKocKatimData.length,
                    itemBuilder: (context, index) {
                      final data = controller.filteredKocKatimData[index];
                      return KocKatimCard(
                        koyunKupeNo: data['koyunKupeNo'] ?? '',
                        kocKupeNo: data['kocKupeNo'] ?? '',
                        koyunAdi: data['koyunAdi'] ?? '',
                        kocAdi: data['kocAdi'] ?? '',
                        katimTarihi: data['katimTarihi'] ?? '',
                        katimSaati: data['katimSaati'] ?? '',
                      );
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
