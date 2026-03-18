import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/component/space.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/style/thypograpy/photo_booth_text_style.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../core/component/buttons.dart';
import '../../../../core/style/color/colors_app.dart';
import '../../data/datasource/printer_datasource.dart';
import 'print_quality_setting_page.dart';

class SettingPrinterPage extends StatefulWidget {
  const SettingPrinterPage({super.key});

  @override
  State<SettingPrinterPage> createState() => _SettingPrinterPageState();
}

class _SettingPrinterPageState extends State<SettingPrinterPage> {
  final PrinterDatasource _printerDatasource = PrinterDatasource();

  List<BluetoothInfo> _devices = [];
  bool _isLoading = false;
  bool _isConnected = false;
  String? _errorMessage;
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _checkPermissionsAndLoad();
    }
  }

  Future<void> _checkPermissionsAndLoad() async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      final bluetoothStatus = await Permission.bluetoothScan.status;
      final bluetoothConnectStatus = await Permission.bluetoothConnect.status;
      final locationStatus = await Permission.location.status;

      if (!bluetoothStatus.isGranted ||
          !bluetoothConnectStatus.isGranted ||
          !locationStatus.isGranted) {
        await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
        ].request();
      }
    }

    await _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final devices = await _printerDatasource.getBluetoothDevices();
      final connected = await _printerDatasource.isConnected();

      if (mounted) {
        setState(() {
          _devices = devices;
          _isConnected = connected;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _connectToDevice(String macAddress) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final connected = await _printerDatasource.connectToDevice(macAddress);

      if (mounted) {
        setState(() {
          _isConnected = connected;
          _isLoading = false;
        });

        if (connected) {
          context.showAlertSuccess(message: 'Berhasil terhubung ke printer');
        } else {
          context.showAlertError(message: 'Gagal terhubung ke printer');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        context.showAlertError(message: 'Gagal terhubung ke printer: $e');
      }
    }
  }

  Future<void> _disconnect() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _printerDatasource.disconnect();

      if (mounted) {
        setState(() {
          _isConnected = false;
          _isLoading = false;
        });
        context.showAlertSuccess(message: 'Printer terputus');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.showAlertError(message: 'Gagal memutuskan koneksi: $e');
      }
    }
  }

  Future<void> _printImage() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final picker = ImagePicker();
    final XFile? picked = source == ImageSource.camera
        ? await picker.pickImage(source: ImageSource.camera, imageQuality: 90)
        : await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);

    if (picked == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final imageBytes = await picked.readAsBytes();
      await _printerDatasource.printImage(imageBytes);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.showAlertSuccess(
          message: 'Test print berhasil! Periksa hasil cetakan pada printer.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.showAlertError(message: 'Test print gagal: $e');
        debugPrint('Test print error: $e');
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Sumber Gambar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Upload dari Galeri'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Printer'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            )
          : _isConnected
          ? _buildConnectedView()
          : _buildDevicesList(),
    );
  }

  Widget _buildDevicesList() {
    if (_devices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.bluetooth_disabled,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada perangkat Bluetooth yang dipasangkan',
                textAlign: TextAlign.center,
                style: PhotoBoothTextStyle.titleSmall.copyWith(
                  color: Colors.grey,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              Button.filled(
                label: 'Refresh',
                onPressed: _loadDevices,
                color: ColorsApp.primary,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDevices,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: ColorsApp.white,
            child: ListTile(
              leading: const Icon(
                Icons.print,
                size: 40,
                color: ColorsApp.primary,
              ),
              title: Text(
                device.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(device.macAdress),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showConnectDialog(device),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Printer Terhubung',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Button.filled(
              label: 'Test Print',
              onPressed: _printImage,
              color: ColorsApp.primary,
            ),
            SpaceHeight(8),
            Button.outlined(
              onPressed: () {
                context.push(const PrintQualitySettingPage());
              },
              label: 'Atur Kualitas Cetak',
              icon: Icon(Icons.tune, color: ColorsApp.primary),
              color: Colors.white,
            ),
            SpaceHeight(8),
            Button.filled(
              onPressed: () => _disconnect(),
              label: 'Putuskan Koneksi',
              color: Colors.red,
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await _disconnect();
                await _loadDevices();
              },
              child: const Text('Pilih Printer Lain'),
            ),
          ],
        ),
      ),
    );
  }

  void _showConnectDialog(BluetoothInfo device) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ColorsApp.white,
        title: const Text(
          'Hubungkan Printer',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorsApp.primary,
          ),
        ),
        content: Text(
          'Hubungkan ke ${device.name}?',
          style: TextStyle(color: ColorsApp.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _connectToDevice(device.macAdress);
            },
            child: const Text('Hubungkan'),
          ),
        ],
      ),
    );
  }
}
