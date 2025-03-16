import 'package:flutter/material.dart';
import 'tmr_rasyon_list_screen.dart';
import 'yem_list_screen.dart';
import 'yem_stok_list_screen.dart';
import 'yem_islem_list_screen.dart';

class YemHomeScreen extends StatefulWidget {
  const YemHomeScreen({super.key});

  @override
  State<YemHomeScreen> createState() => _YemHomeScreenState();
}

class _YemHomeScreenState extends State<YemHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const YemListScreen(),
    const YemStokListScreen(),
    const YemIslemListScreen(),
    const TMRRasyonListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grass), label: 'Yemler'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Stok'),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'İşlemler',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.blender), label: 'TMR'),
        ],
      ),
    );
  }
}
