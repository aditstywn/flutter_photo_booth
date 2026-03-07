import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

class PrinterDatasource {
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
      final generator = Generator(PaperSize.mm58, profile);

      final img.Image? image = img.decodeImage(imageBytes);
      if (image != null) {
        final img.Image resized = img.copyResize(image, width: 384);
        bytes.addAll(generator.imageRaster(resized, align: PosAlign.center));
        // bytes.addAll(generator.emptyLines(1));
      }

      bytes.addAll(
        generator.feed(1),
      ); // Menambahkan satu baris kosong setelah gambar
      bytes.addAll(
        generator.cut(),
      ); // Memotong kertas setelah mencetak, jika printer mendukung fitur ini

      await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      throw Exception('Failed to test print: $e');
    }
  }
}
