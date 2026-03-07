import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/component/space.dart';
import '../../data/datasource/custom_button_local_datasource.dart';
import '../../data/datasource/custom_frame_local_datasource.dart';
import '../../data/datasource/frame_template_local_datasource.dart';
import '../../data/models/request/button_area.dart';
import '../../data/models/request/frame_template.dart';

class TestAreaButtonPage extends StatefulWidget {
  const TestAreaButtonPage({super.key});

  @override
  State<TestAreaButtonPage> createState() => _TestAreaButtonPageState();
}

class _TestAreaButtonPageState extends State<TestAreaButtonPage> {
  File? _mainFrame;
  File? _cameraFrame;
  File? _resultFrame;

  String _selectedFrame = 'main';

  // Pengaturan area tombol untuk frame main
  List<ButtonArea> _buttonAreasMain = [];

  // Pengaturan Frame Kamera
  ButtonArea? _cameraPreviewArea;
  List<ButtonArea> _cameraButtonAreas = []; // Untuk tombol Take Photo

  // Pengaturan Frame Hasil
  ButtonArea? _resultPreviewArea;
  List<ButtonArea> _buttonAreasResult = [];

  // Frame Template variables
  List<FrameTemplate> _availableTemplates = [];
  FrameTemplate? _selectedTemplate;

  // Camera variables
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  // Photo capture variables
  Map<int, File> _uploadedPhotos = {}; // indeks -> file foto
  int _countdownValue = 0; // 0 = tidak countdown
  int _countdownPhotoIndex = 0; // foto ke-berapa yang sedang di-countdown

  // Template image size (untuk BoxFit.contain offset correction)
  Size? _templateImageSize;

  final ImagePicker _picker = ImagePicker();

  final GlobalKey _compositeKey = GlobalKey();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadSavedFrames();
    _loadSavedButtonAreas();
    _loadTemplates();
    _initializeCamera();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras[1], // Gunakan kamera depan (selfie)
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
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

  void _loadSavedButtonAreas() {
    CustomButtonLocalDatasource().loadConfiguration(
      onLoadedMain: (areas) {
        setState(() {
          _buttonAreasMain = areas;
        });
      },
      onLoadedCameraPreview: (area) {
        setState(() {
          _cameraPreviewArea = area;
        });
      },
      onLoadedCameraButtons: (areas) {
        setState(() {
          _cameraButtonAreas = areas;
        });
      },
      onLoadedResultPreview: (resultPreviewArea) {
        setState(() {
          _resultPreviewArea = resultPreviewArea;
        });
      },

      onLoadedResult: (areas) {
        setState(() {
          _buttonAreasResult = areas;
        });
      },
      onError: (e) {
        debugPrint('Error loading button areas: $e');
      },
    );
  }

  Future<void> _loadTemplates() async {
    final templates = await FrameTemplateLocalDatasource().loadAllTemplates();
    setState(() {
      _availableTemplates = templates;
    });
  }

  /// Memuat dimensi gambar template secara async menggunakan ImageStream.
  /// Hasilnya disimpan ke [_templateImageSize] untuk digunakan
  /// menghitung offset BoxFit.contain di _buildResultPreviewWidget.
  Future<void> _loadTemplateImageSize(String imagePath) async {
    final file = File(imagePath);
    if (!file.existsSync()) return;

    final completer = Completer<Size>();
    final imageProvider = FileImage(file);
    final stream = imageProvider.resolve(const ImageConfiguration());
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        if (!completer.isCompleted) {
          completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble()),
          );
        }
        stream.removeListener(listener);
      },
      onError: (e, st) {
        if (!completer.isCompleted) completer.completeError(e);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);

    try {
      final size = await completer.future;
      if (mounted) {
        setState(() {
          _templateImageSize = size;
        });
      }
    } catch (e) {
      debugPrint('Error loading template image size: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: _buildEditSection());
  }

  Widget _buildEditSection() {
    // Tampilkan list template jika tab template dipilih
    if (_selectedFrame == 'template') {
      return _buildTemplateList();
    }

    File? currentFrame;
    currentFrame = _selectedFrame == 'main'
        ? _mainFrame
        : _selectedFrame == 'camera'
        ? _cameraFrame
        : _resultFrame;

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (currentFrame == null)
            Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  'No frame uploaded',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Image.file(
              currentFrame,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.fill,
            ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, stackConstraints) {
                // Validasi constraint
                if (stackConstraints.maxWidth.isInfinite ||
                    stackConstraints.maxHeight.isInfinite ||
                    stackConstraints.maxWidth == 0 ||
                    stackConstraints.maxHeight == 0) {
                  return SizedBox.shrink();
                }

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Gambar area
                    if (_selectedFrame == 'main') ...[
                      ..._buttonAreasMain.map((area) {
                        return _buildTappableArea(
                          area: area,
                          constraints: stackConstraints,
                        );
                      }),
                    ] else if (_selectedFrame == 'camera') ...[
                      if (_cameraPreviewArea != null)
                        _buildTappableArea(
                          area: _cameraPreviewArea!,
                          isCameraPreview: true,
                          constraints: stackConstraints,
                        ),
                      ..._cameraButtonAreas.map((area) {
                        return _buildTappableArea(
                          area: area,
                          constraints: stackConstraints,
                        );
                      }),
                    ] else if (_selectedFrame == 'result') ...[
                      if (_resultPreviewArea != null)
                        _buildTappableArea(
                          area: _resultPreviewArea!,
                          isResultPreview: true,
                          constraints: stackConstraints,
                        ),
                      ..._buttonAreasResult.map((area) {
                        return _buildTappableArea(
                          area: area,
                          constraints: stackConstraints,
                        );
                      }),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan list template
  Widget _buildTemplateList() {
    if (_availableTemplates.isEmpty) {
      return SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_album_outlined,
                size: 80,
                color: Colors.grey[300],
              ),
              SizedBox(height: 16),
              Text(
                'Belum Ada Template',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Buat template terlebih dahulu',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          if (_selectedTemplate != null)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF00B8D4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Template dipilih: ${_selectedTemplate!.name}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedFrame = 'camera';
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF00B8D4),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text('Lanjut Ambil Foto'),
                  ),
                ],
              ),
            ),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: _availableTemplates.length,
            itemBuilder: (context, index) {
              final template = _availableTemplates[index];
              final isSelected = _selectedTemplate?.id == template.id;
              return _buildTemplateCard(template, isSelected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(FrameTemplate template, bool isSelected) {
    final frameFile = File(template.framePath);
    final frameExists = frameFile.existsSync();

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTemplate = template;
          _templateImageSize = null; // reset lalu muat ulang
        });
        _loadTemplateImageSize(template.framePath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Template "${template.name}" dipilih'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFF00B8D4),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xFF00B8D4) : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview Frame
            Expanded(
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: frameExists
                      ? Image.file(frameFile, fit: BoxFit.cover)
                      : Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey[400],
                            size: 40,
                          ),
                        ),
                ),
              ),
            ),
            // Info
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.photo_library, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        '${template.numberOfPhotoStrips} Photos',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  if (isSelected)
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF00B8D4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '✓ Terpilih',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTappableArea({
    required ButtonArea area,
    bool isCameraPreview = false,
    bool isResultPreview = false,
    required BoxConstraints constraints,
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
          ? _buildCameraPreviewWidget(area, constraints)
          : isResultPreview
          ? Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: _buildResultPreviewWidget(area, constraints),
            )
          : GestureDetector(
              onTap: () {
                _handleAreaTap(area.function);

                if (area.function == 'Start') {
                  setState(() {
                    _selectedFrame = 'template';
                  });
                } else if (area.function == 'Take Photo') {
                  // setState(() {
                  //   _selectedFrame = 'result';
                  // });
                }
              },
              child: Container(
                width: pixelWidth,
                height: pixelHeight,
                color: Colors.transparent,
              ),
            ),
    );
  }

  void _handleAreaTap(String function) {
    // Jika Take Photo, mulai proses pengambilan foto
    if (function == 'Take Photo') {
      _startPhotoCapture();
      return;
    }

    if (function == 'Print') {
      _saveCompositeImage();
      return;
    }

    // Jika Retake, tampilkan dialog retake
    if (function == 'Retake') {
      _handleRetake();
      return;
    }

    String message;
    Color backgroundColor;
    IconData icon;

    switch (function) {
      case 'Take Photo':
        message = 'Take Photo - Mengambil foto';
        backgroundColor = Color(0xFF5F72EB);
        icon = Icons.camera;
        break;
      case 'Retake':
        message = 'Retake - Mengulang pengambilan foto';
        backgroundColor = Color(0xFFFF6B6B);
        icon = Icons.refresh;
        break;
      case 'Print':
        message = 'Print - Mencetak foto';
        backgroundColor = Color(0xFF5F72EB);
        icon = Icons.print;
        break;
      case 'Scan QR':
        message = 'Scan QR - Scan QR code untuk mendapatkan foto';
        backgroundColor = Color(0xFF00B894);
        icon = Icons.qr_code_scanner;
        break;
      default:
        message = function;
        backgroundColor = Color(0xFF636E72);
        icon = Icons.touch_app;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _startPhotoCapture() async {
    if (_cameraController == null || !_isCameraInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kamera belum siap'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final int totalPhotos = _selectedTemplate?.numberOfPhotoStrips ?? 1;

    setState(() {
      _uploadedPhotos.clear();
    });

    for (int i = 0; i < totalPhotos; i++) {
      // Countdown 3, 2, 1 tampil di atas camera preview
      for (int countdown = 3; countdown > 0; countdown--) {
        if (!mounted) return;
        setState(() {
          _countdownValue = countdown;
          _countdownPhotoIndex = i + 1;
        });
        await Future.delayed(Duration(seconds: 1));
      }

      if (!mounted) return;
      setState(() {
        _countdownValue = 0;
      });

      try {
        final XFile photo = await _cameraController!.takePicture();
        setState(() {
          _uploadedPhotos[i] = File(photo.path);
        });

        if (i < totalPhotos - 1) {
          await Future.delayed(Duration(milliseconds: 600));
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _countdownValue = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error mengambil foto ${i + 1}: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (!mounted) return;

    // Semua foto sudah diambil, pindah ke result frame
    if (_uploadedPhotos.length == totalPhotos) {
      setState(() {
        _selectedFrame = 'result';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.photo_library, color: Colors.white),
              SizedBox(width: 12),
              Text('Semua $totalPhotos foto berhasil diambil!'),
            ],
          ),
          backgroundColor: Color(0xFF00B894),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildCameraPreviewWidget(
    ButtonArea area,
    BoxConstraints constraints,
  ) {
    // Convert normalized values (0-1) to pixels
    final containerWidth = constraints.maxWidth;
    final containerHeight = constraints.maxHeight;

    final normalizedWidth = area.width > 1.0
        ? area.width / containerWidth
        : area.width;
    final normalizedHeight = area.height > 1.0
        ? area.height / containerHeight
        : area.height;

    final pixelWidth = (normalizedWidth * containerWidth).clamp(
      10.0,
      containerWidth,
    );
    final pixelHeight = (normalizedHeight * containerHeight).clamp(
      10.0,
      containerHeight,
    );
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        width: pixelWidth,
        height: pixelHeight,
        decoration: BoxDecoration(color: Colors.black87),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              SizedBox(height: 12),
              Text(
                'Memuat kamera...',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: pixelWidth,
      height: pixelHeight,
      child: Stack(
        children: [
          // Bungkus CameraPreview dengan Positioned.fill agar tidak gepeng
          Positioned.fill(
            child: ClipRRect(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize!.height,
                  height: _cameraController!.value.previewSize!.width,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),
          ),
          // Overlay countdown
          if (_countdownValue > 0)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(120),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Foto $_countdownPhotoIndex / ${_selectedTemplate?.numberOfPhotoStrips ?? 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$_countdownValue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultPreviewWidget(
    ButtonArea area,
    BoxConstraints constraints,
  ) {
    // Convert normalized values (0-1) to pixels
    final containerWidth = constraints.maxWidth;
    final containerHeight = constraints.maxHeight;

    final normalizedWidth = area.width > 1.0
        ? area.width / containerWidth
        : area.width;
    final normalizedHeight = area.height > 1.0
        ? area.height / containerHeight
        : area.height;

    final pixelWidth = (normalizedWidth * containerWidth).clamp(
      10.0,
      containerWidth,
    );

    // Hitung tinggi aktual berdasarkan aspect ratio gambar (BoxFit.fitWidth)
    // sehingga tidak ada ruang kosong di bawah.
    final double actualHeight = _templateImageSize != null
        ? pixelWidth * (_templateImageSize!.height / _templateImageSize!.width)
        : (normalizedHeight * containerHeight).clamp(10.0, containerHeight);

    return RepaintBoundary(
      key: _compositeKey,
      child: SizedBox(
        width: pixelWidth,
        height: actualHeight,
        child: Stack(
          children: [
            Container(
              width: pixelWidth,
              height: actualHeight,
              color: Colors.black.withAlpha(50),
            ),
            // Overlay area foto: diposisikan sesuai ukuran AKTUAL gambar
            if (_selectedTemplate != null && _templateImageSize != null)
              _buildTemplateAreaOverlay(
                containerWidth: pixelWidth,
                containerHeight: actualHeight,
                imageSize: _templateImageSize!,
              ),
            // Hanya tampilkan image jika ada template
            if (_selectedTemplate?.framePath != null)
              Image.file(
                File(_selectedTemplate!.framePath),
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
          ],
        ),
      ),
    );
  }

  /// Membangun overlay area foto yang diposisikan sesuai batas AKTUAL gambar
  /// yang di-render dengan [BoxFit.contain] di dalam container
  /// [containerWidth] x [containerHeight].
  ///
  /// BoxFit.contain menjaga aspect ratio gambar sehingga mungkin ada
  /// ruang kosong (letterbox) di kiri/kanan atau atas/bawah.
  /// Overlay harus dimulai dari tepi gambar aktual, bukan tepi container.
  Widget _buildTemplateAreaOverlay({
    required double containerWidth,
    required double containerHeight,
    required Size imageSize,
  }) {
    // Hitung skala BoxFit.contain: pilih skala terkecil agar gambar muat
    final scale = math.min(
      containerWidth / imageSize.width,
      containerHeight / imageSize.height,
    );
    final renderedWidth = imageSize.width * scale;
    final renderedHeight = imageSize.height * scale;

    // Offset letterbox (ruang kosong di kiri/kanan atau atas/bawah)
    final offsetX = (containerWidth - renderedWidth) / 2;
    final offsetY = (containerHeight - renderedHeight) / 2;

    final renderedConstraints = BoxConstraints(
      maxWidth: renderedWidth,
      maxHeight: renderedHeight,
    );

    return Positioned(
      left: offsetX,
      top: offsetY,
      width: renderedWidth,
      height: renderedHeight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          // border: Border.all(color: Colors.redAccent, width: 1),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ..._selectedTemplate?.photoAreas.asMap().entries.map((entry) {
                  final photoIndex = entry.key;
                  final area = entry.value;
                  return _buildAreaWidget(
                    area: area,
                    index: photoIndex,
                    constraints: renderedConstraints,
                  );
                }) ??
                [],
          ],
        ),
      ),
    );
  }

  Widget _buildAreaWidget({
    required int index,
    required ButtonArea area,
    required BoxConstraints constraints,
  }) {
    // Convert normalized values (0-1) to pixels
    final containerWidth = constraints.maxWidth;
    final containerHeight = constraints.maxHeight;

    // Validasi dan clamp nilai normalized
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

    // Jika sudah upload foto, tampilkan preview foto di area tersebut
    if (_uploadedPhotos.containsKey(index)) {
      return Positioned(
        left: pixelX,
        top: pixelY,
        child: Container(
          width: pixelWidth,
          height: pixelHeight,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(_uploadedPhotos[index]!),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    return Positioned(
      left: pixelX,
      top: pixelY,
      child: GestureDetector(
        onTap: () {
          _handlePhotoAreaTap(index);
        },
        child: Container(
          width: pixelWidth,
          height: pixelHeight,
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(80),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Stack(
            children: [
              // Label area foto
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_library, color: Colors.white, size: 32),
                    SizedBox(height: 4),
                    Text(
                      'Photo ${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk handle tap pada photo area
  Future<void> _handlePhotoAreaTap(int photoIndex) async {
    // Show bottom sheet untuk pilih sumber foto
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Sumber Foto ${photoIndex + 1}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Color(0xFF00B8D4)),
              title: Text('Ambil dari Kamera'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Color(0xFF00B8D4)),
              title: Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            if (_uploadedPhotos.containsKey(photoIndex))
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Hapus Foto'),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
          ],
        ),
      ),
    );

    if (result == 'camera') {
      await _pickImageFromCamera(photoIndex);
    } else if (result == 'gallery') {
      await _pickImageFromGallery(photoIndex);
    } else if (result == 'delete') {
      setState(() {
        _uploadedPhotos.remove(photoIndex);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo ${photoIndex + 1} dihapus'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk ambil foto dari kamera
  Future<void> _pickImageFromCamera(int photoIndex) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (image != null) {
        setState(() {
          _uploadedPhotos[photoIndex] = File(image.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo ${photoIndex + 1} berhasil diambil'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFF00B8D4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk pilih foto dari galeri
  Future<void> _pickImageFromGallery(int photoIndex) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _uploadedPhotos[photoIndex] = File(image.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo ${photoIndex + 1} berhasil dipilih'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFF00B8D4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveCompositeImage() async {
    if (_uploadedPhotos.length != _selectedTemplate?.numberOfPhotoStrips) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload all photos first'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Tangkap widget komposit sebagai gambar
      RenderRepaintBoundary boundary =
          _compositeKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      // Tunggu frame berikutnya untuk memastikan rendering selesai
      await Future.delayed(Duration(milliseconds: 100));

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();

      // Simpan ke perangkat
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '${directory.path}/photoboot_${timestamp}.png';

      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      // Simpan ke galeri/hasil terbaru
      final prefs = await SharedPreferences.getInstance();
      List<String> recentResults = prefs.getStringList('recent_results') ?? [];
      recentResults.insert(0, imagePath);

      // Simpan setiap foto individual yang dipakai ke galeri
      for (int i = 0; i < (_selectedTemplate?.numberOfPhotoStrips ?? 1); i++) {
        if (_uploadedPhotos.containsKey(i)) {
          await Gal.putImage(
            _uploadedPhotos[i]!.path,
            album: 'PhotoBoot Results',
          );
        }
      }

      // Simpan hasil komposit ke galeri
      await Gal.putImage(imageFile.path, album: 'PhotoBoot Results');

      // Simpan hanya 50 hasil terakhir
      if (recentResults.length > 50) {
        recentResults = recentResults.take(50).toList();
      }

      await prefs.setStringList('recent_results', recentResults);

      if (mounted) {
        // Tampilkan dialog sukses dengan pratinjau & form WA
        showDialog(
          context: context,
          builder: (dialogContext) {
            final waController = TextEditingController();
            bool isSendingWa = false;
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  backgroundColor: Color(0xFF2A2A3E),
                  title: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 28),
                      SpaceWidth(12),
                      Text('Tersimpan!', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            imageFile,
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SpaceHeight(16),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check, color: Colors.green, size: 14),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Gambar berhasil disimpan',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SpaceHeight(20),
                        Divider(color: Colors.white24),
                        SpaceHeight(12),
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Color(0xFF25D366),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  'W',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Kirim ke WhatsApp',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SpaceHeight(10),
                        TextField(
                          controller: waController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Contoh: 628123456789',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Color(0xFF25D366),
                              size: 20,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.white24),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Color(0xFF25D366)),
                            ),
                            filled: true,
                            fillColor: Colors.white10,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                        SpaceHeight(8),
                        Text(
                          'Masukkan nomor WA dengan kode negara (tanpa +)',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        SpaceHeight(10),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFF25D366).withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFF25D366).withAlpha(80),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFF25D366),
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Foto otomatis disimpan ke Galeri.\nBuka WA → ketuk lampiran (📎) → pilih dari Galeri.',
                                  style: TextStyle(
                                    color: Color(0xFF25D366),
                                    fontSize: 10,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context, true);
                      },
                      child: Text(
                        'Tutup',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: isSendingWa
                          ? null
                          : () async {
                              final rawNumber = waController.text
                                  .trim()
                                  .replaceAll(RegExp(r'[^0-9]'), '');
                              if (rawNumber.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Masukkan nomor WhatsApp'),
                                    backgroundColor: Colors.orange,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              setDialogState(() => isSendingWa = true);
                              try {
                                // Buka WhatsApp langsung ke chat nomor
                                // (berfungsi meski nomor tidak ada di kontak)
                                final waUrl = Uri.parse(
                                  'whatsapp://send?phone=$rawNumber&text=Foto+dari+Photo+Booth',
                                );
                                if (await canLaunchUrl(waUrl)) {
                                  await launchUrl(
                                    waUrl,
                                    mode: LaunchMode.externalApplication,
                                  );
                                  // Reminder untuk attach foto
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Ketuk 📎 di WA → pilih foto dari Galeri',
                                        ),
                                        backgroundColor: Color(0xFF25D366),
                                        behavior: SnackBarBehavior.floating,
                                        duration: Duration(seconds: 5),
                                      ),
                                    );
                                  }
                                } else {
                                  // WA tidak terinstall, fallback ke share sheet
                                  await Share.shareXFiles([
                                    XFile(imagePath),
                                  ], text: 'Foto dari Photo Booth');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } finally {
                                setDialogState(() => isSendingWa = false);
                              }
                            },
                      icon: isSendingWa
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.send, size: 16),
                      label: Text('Buka WA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        print('Error saving image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving image: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _retakeSinglePhoto(int photoIndex) async {
    if (_cameraController == null || !_isCameraInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kamera belum siap'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Hapus foto lama dan pindah ke tab camera
    setState(() {
      _uploadedPhotos.remove(photoIndex);
      _selectedFrame = 'camera';
    });

    // Countdown 3, 2, 1
    for (int countdown = 3; countdown > 0; countdown--) {
      if (!mounted) return;
      setState(() {
        _countdownValue = countdown;
        _countdownPhotoIndex = photoIndex + 1;
      });
      await Future.delayed(Duration(seconds: 1));
    }

    if (!mounted) return;
    setState(() {
      _countdownValue = 0;
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _uploadedPhotos[photoIndex] = File(photo.path);
        _selectedFrame = 'result'; // Kembali ke result setelah foto diambil
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Foto ${photoIndex + 1} berhasil diambil ulang'),
              ],
            ),
            backgroundColor: Color(0xFF00B894),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _countdownValue = 0;
        _selectedFrame = 'result';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error mengambil foto: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleRetake() async {
    final int totalPhotos = _selectedTemplate?.numberOfPhotoStrips ?? 1;

    if (totalPhotos <= 1) {
      // Hanya 1 foto: langsung konfirmasi retake
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Konfirmasi'),
            content: Text(
              'Apakah Anda yakin ingin mengambil ulang foto?',
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _retakeSinglePhoto(0);
                },
                child: Text('Ambil Ulang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00B894),
                ),
              ),
            ],
          );
        },
      );
    }

    // Lebih dari 1 foto: pilih foto mana yang ingin di-retake
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Foto untuk Diulang'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih foto mana yang ingin diambil ulang, atau ulang semua.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                SizedBox(height: 12),
                ...List.generate(totalPhotos, (index) {
                  final hasPhoto = _uploadedPhotos.containsKey(index);
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                    leading: CircleAvatar(
                      backgroundColor: hasPhoto
                          ? Color(0xFF00B8D4)
                          : Colors.grey[300],
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: hasPhoto ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text('Foto ${index + 1}'),
                    subtitle: Text(
                      hasPhoto ? 'Sudah diambil' : 'Belum diambil',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(Icons.refresh, color: Color(0xFF00B894)),
                    onTap: () {
                      Navigator.pop(context);
                      _retakeSinglePhoto(index);
                    },
                  );
                }),
                Divider(),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  leading: CircleAvatar(
                    backgroundColor: Colors.red[100],
                    child: Icon(Icons.refresh, color: Colors.red),
                  ),
                  title: Text(
                    'Ulang Semua Foto',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _uploadedPhotos.clear();
                      _selectedFrame = 'camera';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Silakan ambil ulang semua foto'),
                        backgroundColor: Color(0xFF00B894),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }
}
