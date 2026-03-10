import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

import '../models/request/print_settings.dart';
import 'print_settings_datasource.dart';

class PrinterDatasource {
  final PrintSettingsDatasource _settingsDatasource = PrintSettingsDatasource();
  Future<List<BluetoothInfo>> getBluetoothDevices() async {
    try {
      final List<BluetoothInfo> devices =
          await PrintBluetoothThermal.pairedBluetooths;
      return devices;
    } catch (e) {
      throw Exception('Failed to get bluetooth devices: $e');
    }
  }

  Future<bool> connectToDevice(String macAddress) async {
    try {
      final bool connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: macAddress,
      );
      return connected;
    } catch (e) {
      throw Exception('Failed to connect to device: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
    } catch (e) {
      throw Exception('Failed to disconnect: $e');
    }
  }

  Future<bool> isConnected() async {
    try {
      final bool connected = await PrintBluetoothThermal.connectionStatus;
      return connected;
    } catch (e) {
      return false;
    }
  }

  Future<void> printImage(Uint8List imageBytes) async {
    try {
      bool connected = await isConnected();
      if (!connected) {
        throw Exception('Printer not connected');
      }

      List<int> bytes = [];
      final profile = await CapabilityProfile.load();
      final generator = Generator(
        PaperSize.mm58,
        profile,
      ); // mm80 -> 576 atau mm58 -> 384

      final img.Image? image = img.decodeImage(imageBytes);
      if (image != null) {
        // Resize terlebih dahulu
        final img.Image resized = img.copyResize(image, width: 384);

        // Load settings dan preprocessing untuk kualitas cetak yang lebih baik
        final settings = await _settingsDatasource.loadSettings();
        final img.Image processed = await _preprocessImageForThermalPrint(
          resized,
          settings,
        );

        bytes.addAll(generator.feed(2));
        // bytes.addAll(generator.emptyLines(1));

        bytes.addAll(generator.imageRaster(processed, align: PosAlign.center));

        // bytes.addAll(generator.emptyLines(1));
        // bytes.addAll(generator.feed(1));
      }

      bytes.addAll(
        generator.cut(),
      ); // Memotong kertas setelah mencetak, jika printer mendukung fitur ini

      await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      throw Exception('Failed to test print: $e');
    }
  }

  /// Preprocessing gambar untuk hasil cetakan thermal yang lebih baik
  /// Menggunakan teknik: grayscale, contrast enhancement, dan dithering
  /// Settings diambil dari user preferences
  Future<img.Image> _preprocessImageForThermalPrint(
    img.Image image,
    PrintSettings settings,
  ) async {
    // 1. Konversi ke grayscale
    img.Image processed = img.grayscale(image);

    // 2. Apply brightness & contrast dari settings user
    processed = img.adjustColor(
      processed,
      contrast: settings.contrast,
      brightness: settings.brightness,
    );

    // 3. Sharpen untuk meningkatkan ketajaman detail wajah (optional)
    // processed = img.sharpen(processed, amount: 1.5);

    // 4. Dithering untuk konversi halftone yang lebih baik
    // Floyd-Steinberg dithering mempertahankan detail gambar saat konversi ke B&W
    processed = _applyFloydSteinbergDithering(processed, settings.threshold);

    return processed;
  }

  /// Floyd-Steinberg Dithering Algorithm
  /// Teknik terbaik untuk konversi grayscale ke black & white
  /// dengan mempertahankan detail dan gradasi
  img.Image _applyFloydSteinbergDithering(img.Image image, int threshold) {
    final img.Image dithered = img.Image.from(image);

    for (int y = 0; y < dithered.height; y++) {
      for (int x = 0; x < dithered.width; x++) {
        final oldPixel = dithered.getPixel(x, y);
        final oldGray = oldPixel.r.toInt(); // Karena sudah grayscale, R=G=B

        // Threshold dari user settings
        // Threshold tinggi = lebih cerah (lebih banyak area putih)
        // Threshold rendah = lebih gelap (lebih banyak area hitam)
        final newGray = oldGray < threshold ? 0 : 255;

        // Set pixel baru
        dithered.setPixelRgba(x, y, newGray, newGray, newGray, 255);

        // Hitung error
        final error = oldGray - newGray;

        // Distribusikan error ke pixel tetangga (Floyd-Steinberg)
        if (x + 1 < dithered.width) {
          _addError(dithered, x + 1, y, error * 7 / 16);
        }
        if (y + 1 < dithered.height) {
          if (x - 1 >= 0) {
            _addError(dithered, x - 1, y + 1, error * 3 / 16);
          }
          _addError(dithered, x, y + 1, error * 5 / 16);
          if (x + 1 < dithered.width) {
            _addError(dithered, x + 1, y + 1, error * 1 / 16);
          }
        }
      }
    }

    return dithered;
  }

  /// Helper untuk menambahkan error ke pixel
  void _addError(img.Image image, int x, int y, double error) {
    final pixel = image.getPixel(x, y);
    final gray = pixel.r.toInt();
    final newGray = (gray + error).clamp(0, 255).toInt();
    image.setPixelRgba(x, y, newGray, newGray, newGray, 255);
  }
}
