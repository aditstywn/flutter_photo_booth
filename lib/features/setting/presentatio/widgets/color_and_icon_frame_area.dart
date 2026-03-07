import 'package:flutter/material.dart';

Color getColorForFunction(String function) {
  switch (function) {
    case 'Start':
      return Color.fromARGB(255, 215, 230, 16);
    case 'Camera Preview':
      return Color(0xFF00B894);
    case 'Take Photo':
      return Color(0xFF5F72EB);

    case 'Preview':
      return Color(0xFF5F72EB);
    case 'Retake':
      return Color(0xFFFF6B6B);
    case 'Print':
      return Color(0xFF5F72EB);
    case 'Scan QR':
      return Color(0xFF00B894);
    default:
      return Color(0xFF636E72);
  }
}

IconData getIconForFunction(String function) {
  switch (function) {
    case 'Start':
      return Icons.play_arrow;
    case 'Camera Preview':
      return Icons.camera_alt;
    case 'Take Photo':
      return Icons.camera;

    case 'Preview':
      return Icons.image;
    case 'Retake':
      return Icons.refresh;
    case 'Print':
      return Icons.print;
    case 'Scan QR':
      return Icons.qr_code_scanner;
    default:
      return Icons.touch_app;
  }
}
