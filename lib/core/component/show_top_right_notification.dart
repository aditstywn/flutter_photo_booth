import 'package:flutter/material.dart';

import '../style/color/colors_app.dart';

void showTopRightAlert({
  required BuildContext context,
  required String message,
  bool? isSuccess,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);

  late OverlayEntry realEntry;

  realEntry = OverlayEntry(
    builder: (context) => _AnimatedAlert(
      message: message,
      onClose: () => realEntry.remove(),
      isSuccess: isSuccess ?? false,
    ),
  );

  overlay.insert(realEntry);

  Future.delayed(duration, () {
    if (realEntry.mounted) realEntry.remove();
  });
}

class _AnimatedAlert extends StatefulWidget {
  final String message;
  final VoidCallback onClose;
  final bool isSuccess;

  const _AnimatedAlert({
    required this.message,
    required this.onClose,
    required this.isSuccess,
  });

  @override
  State<_AnimatedAlert> createState() => _AnimatedAlertState();
}

class _AnimatedAlertState extends State<_AnimatedAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // dari kanan
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: _AlertBox(
            message: widget.message,
            onClose: widget.onClose,
            isSuccess: widget.isSuccess,
          ),
        ),
      ),
    );
  }
}

class _AlertBox extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  final bool isSuccess;

  const _AlertBox({
    required this.message,
    required this.onClose,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: isSuccess == true ? Color(0xFFD6FFBA) : Color(0xFFFFD8DB),
          border: Border.all(
            color: isSuccess == true ? ColorsApp.success : ColorsApp.error,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSuccess == true ? Icons.check_circle : Icons.error,
                  size: 18,
                  color: isSuccess == true
                      ? ColorsApp.success
                      : ColorsApp.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isSuccess == true
                          ? ColorsApp.success
                          : ColorsApp.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
