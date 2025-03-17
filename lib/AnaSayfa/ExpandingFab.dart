import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../EklemeSayfalari/OlcumEkleme/OlcumPage.dart';

import '../SecimSayfalari/SelectBirthTypePage.dart';
import '../SecimSayfalari/SelectTypePage.dart';

/*
* ExpandingFab - Neo-Brutalist Genişleyen Floating Action Button Widget'ı
* --------------------------------------------------
* Bu widget, ana sayfada kullanılan genişleyebilir
* floating action button'u ve alt menülerini neo-brutalist 
* tasarım prensiplerine göre yönetir.
*
* Neo-Brutalist Tasarım Özellikleri:
* - Kalın siyah çerçeveler
* - Keskin köşeler
* - Yüksek kontrast yeşil-siyah renk paleti
* - Belirgin offset gölgeler
* - Minimalist yaklaşım
*
* Ana Bileşenler:
* 1. Ana FAB:
*    - Kare formlu buton
*    - Kalın çerçeve
*    - Offset gölge
*    - Animasyonlu ikon
*
* 2. Alt Menü Butonları:
*    - Hayvan ekleme
*    - Süt ölçümü
*    - Aşı kaydı
*    - Muayene kaydı
*    - Hızlı not
*
* 3. Animasyonlar:
*    - Açılma animasyonu
*    - Kapanma animasyonu
*    - İkon dönüşü
*    - Opaklık değişimi
*
* Kullanım:
* - Ana sayfada hızlı işlemler için
* - Sık kullanılan fonksiyonlara erişim
* - Yeni kayıt oluşturma
* - Hızlı veri girişi
*/

import 'dart:math' as math;

/// Neo-Brutalist stilinde açılabilir Floating Action Button widget'ı.
/// Bu widget, ana bir FAB ve bağlı alt FAB'lar içerir.
/// Ana FAB'a tıklandığında alt FAB'lar açılır veya kapanır.
class ExpandingFab extends StatefulWidget {
  final bool mini;
  final List<Widget> children;
  final double distance;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final Icon icon;
  final AnimatedIconData animatedIcon;

  const ExpandingFab({
    Key? key,
    this.mini = false,
    required this.children,
    required this.distance,
    this.backgroundColor = const Color(0xFF0F9D58), // Vibrant Green
    this.foregroundColor = Colors.white,
    this.borderColor = Colors.black,
    this.icon = const Icon(Icons.add),
    this.animatedIcon = AnimatedIcons.menu_close,
  }) : super(key: key);

  @override
  State<ExpandingFab> createState() => _ExpandingFabState();
}

class _ExpandingFabState extends State<ExpandingFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.distance * 2,
      height: widget.distance * 2,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final int count = widget.children.length;
    final double step = 90.0 / (count - 1);

    return List.generate(count, (index) {
      final double angle = (135.0 + step * index) * (math.pi / 180);

      return _ExpandingActionButton(
        directionInDegrees: angle,
        maxDistance: widget.distance,
        progress: _controller,
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: widget.borderColor,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(3, 3),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: widget.children[index],
        ),
      );
    });
  }

  Widget _buildTapToOpenFab() {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: widget.borderColor,
          width: 3.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(5, 5),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: IgnorePointer(
        ignoring: _isOpen,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transformAlignment: Alignment.center,
          transform: Matrix4.diagonal3Values(
            _isOpen ? 0.7 : 1.0,
            _isOpen ? 0.7 : 1.0,
            1.0,
          ),
          child: AnimatedOpacity(
            opacity: _isOpen ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: FloatingActionButton(
              heroTag: 'NeoBrutalistFAB',
              mini: widget.mini,
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: _toggle,
              child: widget.icon,
            ),
          ),
        ),
      ),
    );
  }
}

/// Alt FAB düğmelerinin açılma animasyonunu yöneten yardımcı sınıf.
class _ExpandingActionButton extends StatelessWidget {
  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final double dx =
            math.cos(directionInDegrees) * (maxDistance * progress.value);
        final double dy =
            math.sin(directionInDegrees) * (maxDistance * progress.value);

        return Positioned(
          right: 4.0 + dx,
          bottom: 4.0 + dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: Opacity(
              opacity: progress.value,
              child: SizedBox(
                height: 56,
                width: 56,
                child: child,
              ),
            ),
          ),
        );
      },
      child: FittedBox(
        child: child,
      ),
    );
  }
}

/// Alt butonlar için action button bileşeni
class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String tooltip;
  final Color backgroundColor;
  final Color foregroundColor;

  const ActionButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.tooltip = '',
    this.backgroundColor = Colors.blue,
    this.foregroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: backgroundColor.withOpacity(0.9),
      shape: const CircleBorder(),
      elevation: 4.0,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor ?? theme.colorScheme.primary,
            ),
            child: Center(
              child: IconTheme(
                data: IconThemeData(
                    color: foregroundColor ?? theme.colorScheme.onPrimary,
                    size: 24.0),
                child: icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
