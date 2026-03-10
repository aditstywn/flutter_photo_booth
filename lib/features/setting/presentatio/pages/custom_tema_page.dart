import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_photo_booth/core/extensions/build_context_ext.dart';
import 'package:flutter_photo_booth/features/setting/data/datasource/custom_frame_local_datasource.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/component/space.dart';
import '../../../../core/style/color/colors_app.dart';
import '../widgets/build_frame_card.dart';

class CustomTemaPage extends StatefulWidget {
  const CustomTemaPage({super.key});

  @override
  State<CustomTemaPage> createState() => _CustomTemaPageState();
}

class _CustomTemaPageState extends State<CustomTemaPage> {
  File? _mainFrame;
  File? _cameraFrame;
  File? _resultFrame;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSavedFrames();
  }

  void _loadSavedFrames() {
    CustomFrameLocalDatasource().loadSavedFrames(
      onLoaded: (main, camera, result) {
        setState(() {
          _mainFrame = main;
          _cameraFrame = camera;
          _resultFrame = result;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Tema')),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            BuildFrameCard(
              title: 'Frame Utama',
              subtitle: 'Frame pembuka/welcome screen',
              icon: Icons.home_rounded,
              color: Color(0xFF5F72EB),
              frame: _mainFrame,
              onUpload: () => _pickFrame('main'),
              onDelete: () => _deleteFrame('main'),
            ),
            SpaceHeight(16),
            BuildFrameCard(
              title: 'Frame Kamera',
              subtitle: 'Frame untuk foto kamera',
              icon: Icons.camera_alt_rounded,
              color: Color(0xFF00B894),
              frame: _cameraFrame,
              onUpload: () => _pickFrame('camera'),
              onDelete: () => _deleteFrame('camera'),
            ),
            SpaceHeight(16),

            BuildFrameCard(
              title: 'Frame Hasil',
              subtitle: 'Frame untuk hasil foto',
              icon: Icons.check_circle_rounded,
              color: Color(0xFFFF6B6B),
              frame: _resultFrame,
              onUpload: () => _pickFrame('result'),
              onDelete: () => _deleteFrame('result'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFrame(String frameType) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Save image to permanent location
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName =
            'frame_${frameType}_${DateTime.now().millisecondsSinceEpoch}.png';
        final String savedPath = '${appDir.path}/$fileName';

        final File imageFile = File(pickedFile.path);
        await imageFile.copy(savedPath);

        setState(() {
          switch (frameType) {
            case 'main':
              _mainFrame = File(savedPath);
              break;
            case 'camera':
              _cameraFrame = File(savedPath);

              break;
            case 'result':
              _resultFrame = File(savedPath);
              break;
          }
        });

        await CustomFrameLocalDatasource().saveFrames(
          mainFrame: _mainFrame,
          cameraFrame: _cameraFrame,
          resultFrame: _resultFrame,
        );

        if (mounted) {
          context.showAlertSuccess(message: 'Frame berhasil diunggah');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showAlertError(message: 'Gagal memilih gambar: $e');
      }
    }
  }

  Future<void> _deleteFrame(String frameType) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Frame',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorsApp.primary,
          ),
        ),
        content: Text(
          'Yakin ingin menghapus frame ini?',
          style: TextStyle(color: ColorsApp.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: ColorsApp.primary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        switch (frameType) {
          case 'main':
            _mainFrame = null;
            break;
          case 'camera':
            _cameraFrame = null;
            break;

          case 'result':
            _resultFrame = null;
            break;
        }
      });

      await CustomFrameLocalDatasource().saveFrames(
        mainFrame: _mainFrame,
        cameraFrame: _cameraFrame,
        resultFrame: _resultFrame,
      );

      if (mounted) {
        context.showAlertSuccess(message: 'Frame berhasil dihapus');
      }
    }
  }
}
