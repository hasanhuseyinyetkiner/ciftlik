import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../EklemeSayfalari/OlcumEkleme/OlcumPage.dart';

import '../SecimSayfalari/SelectBirthTypePage.dart';
import '../SecimSayfalari/SelectTypePage.dart';

/*
* ExpandingFab - Genişleyen Floating Action Button Widget'ı
* --------------------------------------------------
* Bu widget, ana sayfada kullanılan genişleyebilir
* floating action button'u ve alt menülerini yönetir.
*
* Ana Bileşenler:
* 1. Ana FAB:
*    - Ana buton
*    - Animasyonlu ikon
*    - Açılma/kapanma durumu
*    - Gölge efekti
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
* 4. İnteraksiyon:
*    - Tıklama yönetimi
*    - Geri bildirim
*    - Otomatik kapanma
*    - Gesture algılama
*
* Özellikler:
* - Hero animasyonu
* - Özelleştirilebilir renkler
* - Responsive konumlandırma
* - Tema uyumu
*
* Kullanım:
* - Ana sayfada hızlı işlemler için
* - Sık kullanılan fonksiyonlara erişim
* - Yeni kayıt oluşturma
* - Hızlı veri girişi
*/

import 'dart:math' as math;

/// Açılabilir Floating Action Button widget'ı.
/// Bu widget, ana bir FAB ve bağlı alt FAB'lar içerir.
/// Ana FAB'a tıklandığında alt FAB'lar açılır veya kapanır.
class ExpandingFab extends StatefulWidget {
  final bool mini;
  final List<Widget> children;
  final double distance;
  final Color backgroundColor;
  final Color foregroundColor;
  final Icon icon;
  final AnimatedIconData animatedIcon;

  const ExpandingFab({
    Key? key,
    this.mini = false,
    required this.children,
    required this.distance,
    this.backgroundColor = Colors.blue,
    this.foregroundColor = Colors.white,
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
    final theme = Theme.of(context);
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          // Alt butonları oluştur
          ..._buildExpandingActionButtons(),

          // Ana buton
          _buildTapToOpenFab(theme),
        ],
      ),
    );
  }

  Widget _buildTapToOpenFab(ThemeData theme) {
    return FloatingActionButton(
      backgroundColor: widget.backgroundColor.withOpacity(0.9),
      foregroundColor: widget.foregroundColor,
      mini: widget.mini,
      onPressed: _toggle,
      elevation: 4,
      heroTag:
          'ExpandingFab_${widget.icon.toString()}_${widget.children.length}',
      child: AnimatedIcon(
        icon: widget.animatedIcon,
        progress: _controller,
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;

    // Her alt buton için özel bir açı hesapla
    // Butonu ekran kenarından aşağı doğru yerleştiriyoruz
    final step = 90.0 / (count - 1);

    for (var i = 0; i < count; i++) {
      final angle = 180 + i * step;
      children.add(
        _ExpandingActionButton(
          directionDegrees: angle,
          maxDistance: widget.distance,
          progress: _controller,
          child: widget.children[i],
        ),
      );
    }

    return children;
  }
}

/// Alt butonlar için animasyonlu container bileşeni
class _ExpandingActionButton extends StatelessWidget {
  final double directionDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  const _ExpandingActionButton({
    required this.directionDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );

        // Buton konumu
        return Positioned(
          right: 12.0 + offset.dx,
          bottom: 12.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: Opacity(
              opacity: progress.value,
              child: child,
            ),
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
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
