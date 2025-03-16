import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeightField extends StatelessWidget {
  const WeightField({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.cyan,
              spreadRadius: 3,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '12,34 kg',
              style: GoogleFonts.orbitron(
                textStyle: const TextStyle(
                  fontSize: 22, // Büyük başlık boyutu
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
