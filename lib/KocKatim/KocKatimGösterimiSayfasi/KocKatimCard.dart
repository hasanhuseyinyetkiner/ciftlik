import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'KocKatimController.dart';

class KocKatimCard extends StatefulWidget {
  final String koyunKupeNo;
  final String kocKupeNo;
  final String koyunAdi;
  final String kocAdi;
  final String katimTarihi;
  final String katimSaati;

  const KocKatimCard({
    Key? key,
    required this.koyunKupeNo,
    required this.kocKupeNo,
    required this.koyunAdi,
    required this.kocAdi,
    required this.katimTarihi,
    required this.katimSaati,
  }) : super(key: key);

  @override
  _KocKatimCardState createState() => _KocKatimCardState();
}

class _KocKatimCardState extends State<KocKatimCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final KocKatimController controller = Get.find<KocKatimController>();

    return Slidable(
      key: ValueKey(widget.koyunKupeNo + widget.kocKupeNo), // Benzersiz bir anahtar
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.17,
        children: [
          SlidableAction(
            onPressed: (context) {
              controller.removeKocKatim(widget.koyunKupeNo, widget.kocKupeNo);
              Get.snackbar('Başarılı', 'Koç Katım kaydı silindi');
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Sil',
            borderRadius: BorderRadius.circular(12.0),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
      child: Stack(
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 4.0,
            shadowColor: Colors.cyan,
            margin: const EdgeInsets.only(bottom: 10.0, right: 10),
            child: ListTile(
              leading: Image.asset(
                'icons/sheep_and_lamb_icon_black.png', // Buraya asset yolunu koyun
                width: 40.0,
                height: 40.0,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Eşlenen Koyun Küpe No: ${widget.koyunKupeNo}'),
                  const SizedBox(height: 4),
                  Text('Eşlenen Koç Küpe No: ${widget.kocKupeNo}'),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Eşlenen Koyunun Adı: ${widget.koyunAdi}'),
                    const SizedBox(height: 4),
                    Text('Eşlenen Koçun Adı: ${widget.kocAdi}'),
                    const SizedBox(height: 4),
                    Text('Koç Katım Tarihi: ${widget.katimTarihi}'),
                    const SizedBox(height: 4),
                    Text('Koç Katım Saati: ${widget.katimSaati}'),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            top: 6,
            right: 16,
            child: Icon(
              Icons.swipe_left,
              size: 18,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
