import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomFrameLocalDatasource {
  File? _mainFrame;
  File? _cameraFrame;
  File? _resultFrame;

  Future<void> saveFrames({
    File? mainFrame,
    File? cameraFrame,
    File? resultFrame,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (mainFrame != null) {
        await prefs.setString('main_frame_path', mainFrame.path);
      } else {
        await prefs.remove('main_frame_path');
      }

      if (cameraFrame != null) {
        await prefs.setString('camera_frame_path', cameraFrame.path);
      } else {
        await prefs.remove('camera_frame_path');
      }

      if (resultFrame != null) {
        await prefs.setString('result_frame_path', resultFrame.path);
      } else {
        await prefs.remove('result_frame_path');
      }
    } catch (e) {
      debugPrint('Error saving frames: $e');
    }
  }

  Future<void> loadSavedFrames({
    Function(File? mainFrame, File? cameraFrame, File? resultFrame)? onLoaded,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? mainFramePath = prefs.getString('main_frame_path');
      if (mainFramePath != null && File(mainFramePath).existsSync()) {
        _mainFrame = File(mainFramePath);
      }

      final String? cameraFramePath = prefs.getString('camera_frame_path');
      if (cameraFramePath != null && File(cameraFramePath).existsSync()) {
        _cameraFrame = File(cameraFramePath);
      }

      final String? resultFramePath = prefs.getString('result_frame_path');
      if (resultFramePath != null && File(resultFramePath).existsSync()) {
        _resultFrame = File(resultFramePath);
      }
    } catch (e) {
      debugPrint('Error loading frames: $e');
    } finally {
      if (onLoaded != null) {
        onLoaded(_mainFrame, _cameraFrame, _resultFrame);
      }
    }
  }
}
