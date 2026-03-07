import 'package:flutter/material.dart';

import '../../../setting/data/models/request/button_area.dart';

Widget buildTappableArea({
  required ButtonArea area,
  required BoxConstraints constraints,
  bool isCameraPreview = false,
  bool isResultPreview = false,
  VoidCallback? onTap,
  Widget? child,

  // camera preview specific parameters
  // CameraController? cameraController,
  // bool isCameraInitialized = false,
  // FrameTemplate? selectedTemplate,
}) {
  // Convert normalized values (0-1) to pixels
  final containerWidth = constraints.maxWidth;
  final containerHeight = constraints.maxHeight;

  // Validasi dan clamp nilai normalized (handle data lama yang mungkin masih pixel)
  final normalizedX = area.x > 1.0 ? area.x / containerWidth : area.x;
  final normalizedY = area.y > 1.0 ? area.y / containerHeight : area.y;
  final normalizedWidth = area.width > 1.0
      ? area.width / containerWidth
      : area.width;
  final normalizedHeight = area.height > 1.0
      ? area.height / containerHeight
      : area.height;

  final pixelX = (normalizedX * containerWidth).clamp(0.0, containerWidth);
  final pixelY = (normalizedY * containerHeight).clamp(0.0, containerHeight);
  final pixelWidth = (normalizedWidth * containerWidth).clamp(
    10.0,
    containerWidth,
  );
  final pixelHeight = (normalizedHeight * containerHeight).clamp(
    10.0,
    containerHeight,
  );
  return Positioned(
    left: pixelX,
    top: pixelY,
    child: isCameraPreview
        ? child ?? Container()
        : isResultPreview
        ? child ?? Container()
        : GestureDetector(
            onTap: onTap,
            child: Container(
              width: pixelWidth,
              height: pixelHeight,
              color: Colors.transparent,
            ),
          ),
  );
}
