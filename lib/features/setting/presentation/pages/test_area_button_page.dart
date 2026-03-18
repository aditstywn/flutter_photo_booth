import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_photo_booth/core/extensions/build_context_ext.dart';
import 'package:flutter_photo_booth/features/setting/data/datasource/description_wa_local_datasource.dart';
import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/component/buttons.dart';
import '../../../../core/component/space.dart';
import '../../../../core/component/tab_selector.dart';
import '../../../../core/style/color/colors_app.dart';
import '../../data/datasource/countdown_settings_datasource.dart';
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

  // Variabel zoom
  double _minZoomLevel = 1.0;

  // Photo capture variables
  final Map<int, File> _uploadedPhotos = {}; // indeks -> file foto
  int _countdownValue = 0; // 0 = tidak countdown
  int _countdownPhotoIndex = 0; // foto ke-berapa yang sedang di-countdown
  int _countdownDuration = 3; // durasi countdown (default 3 detik)

  // Template image size (untuk BoxFit.contain offset correction)
  Size? _templateImageSize;

  // final ImagePicker _picker = ImagePicker();

  final GlobalKey _compositeKey = GlobalKey();

  bool _loading = false;

  int _currentTemplateIndex = 0;
  late PageController _pageController;

  String? _description = '';

  @override
  void initState() {
    _pageController = PageController();
    _loadCountdownSettings();
    _loadSavedFrames();
    _loadSavedButtonAreas();
    _loadTemplates();
    _initializeCamera();
    _loadDescription();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      // pilih kamera depan terbaik
      final bestCamera = _getBestFrontCamera(_cameras);

      _cameraController = CameraController(
        bestCamera,
        ResolutionPreset.max, // supaya foto photobooth tajam
        enableAudio: false,
      );

      await _cameraController!.initialize();

      _minZoomLevel = await _cameraController!.getMinZoomLevel();

      // gunakan zoom minimum supaya FOV paling luas
      await _cameraController!.setZoomLevel(_minZoomLevel);

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }

      // debug kamera
      for (int i = 0; i < _cameras.length; i++) {
        debugPrint(
          "Camera $i : ${_cameras[i].lensDirection} - ${_cameras[i].name}",
        );
      }
    } catch (e) {
      debugPrint('Error inisialisasi kamera: $e');
    }
  }

  CameraDescription _getBestFrontCamera(List<CameraDescription> cameras) {
    // ambil semua kamera depan
    final frontCameras = cameras
        .where((c) => c.lensDirection == CameraLensDirection.front)
        .toList();

    if (frontCameras.isEmpty) {
      return cameras.first;
    }

    // jika ada lebih dari satu kamera depan
    if (frontCameras.length > 1) {
      // biasanya ultra wide index lebih besar
      return frontCameras.last;
    }

    return frontCameras.first;
  }

  // Future<void> _initializeCamera() async {
  //   try {
  //     _cameras = await availableCameras();
  //     if (_cameras.isNotEmpty) {
  //       // Gunakan kamera depan (index 1) jika ada, jika tidak gunakan kamera belakang (index 0)
  //       final cameraIndex = _cameras.length > 1 ? 1 : 0;
  //       _cameraController = CameraController(
  //         _cameras[cameraIndex],
  //         ResolutionPreset.high,
  //         enableAudio: false,
  //       );
  //       await _cameraController!.initialize();
  //       if (mounted) {
  //         setState(() {
  //           _isCameraInitialized = true;
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Error initializing camera: $e');
  //   }
  // }

  Future<void> _loadCountdownSettings() async {
    try {
      final duration = await CountdownSettingsDatasource()
          .loadCountdownDuration();
      if (mounted) {
        setState(() {
          _countdownDuration = duration;
        });
      }
    } catch (e) {
      debugPrint('Error memuat countdown settings: $e');
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

  void _goToNextTemplate() {
    if (_currentTemplateIndex < _availableTemplates.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousTemplate() {
    if (_currentTemplateIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _selectTemplate() async {
    final currentTemplate = _availableTemplates[_currentTemplateIndex];
    setState(() {
      _selectedTemplate = currentTemplate;
      _templateImageSize = null;
    });

    // Wait for template image size to load before navigating
    await _loadTemplateImageSize(currentTemplate.framePath);

    // Navigate to camera page
    if (mounted) {
      setState(() {
        _selectedFrame = 'camera';
      });
    }
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

  Future<void> _loadDescription() async {
    try {
      final description = await DescriptionWaLocalDatasource()
          .loadDescription();
      if (mounted) {
        setState(() {
          _description = description;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showAlertError(message: 'Error loading settings: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Area Button')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ScrollableHorizontalTabSelector(
            fontSize: 12,
            borderRadius: 8,
            margin: EdgeInsets.zero,
            items: [
              TabItem(id: 'main', label: 'Landing ', icon: Icons.home_rounded),

              TabItem(
                id: 'template',
                label: 'Template ',
                icon: Icons.view_module_rounded,
              ),
              TabItem(
                id: 'camera',
                label: 'Preview ',
                icon: Icons.camera_alt_rounded,
              ),

              TabItem(id: 'result', label: 'Hasil ', icon: Icons.photo_rounded),
            ],
            selectedId: _selectedFrame,

            onSelected: (id) {
              setState(() {
                _selectedFrame = id;
              });
            },
          ),
          SpaceHeight(16),
          _buildEditSection(),
        ],
      ),
    );
  }

  Widget _buildEditSection() {
    // Tampilkan list template jika tab template dipilih
    if (_selectedFrame == 'template') {
      return listTemplate(context);
    }

    File? currentFrame;
    currentFrame = _selectedFrame == 'main'
        ? _mainFrame
        : _selectedFrame == 'camera'
        ? _cameraFrame
        : _resultFrame;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            if (currentFrame == null)
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: Center(
                  child: Text(
                    'No frame uploaded',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  return Image.file(
                    currentFrame!,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  );
                },
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
                        if (_loading)
                          Container(
                            color: Colors.transparent,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: ColorsApp.primary,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Loading...',
                                    style: TextStyle(
                                      color: ColorsApp.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
      ),
    );
  }

  // Widget untuk menampilkan list template
  Column listTemplate(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Template Display Area
        SizedBox(
          height: 500, // Fixed height untuk PageView
          child: PageView.builder(
            controller: _pageController,
            itemCount: _availableTemplates.length,
            onPageChanged: (index) {
              setState(() {
                _currentTemplateIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final template = _availableTemplates[index];
              return Container(
                margin: EdgeInsets.only(bottom: 16),
                child: _buildSingleTemplateView(template),
              );
            },
          ),
        ),
        SizedBox(height: 16),

        // Navigation Buttons (Previous & Next)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous Button
            ElevatedButton.icon(
              onPressed: _currentTemplateIndex > 0
                  ? _goToPreviousTemplate
                  : null,
              icon: Icon(Icons.arrow_back),
              label: Text('Sebelumnya'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentTemplateIndex > 0
                    ? Colors.grey[300]
                    : Colors.grey[200],
                foregroundColor: Colors.black87,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(width: 16),

            // Next Button
            ElevatedButton.icon(
              onPressed: _currentTemplateIndex < _availableTemplates.length - 1
                  ? _goToNextTemplate
                  : null,
              icon: Icon(Icons.arrow_forward),
              label: Text('Selanjutnya'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _currentTemplateIndex < _availableTemplates.length - 1
                    ? Colors.grey[300]
                    : Colors.grey[200],
                foregroundColor: Colors.black87,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 16),

        // Select Button
        Button.filled(
          height: 50,
          onPressed: _selectTemplate,
          label: 'Pilih Template Ini',
          color: ColorsApp.primary,
        ),

        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSingleTemplateView(FrameTemplate template) {
    final frameFile = File(template.framePath);
    final frameExists = frameFile.existsSync();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Preview Frame
          SizedBox(
            height: 380, // Fixed height untuk preview
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: frameExists
                    ? Image.file(frameFile, fit: BoxFit.contain)
                    : Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[400],
                          size: 80,
                        ),
                      ),
              ),
            ),
          ),
          // Info
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.photo_library,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${template.numberOfPhotoStrips} Photos',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          ? _buildResultPreviewWidget(area, constraints)
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

    // if (function == 'Share') {
    //   if (_uploadedPhotos.isEmpty) {
    //     context.showAlertError(message: 'Belum ada foto untuk dibagikan');
    //     return;
    //   }

    //   _saveCompositeImage();

    //   return;
    // }

    // Jika Retake, tampilkan dialog retake
    if (function == 'Retake') {
      _handleRetake();
      return;
    }

    // if (function == 'Print') {
    //   _createVideoFromPhotos();
    //   return;
    // }

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
      case 'Share':
        message = 'Share - Berbagi foto';
        backgroundColor = Color(0xFF00B894);
        icon = Icons.share;
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
      if (_countdownDuration > 0) {
        for (int countdown = _countdownDuration; countdown > 0; countdown--) {
          if (!mounted) return;
          setState(() {
            _countdownValue = countdown;
            _countdownPhotoIndex = i + 1;
          });
          await Future.delayed(Duration(seconds: 1));
        }
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

    // Hitung maksimum lebar dan tinggi dari area yang ditentukan
    final maxPixelWidth = (normalizedWidth * containerWidth).clamp(
      10.0,
      containerWidth,
    );
    final maxPixelHeight = (normalizedHeight * containerHeight).clamp(
      10.0,
      containerHeight,
    );

    // Hitung ukuran aktual dengan mempertimbangkan aspect ratio
    // dan memastikan tidak melebihi area yang ditentukan
    double actualWidth = maxPixelWidth;
    double actualHeight = maxPixelHeight;

    if (_templateImageSize != null) {
      final imageAspectRatio =
          _templateImageSize!.width / _templateImageSize!.height;
      final areaAspectRatio = maxPixelWidth / maxPixelHeight;

      // Sesuaikan ukuran agar muat dalam area yang ditentukan
      if (imageAspectRatio > areaAspectRatio) {
        // Image lebih lebar, sesuaikan berdasarkan lebar
        actualWidth = maxPixelWidth;
        actualHeight = maxPixelWidth / imageAspectRatio;
      } else {
        // Image lebih tinggi, sesuaikan berdasarkan tinggi
        actualHeight = maxPixelHeight;
        actualWidth = maxPixelHeight * imageAspectRatio;
      }
    }

    return Container(
      width: maxPixelWidth,
      height: maxPixelHeight,
      alignment: Alignment.center,
      child: Container(
        width: actualWidth,
        height: actualHeight,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(77),
              spreadRadius: 3,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: RepaintBoundary(
          key: _compositeKey,
          child: Stack(
            children: [
              Container(
                width: actualWidth,
                height: actualHeight,
                color: Colors.black.withAlpha(50),
              ),
              // Overlay area foto: diposisikan sesuai ukuran AKTUAL gambar
              if (_selectedTemplate != null && _templateImageSize != null)
                _buildTemplateAreaOverlay(
                  containerWidth: actualWidth,
                  containerHeight: actualHeight,
                  imageSize: _templateImageSize!,
                ),
              // Hanya tampilkan image jika ada template
              if (_selectedTemplate?.framePath != null)
                Image.file(
                  File(_selectedTemplate!.framePath),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildResultPreviewWidget(
  //   ButtonArea area,
  //   BoxConstraints constraints,
  // ) {
  //   // Convert normalized values (0-1) to pixels
  //   final containerWidth = constraints.maxWidth;
  //   final containerHeight = constraints.maxHeight;

  //   final normalizedWidth = area.width > 1.0
  //       ? area.width / containerWidth
  //       : area.width;
  //   final normalizedHeight = area.height > 1.0
  //       ? area.height / containerHeight
  //       : area.height;

  //   final pixelWidth = (normalizedWidth * containerWidth).clamp(
  //     10.0,
  //     containerWidth,
  //   );

  //   // Hitung tinggi aktual berdasarkan aspect ratio gambar (BoxFit.fitWidth)
  //   // sehingga tidak ada ruang kosong di bawah.
  //   final double actualHeight = _templateImageSize != null
  //       ? pixelWidth * (_templateImageSize!.height / _templateImageSize!.width)
  //       : (normalizedHeight * containerHeight).clamp(10.0, containerHeight);

  //   return RepaintBoundary(
  //     key: _compositeKey,
  //     child: SizedBox(
  //       width: pixelWidth,
  //       height: actualHeight,
  //       child: Stack(
  //         children: [
  //           Container(
  //             width: pixelWidth,
  //             height: actualHeight,
  //             color: Colors.black.withAlpha(50),
  //           ),
  //           // Overlay area foto: diposisikan sesuai ukuran AKTUAL gambar
  //           if (_selectedTemplate != null && _templateImageSize != null)
  //             _buildTemplateAreaOverlay(
  //               containerWidth: pixelWidth,
  //               containerHeight: actualHeight,
  //               imageSize: _templateImageSize!,
  //             ),
  //           // Hanya tampilkan image jika ada template
  //           if (_selectedTemplate?.framePath != null)
  //             Image.file(
  //               File(_selectedTemplate!.framePath),
  //               width: double.infinity,
  //               fit: BoxFit.fitWidth,
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
        child: Transform(
          transform: Matrix4.rotationY(math.pi), // Mirror horizontal
          alignment: Alignment.center,
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
        ),
      );
    }

    return Positioned(
      left: pixelX,
      top: pixelY,
      child: GestureDetector(
        onTap: () {
          // _handlePhotoAreaTap(index);
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
  // Future<void> _handlePhotoAreaTap(int photoIndex) async {
  //   // Show bottom sheet untuk pilih sumber foto
  //   final result = await showModalBottomSheet<String>(
  //     context: context,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) => Container(
  //       padding: EdgeInsets.all(20),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text(
  //             'Pilih Sumber Foto ${photoIndex + 1}',
  //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //           ),
  //           SizedBox(height: 20),
  //           ListTile(
  //             leading: Icon(Icons.camera_alt, color: Color(0xFF00B8D4)),
  //             title: Text('Ambil dari Kamera'),
  //             onTap: () => Navigator.pop(context, 'camera'),
  //           ),
  //           ListTile(
  //             leading: Icon(Icons.photo_library, color: Color(0xFF00B8D4)),
  //             title: Text('Pilih dari Galeri'),
  //             onTap: () => Navigator.pop(context, 'gallery'),
  //           ),
  //           if (_uploadedPhotos.containsKey(photoIndex))
  //             ListTile(
  //               leading: Icon(Icons.delete, color: Colors.red),
  //               title: Text('Hapus Foto'),
  //               onTap: () => Navigator.pop(context, 'delete'),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );

  //   if (result == 'camera') {
  //     await _pickImageFromCamera(photoIndex);
  //   } else if (result == 'gallery') {
  //     await _pickImageFromGallery(photoIndex);
  //   } else if (result == 'delete') {
  //     setState(() {
  //       _uploadedPhotos.remove(photoIndex);
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Photo ${photoIndex + 1} dihapus'),
  //         behavior: SnackBarBehavior.floating,
  //         duration: Duration(seconds: 1),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  // Fungsi untuk ambil foto dari kamera
  // Future<void> _pickImageFromCamera(int photoIndex) async {
  //   try {
  //     final XFile? image = await _picker.pickImage(
  //       source: ImageSource.camera,
  //       preferredCameraDevice: CameraDevice.front,
  //     );

  //     if (image != null) {
  //       setState(() {
  //         _uploadedPhotos[photoIndex] = File(image.path);
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Photo ${photoIndex + 1} berhasil diambil'),
  //           behavior: SnackBarBehavior.floating,
  //           duration: Duration(seconds: 1),
  //           backgroundColor: Color(0xFF00B8D4),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error: $e'),
  //         behavior: SnackBarBehavior.floating,
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  // // Fungsi untuk pilih foto dari galeri
  // Future<void> _pickImageFromGallery(int photoIndex) async {
  //   try {
  //     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

  //     if (image != null) {
  //       setState(() {
  //         _uploadedPhotos[photoIndex] = File(image.path);
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Photo ${photoIndex + 1} berhasil dipilih'),
  //           behavior: SnackBarBehavior.floating,
  //           duration: Duration(seconds: 1),
  //           backgroundColor: Color(0xFF00B8D4),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error: $e'),
  //         behavior: SnackBarBehavior.floating,
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

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
      final imagePath = '${directory.path}/photoboot_$timestamp.png';

      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      // Simpan ke galeri/hasil terbaru
      final prefs = await SharedPreferences.getInstance();
      List<String> recentResults = prefs.getStringList('recent_results') ?? [];
      recentResults.insert(0, imagePath);

      // Simpan setiap foto individual yang dipakai ke galeri (dengan mirror horizontal)
      for (int i = 0; i < (_selectedTemplate?.numberOfPhotoStrips ?? 1); i++) {
        if (_uploadedPhotos.containsKey(i)) {
          // Baca foto asli
          final originalBytes = await _uploadedPhotos[i]!.readAsBytes();
          img.Image? originalImage = img.decodeImage(originalBytes);

          if (originalImage != null) {
            // Flip horizontal agar sesuai dengan tampilan di layar
            final flippedImage = img.flipHorizontal(originalImage);

            // Simpan ke file temporary
            final tempDir = await getApplicationDocumentsDirectory();
            final flippedPath =
                '${tempDir.path}/flipped_photo_${i}_$timestamp.jpg';
            final flippedFile = File(flippedPath);
            await flippedFile.writeAsBytes(img.encodeJpg(flippedImage));

            // Simpan ke galeri
            await Gal.putImage(flippedFile.path, album: 'Boothera');

            // Hapus file temporary
            await flippedFile.delete();
          }
        }
      }

      // Simpan hasil komposit ke galeri
      await Gal.putImage(imageFile.path, album: 'Boothera');

      String? videoPath = await _createVideoFromPhotos();

      // Simpan hanya 50 hasil terakhir
      // if (recentResults.length > 50) {
      //   recentResults = recentResults.take(50).toList();
      // }

      // await prefs.setStringList('recent_results', recentResults);

      if (videoPath != null && imageFile.existsSync()) {
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
                        Text(
                          'Tersimpan!',
                          style: TextStyle(color: Colors.white),
                        ),
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
                                Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 14,
                                ),
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
                          ...[
                            SpaceHeight(12),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 14,
                                  ),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Video gif berhasil disimpan',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

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
                                borderSide: BorderSide(
                                  color: Color(0xFF25D366),
                                ),
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
                                    'whatsapp://send?phone=$rawNumber&text=$_description',
                                  );
                                  if (await canLaunchUrl(waUrl)) {
                                    await launchUrl(
                                      waUrl,
                                      mode: LaunchMode.externalApplication,
                                    );
                                    // Reminder untuk attach foto
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
      }
    } catch (e) {
      if (mounted) {
        context.showAlertError(message: 'Gagal menyimpan gambar: $e');
      }
    }
  }

  // Future<String?> createGif() async {
  //   try {
  //     if (_uploadedPhotos.isEmpty) return null;

  //     setState(() {
  //       _loading = true;
  //     });

  //     final encoder = img.GifEncoder();

  //     /// decode semua foto sekali saja
  //     List<img.Image> frames = [];

  //     for (var photo in _uploadedPhotos.values) {
  //       final bytes = await photo.readAsBytes();
  //       final decoded = img.decodeImage(bytes);

  //       if (decoded != null) {
  //         /// resize supaya proses cepat
  //         final resized = img.copyResize(decoded, width: 1080);
  //         frames.add(resized);
  //       }
  //     }

  //     /// loop 5x tanpa decode ulang
  //     for (int i = 0; i < 3; i++) {
  //       for (var frame in frames) {
  //         encoder.addFrame(frame, duration: 60);
  //       }
  //     }

  //     final gifBytes = encoder.finish();

  //     final dir = await getApplicationDocumentsDirectory();
  //     final path =
  //         '${dir.path}/photobooth_${DateTime.now().millisecondsSinceEpoch}.gif';

  //     final file = File(path);
  //     await file.writeAsBytes(gifBytes!);

  //     /// simpan ke galeri
  //     await Gal.putImage(path, album: 'Boothera GIF');

  //     if (mounted) {
  //       context.showAlertSuccess(message: 'GIF berhasil dibuat');
  //     }

  //     setState(() {
  //       _loading = false;
  //     });

  //     return path;
  //   } catch (e) {
  //     setState(() {
  //       _loading = false;
  //     });
  //     if (mounted) {
  //       context.showAlertError(message: 'Gagal membuat GIF: $e');
  //     }

  //     debugPrint('Gagal membuat GIF: $e');
  //     return null;
  //   }
  // }

  Future<String?> _createVideoFromPhotos() async {
    try {
      if (_uploadedPhotos.isEmpty) {
        debugPrint('Tidak ada foto untuk membuat video');
        return null;
      }

      setState(() {
        _loading = true;
      });

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final outputPath = '${directory.path}/photobooth_video_$timestamp.mp4';

      final sortedKeys = _uploadedPhotos.keys.toList()..sort();

      // Ambil ukuran dari foto pertama untuk menentukan orientasi video
      final firstPhotoBytes = await _uploadedPhotos[sortedKeys.first]!
          .readAsBytes();
      final firstImage = img.decodeImage(firstPhotoBytes);

      if (firstImage == null) {
        debugPrint('Gagal decode foto pertama');
        setState(() {
          _loading = false;
        });
        return null;
      }

      // Target resolusi lebih kecil agar encoding lebih cepat,
      // sambil tetap mempertahankan rasio asli agar tidak gepeng.
      const int maxLongEdge = 1280;
      final bool isPortrait = firstImage.height >= firstImage.width;
      final double sourceAspect = firstImage.width / firstImage.height;

      int width;
      int height;
      if (isPortrait) {
        height = maxLongEdge;
        width = (height * sourceAspect).round();
      } else {
        width = maxLongEdge;
        height = (width / sourceAspect).round();
      }

      // Banyak encoder butuh dimensi genap.
      width = width.isOdd ? width - 1 : width;
      height = height.isOdd ? height - 1 : height;

      const int fps = 24;
      const int loopCount = 3;
      const int videoBitrate = 1400000;

      const double slideDuration = 0.45; // detik
      final int framesPerSlide = (fps * slideDuration).toInt();

      img.Image fitToCanvas(
        img.Image source,
        int canvasWidth,
        int canvasHeight,
      ) {
        final canvasAspect = canvasWidth / canvasHeight;
        final sourceAspect = source.width / source.height;

        int targetWidth;
        int targetHeight;
        if (sourceAspect > canvasAspect) {
          targetWidth = canvasWidth;
          targetHeight = (canvasWidth / sourceAspect).round();
        } else {
          targetHeight = canvasHeight;
          targetWidth = (canvasHeight * sourceAspect).round();
        }

        final resized = img.copyResize(
          source,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.linear,
        );

        final canvas = img.Image(width: canvasWidth, height: canvasHeight);
        img.fill(canvas, color: img.ColorRgb8(0, 0, 0));

        final offsetX = ((canvasWidth - targetWidth) / 2).round();
        final offsetY = ((canvasHeight - targetHeight) / 2).round();
        img.compositeImage(canvas, resized, dstX: offsetX, dstY: offsetY);
        return canvas;
      }

      /// setup encoder dengan ukuran asli foto
      await FlutterQuickVideoEncoder.setup(
        width: width,
        height: height,
        fps: fps,
        videoBitrate: videoBitrate,
        audioChannels: 0,
        audioBitrate: 64000,
        sampleRate: 44100,
        filepath: outputPath,
        profileLevel: ProfileLevel.mainAutoLevel,
      );

      /// LOOP VIDEO beberapa kali agar durasi cukup tanpa file terlalu besar
      for (int loop = 0; loop < loopCount; loop++) {
        for (int key in sortedKeys) {
          final photoFile = _uploadedPhotos[key]!;

          /// baca file image
          final bytes = await photoFile.readAsBytes();

          img.Image? image = img.decodeImage(bytes);

          if (image == null) continue;

          /// flip horizontal agar sesuai dengan tampilan di layar (mirror)
          image = img.flipHorizontal(image);

          /// fit ke canvas tanpa mengubah rasio agar tidak gepeng
          image = fitToCanvas(image, width, height);

          /// convert ke RGBA
          Uint8List rgba = image.getBytes(order: img.ChannelOrder.rgba);

          /// tampilkan foto selama 0.5 detik
          for (int i = 0; i < framesPerSlide; i++) {
            await FlutterQuickVideoEncoder.appendVideoFrame(rgba);
          }
        }
      }

      /// selesai encode
      await FlutterQuickVideoEncoder.finish();

      if (mounted) {
        context.showAlertSuccess(message: 'Video berhasil dibuat');
      }

      await Gal.putVideo(outputPath, album: 'Boothera');

      debugPrint("Video berhasil dibuat: $outputPath");

      setState(() {
        _loading = false;
      });

      if (mounted) {
        context.showAlertSuccess(message: 'Video berhasil disimpan ke galeri');
      }

      return outputPath;
    } catch (e) {
      setState(() {
        _loading = false;
      });
      debugPrint('Error in _createVideoFromPhotos: $e');

      if (mounted) {
        context.showAlertError(message: 'Gagal membuat video dari foto');
      }

      return null;
    }
  }

  // Future<String?> _createVideoFromPhotos() async {
  //   try {
  //     if (_uploadedPhotos.isEmpty) {
  //       debugPrint('Tidak ada foto untuk membuat video');
  //       return null;
  //     }

  //     final directory = await getApplicationDocumentsDirectory();
  //     final timestamp = DateTime.now().millisecondsSinceEpoch;

  //     final tempVideo = '${directory.path}/temp_video_$timestamp.mp4';
  //     final finalVideo = '${directory.path}/photobooth_video_$timestamp.mp4';

  //     final listFilePath = '${directory.path}/photo_list_$timestamp.txt';
  //     final listFile = File(listFilePath);

  //     final sortedKeys = _uploadedPhotos.keys.toList()..sort();

  //     String fileListContent = '';

  //     for (int key in sortedKeys) {
  //       final photoFile = _uploadedPhotos[key]!;
  //       final safePath = photoFile.path.replaceAll("'", "\\'");

  //       fileListContent += "file '$safePath'\n";
  //       fileListContent += "duration 1\n";
  //     }

  //     if (sortedKeys.isNotEmpty) {
  //       final lastPhoto = _uploadedPhotos[sortedKeys.last]!;
  //       final safePath = lastPhoto.path.replaceAll("'", "\\'");
  //       fileListContent += "file '$safePath'\n";
  //     }

  //     await listFile.writeAsString(fileListContent);

  //     /// STEP 1: buat slideshow
  //     final command1 =
  //         '-f concat -safe 0 -i "$listFilePath" '
  //         '-c:v libx264 '
  //         '-r 30 '
  //         '-pix_fmt yuv420p '
  //         '-vf "scale=1080:1920:force_original_aspect_ratio=decrease,'
  //         'pad=1080:1920:(ow-iw)/2:(oh-ih)/2,format=yuv420p" '
  //         '-y "$tempVideo"';

  //     final session1 = await FFmpegKit.execute(command1);

  //     final returnCode1 = await session1.getReturnCode();

  //     if (!ReturnCode.isSuccess(returnCode1)) {
  //       debugPrint("Gagal membuat slideshow");
  //       if (mounted) {
  //         context.showAlertError(message: 'Gagal membuat video dari foto');
  //       }
  //       return null;
  //     }

  //     /// STEP 2: buat file list untuk repeat video
  //     final repeatListPath = '${directory.path}/repeat_list_$timestamp.txt';
  //     final repeatListFile = File(repeatListPath);

  //     String repeatContent = '';

  //     for (int i = 0; i < 3; i++) {
  //       repeatContent += "file '$tempVideo'\n";
  //     }

  //     await repeatListFile.writeAsString(repeatContent);

  //     /// STEP 3: concat video 3 kali
  //     final command2 =
  //         '-f concat -safe 0 -i "$repeatListPath" '
  //         '-c copy '
  //         '-y "$finalVideo"';

  //     final session2 = await FFmpegKit.execute(command2);

  //     final returnCode2 = await session2.getReturnCode();

  //     if (ReturnCode.isSuccess(returnCode2)) {
  //       if (mounted) {
  //         context.showAlertSuccess(message: 'Video berhasil dibuat');
  //       }
  //       debugPrint("Video berhasil dibuat: $finalVideo");

  //       await Gal.putVideo(finalVideo, album: 'Boothera Video');

  //       await listFile.delete();
  //       await repeatListFile.delete();
  //       await File(tempVideo).delete();

  //       return finalVideo;
  //     } else {
  //       debugPrint("Gagal repeat video");
  //       return null;
  //     }
  //   } catch (e) {
  //     debugPrint('Error in _createVideoFromPhotos: $e');
  //     return null;
  //   }
  // }

  Future<void> _retakeSinglePhoto(int photoIndex) async {
    if (_cameraController == null || !_isCameraInitialized) {
      context.showAlertError(message: 'Kamera tidak tersedia');
      return;
    }

    // Hapus foto lama dan pindah ke tab camera
    setState(() {
      _uploadedPhotos.remove(photoIndex);
      _selectedFrame = 'camera';
    });

    // Hitung mundur (skip jika 0)
    if (_countdownDuration > 0) {
      for (int countdown = _countdownDuration; countdown > 0; countdown--) {
        if (!mounted) return;
        setState(() {
          _countdownValue = countdown;
          _countdownPhotoIndex = photoIndex + 1;
        });
        await Future.delayed(Duration(seconds: 1));
      }
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00B894),
                ),
                child: Text('Ambil Ulang'),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: ColorsApp.white,
          title: Text(
            'Pilih Foto untuk Diulang',
            style: TextStyle(
              color: ColorsApp.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih foto mana yang ingin diambil ulang, atau ulang semua.',
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorsApp.textSecondary,
                  ),
                ),
                SizedBox(height: 12),
                ...List.generate(totalPhotos, (index) {
                  final hasPhoto = _uploadedPhotos.containsKey(index);
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                    leading: CircleAvatar(
                      backgroundColor: hasPhoto
                          ? ColorsApp.primary
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
                    trailing: Icon(Icons.refresh, color: ColorsApp.primary),
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
