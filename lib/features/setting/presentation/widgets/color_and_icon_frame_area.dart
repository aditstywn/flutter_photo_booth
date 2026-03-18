import 'package:flutter/material.dart';

Color getColorForFunction(String function) {
  switch (function) {
    case 'Start':
      return Color.fromARGB(255, 230, 246, 4);
    case 'Camera':
      return Color(0xFF00B894);
    case 'Take Photo':
      return Color(0xFF5F72EB);

    case 'Preview':
      return Color(0xFF5F72EB);
    case 'Retake':
      return Color(0xFFFF6B6B);
    case 'Print':
      return Color(0xFF5F72EB);
    case 'Share':
      return Color(0xFF00B894);
    default:
      return Color(0xFF636E72);
  }
}

IconData getIconForFunction(String function) {
  switch (function) {
    case 'Start':
      return Icons.play_arrow;
    case 'Camera':
      return Icons.camera_alt;
    case 'Take Photo':
      return Icons.camera;

    case 'Preview':
      return Icons.image;
    case 'Retake':
      return Icons.refresh;
    case 'Print':
      return Icons.print;
    case 'Share':
      return Icons.share;
    default:
      return Icons.touch_app;
  }
}
