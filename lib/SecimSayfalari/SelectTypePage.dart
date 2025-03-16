import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'SelectTypeBuyukPage.dart';
import 'SelectTypeKucukPage.dart';

class SelectTypePage extends StatelessWidget {
  const SelectTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double yukseklik = MediaQuery.of(context).size.height;
    final double genislik = MediaQuery.of(context).size.width;

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: yukseklik / 10), // Üstten boşluk
          const Text(
            'Ekleyeceğiniz Hayvanın Türünü Seçiniz',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: yukseklik / 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => const SelectTypeBuyukPage(),
                    duration: const Duration(milliseconds: 650),
                  );
                },
                child: Column(
                  children: [
                    Card(
                      child: Container(
                        width: genislik / 2.5,
                        height: yukseklik / 4,
                        decoration: BoxDecoration(
                          color: Colors.white, // Kart rengini beyaz yapın
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(15.0),
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/images/selecttypebuyuk.webp',
                            ),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: yukseklik / 100),
                    Card(
                      color: Colors.cyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Büyükbaş',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: yukseklik / 30),
              GestureDetector(
                onTap: () {
                  Get.to(
                    () => const SelectTypeKucukPage(),
                    duration: const Duration(milliseconds: 650),
                  );
                },
                child: Column(
                  children: [
                    Card(
                      child: Container(
                        width: genislik / 2.5,
                        height: yukseklik / 4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(15.0),
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/images/selecttypekucuk.webp',
                            ),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: yukseklik / 100),
                    Card(
                      color: Colors.cyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Küçükbaş',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
