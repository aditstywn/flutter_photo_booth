import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/request/button_area.dart';

class CustomButtonLocalDatasource {
  Future<void> saveConfiguration({
    List<ButtonArea>? buttonAreasLanding,
    ButtonArea? cameraPreviewArea,
    List<ButtonArea>? cameraButtonAreas,
    ButtonArea? resultPreviewArea,
    List<ButtonArea>? buttonAreasResult,
    Function? onSuccess,
    Function? onError,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Simpan area tombol untuk frame landing
      final List<Map<String, dynamic>> landingAreasJson =
          buttonAreasLanding?.map((area) => area.toJson()).toList() ?? [];
      await prefs.setString('button_areas_main', jsonEncode(landingAreasJson));

      // Simpan area camera preview
      if (cameraPreviewArea != null) {
        await prefs.setString(
          'camera_preview_area',
          jsonEncode(cameraPreviewArea.toJson()),
        );
      } else {
        await prefs.remove('camera_preview_area');
      }

      // Simpan area tombol kamera
      final List<Map<String, dynamic>> cameraButtonsJson =
          cameraButtonAreas?.map((area) => area.toJson()).toList() ?? [];
      await prefs.setString(
        'camera_button_areas',
        jsonEncode(cameraButtonsJson),
      );

      // Simpan area preview untuk frame hasil
      if (resultPreviewArea != null) {
        await prefs.setString(
          'result_preview_area',
          jsonEncode(resultPreviewArea.toJson()),
        );
      } else {
        await prefs.remove('result_preview_area');
      }

      // Simpan area tombol untuk frame hasil
      final List<Map<String, dynamic>> areasJson =
          buttonAreasResult?.map((area) => area.toJson()).toList() ?? [];
      await prefs.setString('button_areas_result', jsonEncode(areasJson));

      onSuccess?.call();
    } catch (e) {
      onError?.call(e);
    }
  }

  Future<void> loadConfiguration({
    Function(List<ButtonArea> buttonAreasMain)? onLoadedMain,
    Function(ButtonArea? cameraPreviewArea)? onLoadedCameraPreview,
    Function(ButtonArea? resultPreviewArea)? onLoadedResultPreview,
    Function(List<ButtonArea> cameraButtonAreas)? onLoadedCameraButtons,
    Function(List<ButtonArea> buttonAreasResult)? onLoadedResult,
    Function(Object error)? onError,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load area tombol untuk frame main
      final String? mainAreasString = prefs.getString('button_areas_main');
      if (mainAreasString != null) {
        final List<dynamic> mainAreasJson = jsonDecode(mainAreasString);
        final List<ButtonArea> mainAreas = mainAreasJson
            .map((json) => ButtonArea.fromJson(json))
            .toList();
        onLoadedMain?.call(mainAreas);
      }

      // Load area camera preview
      final String? cameraPreviewString = prefs.getString(
        'camera_preview_area',
      );
      if (cameraPreviewString != null) {
        final Map<String, dynamic> cameraPreviewJson = jsonDecode(
          cameraPreviewString,
        );
        final ButtonArea cameraPreviewArea = ButtonArea.fromJson(
          cameraPreviewJson,
        );
        onLoadedCameraPreview?.call(cameraPreviewArea);
      }

      // Load area tombol kamera
      final String? cameraButtonsString = prefs.getString(
        'camera_button_areas',
      );
      if (cameraButtonsString != null) {
        final List<dynamic> cameraButtonsJson = jsonDecode(cameraButtonsString);
        final List<ButtonArea> cameraButtonAreas = cameraButtonsJson
            .map((json) => ButtonArea.fromJson(json))
            .toList();
        onLoadedCameraButtons?.call(cameraButtonAreas);
      }

      // Load area preview untuk frame hasil
      final String? resultPreviewString = prefs.getString(
        'result_preview_area',
      );
      if (resultPreviewString != null) {
        final Map<String, dynamic> resultPreviewJson = jsonDecode(
          resultPreviewString,
        );
        final ButtonArea resultPreviewArea = ButtonArea.fromJson(
          resultPreviewJson,
        );
        onLoadedResultPreview?.call(resultPreviewArea);
      }

      // Load area tombol untuk frame hasil
      final String? areasString = prefs.getString('button_areas_result');
      if (areasString != null) {
        final List<dynamic> areasJson = jsonDecode(areasString);
        final List<ButtonArea> buttonAreasResult = areasJson
            .map((json) => ButtonArea.fromJson(json))
            .toList();
        onLoadedResult?.call(buttonAreasResult);
      }
    } catch (e) {
      onError?.call(e);
    }
  }
}
