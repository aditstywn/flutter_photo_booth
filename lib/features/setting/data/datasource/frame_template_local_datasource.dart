import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/request/frame_template.dart';

class FrameTemplateLocalDatasource {
  static const String _templatesKey = 'frame_templates';

  // Simpan semua templates
  Future<void> saveAllTemplates(
    List<FrameTemplate> templates, {
    Function()? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = templates
          .map((template) => template.toJson())
          .toList();
      await prefs.setString(_templatesKey, jsonEncode(templatesJson));

      if (onSuccess != null) {
        onSuccess();
      }
    } catch (e) {
      debugPrint('Error saving templates: $e');
      if (onError != null) {
        onError(e.toString());
      }
    }
  }

  // Load semua templates
  Future<List<FrameTemplate>> loadAllTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJsonString = prefs.getString(_templatesKey);

      if (templatesJsonString == null) {
        return [];
      }

      final List<dynamic> templatesJson = jsonDecode(templatesJsonString);
      return templatesJson.map((json) => FrameTemplate.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading templates: $e');
      return [];
    }
  }

  // Simpan atau update template
  Future<void> saveTemplate(
    FrameTemplate template, {
    Function()? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      // Load templates yang sudah ada
      final templates = await loadAllTemplates();

      // Cek apakah template dengan ID yang sama sudah ada
      final existingIndex = templates.indexWhere((t) => t.id == template.id);

      if (existingIndex != -1) {
        // Update template yang sudah ada
        templates[existingIndex] = template;
      } else {
        // Tambah template baru
        templates.add(template);
      }

      // Simpan semua templates
      await saveAllTemplates(templates, onSuccess: onSuccess, onError: onError);
    } catch (e) {
      debugPrint('Error saving template: $e');
      if (onError != null) {
        onError(e.toString());
      }
    }
  }

  // Hapus template
  Future<void> deleteTemplate(
    String templateId, {
    Function()? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      // Load templates yang sudah ada
      final templates = await loadAllTemplates();

      // Hapus file frame jika ada
      final template = templates.firstWhere(
        (t) => t.id == templateId,
        orElse: () => throw Exception('Template not found'),
      );

      final frameFile = File(template.framePath);
      if (await frameFile.exists()) {
        await frameFile.delete();
      }

      // Hapus template dari list
      templates.removeWhere((t) => t.id == templateId);

      // Simpan ulang
      await saveAllTemplates(templates, onSuccess: onSuccess, onError: onError);
    } catch (e) {
      debugPrint('Error deleting template: $e');
      if (onError != null) {
        onError(e.toString());
      }
    }
  }

  // Get template by ID
  Future<FrameTemplate?> getTemplateById(String templateId) async {
    try {
      final templates = await loadAllTemplates();
      return templates.firstWhere(
        (t) => t.id == templateId,
        orElse: () => throw Exception('Template not found'),
      );
    } catch (e) {
      debugPrint('Error getting template: $e');
      return null;
    }
  }
}
