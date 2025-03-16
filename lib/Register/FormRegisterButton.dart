import 'package:flutter/material.dart';

class FormRegisterButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String title;
  final bool isLoading;

  const FormRegisterButton({
    Key? key,
    required this.onPressed,
    required this.title,
    required this.isLoading,
  }) : super(key: key);

  @override
  _FormRegisterButtonState createState() => _FormRegisterButtonState();
}

class _FormRegisterButtonState extends State<FormRegisterButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onPressed != null && !widget.isLoading) {
          _animationController.forward();
          widget.onPressed!();
        }
      },
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            gradient: const LinearGradient(
              colors: [Colors.cyan, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: widget.isLoading
              ? const CircularProgressIndicator(
            color: Colors.white,
          )
              : Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
