import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../../core/extensions/build_context_ext.dart';
import 'result_page.dart';

import '../../../setting/data/datasource/custom_button_local_datasource.dart';
import '../../../setting/data/datasource/custom_frame_local_datasource.dart';
import '../../../setting/data/models/request/button_area.dart';
import '../../../setting/data/models/request/frame_template.dart';
import '../widgets/build_tappable_area.dart';

class CameraPage extends StatefulWidget {
  final FrameTemplate? selectedTemplate;
  final Size? templateImageSize;

  /// Jika tidak null, mode retake: hanya ambil 1 foto untuk indeks ini,
  /// lalu pop dengan [File] hasilnya.
  final int? retakePhotoIndex;
  const CameraPage({
    super.key,
    this.selectedTemplate,
    this.templateImageSize,
    this.retakePhotoIndex,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _cameraFrame;
  ButtonArea? _cameraPreviewArea;
  List<ButtonArea> _cameraButtonAreas = [];

  // Variabel kamera
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  int _selectedCameraIndex = 1; // 1 = kamera depan (selfie)

  // Variabel zoom
  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;

  // Variabel pengambilan foto
  Map<int, File> _uploadedPhotos = {}; // indeks -> file foto
  int _countdownValue = 0; // 0 = tidak countdown
  int _countdownPhotoIndex = 0; // foto ke-berapa yang sedang di-countdown

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _loadSavedFrames();
    _loadSavedButtonAreas();
    _initializeCamera();
  }

  @override
  void dispose() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _cameraController?.dispose();
    super.dispose();
  }

  void _loadSavedFrames() {
    CustomFrameLocalDatasource().loadSavedFrames(
      onLoaded: (main, camera, result) {
        setState(() {
          _cameraFrame = camera;
        });
      },
    );
  }

  void _loadSavedButtonAreas() {
    CustomButtonLocalDatasource().loadConfiguration(
      onLoadedCameraPreview: (areas) {
        setState(() {
          _cameraPreviewArea = areas;
        });
      },
      onLoadedCameraButtons: (cameraButtonAreas) {
        setState(() {
          _cameraButtonAreas = cameraButtonAreas;
        });
      },

      onError: (e) {
        debugPrint('Error memuat area tombol: $e');
      },
    );
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _selectedCameraIndex = _cameras.length > 1 ? 1 : 0;
        _cameraController = CameraController(
          _cameras[_selectedCameraIndex],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();

        // Ambil level zoom kamera
        _minZoomLevel = await _cameraController!.getMinZoomLevel();
        _maxZoomLevel = await _cameraController!.getMaxZoomLevel();

        // Pastikan max zoom selalu lebih besar dari min (fallback untuk kamera tanpa zoom)
        if (_maxZoomLevel <= _minZoomLevel) {
          _maxZoomLevel =
              _minZoomLevel + 9.0; // Set max ke 10x jika tidak support zoom
        }

        _currentZoomLevel = _minZoomLevel;

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error inisialisasi kamera: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    setState(() {
      _isCameraInitialized = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    });
    await _cameraController?.dispose();
    _cameraController = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await _cameraController!.initialize();

      // Ambil level zoom untuk kamera baru
      _minZoomLevel = await _cameraController!.getMinZoomLevel();
      _maxZoomLevel = await _cameraController!.getMaxZoomLevel();

      // Pastikan max zoom selalu lebih besar dari min (fallback untuk kamera tanpa zoom)
      if (_maxZoomLevel <= _minZoomLevel) {
        _maxZoomLevel =
            _minZoomLevel + 9.0; // Set max ke 10x jika tidak support zoom
      }

      _currentZoomLevel = _minZoomLevel;

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error ganti kamera: $e');
    }
  }

  Future<void> _onZoomChanged(double value) async {
    if (_cameraController == null || !_isCameraInitialized) return;

    // Petakan nilai slider (1-100) ke rentang zoom sebenarnya
    final double zoomLevel =
        _minZoomLevel + (value - 1) * (_maxZoomLevel - _minZoomLevel) / 99;

    try {
      await _cameraController!.setZoomLevel(zoomLevel);
      setState(() {
        _currentZoomLevel = zoomLevel;
      });
    } catch (e) {
      debugPrint('Error mengatur zoom: $e');
    }
  }

  double get _sliderValue {
    // Petakan level zoom saat ini ke nilai slider (1-100)
    if (_maxZoomLevel == _minZoomLevel) return 1;
    return 1 +
        ((_currentZoomLevel - _minZoomLevel) /
                (_maxZoomLevel - _minZoomLevel)) *
            99;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
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
                        //  area tappable
                        if (_cameraPreviewArea != null)
                          buildTappableArea(
                            area: _cameraPreviewArea!,
                            constraints: stackConstraints,
                            isCameraPreview: true,
                            child: buildCameraPreview(
                              area: _cameraPreviewArea!,
                              constraints: stackConstraints,
                              cameraController: _cameraController,
                              isCameraInitialized: _isCameraInitialized,
                              selectedTemplate: widget.selectedTemplate,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              if (_cameraFrame == null)
                Container(
                  color: Colors.grey[300],
                  width: double.infinity,
                  height: double.infinity,
                  child: const Center(
                    child: Text(
                      'Frame Kamera Tidak Ada',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ),
                )
              else if (_cameraFrame != null)
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Image.file(
                      _cameraFrame!,
                      fit: BoxFit.fill,
                      width: double.infinity,
                      height: double.infinity,
                    );
                  },
                ),
              if (_cameras.length > 1)
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _switchCamera,
                    backgroundColor: Colors.black54,
                    child: const Icon(
                      Icons.flip_camera_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
              // Slider Zoom - vertikal dan pendek, di bawah toggle kamera
              if (_isCameraInitialized)
                Positioned(
                  top: 80,
                  right: 16,
                  child: Container(
                    height: 180,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_in, color: Colors.white, size: 18),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_sliderValue.round()}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 3,
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayShape: RoundSliderOverlayShape(
                                  overlayRadius: 12,
                                ),
                              ),
                              child: Slider(
                                value: _sliderValue,
                                min: 1,
                                max: 100,
                                divisions: 99,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white30,
                                onChanged: _onZoomChanged,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Icon(Icons.zoom_out, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
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
                        ..._cameraButtonAreas.map((area) {
                          return buildTappableArea(
                            area: area,
                            constraints: stackConstraints,
                            onTap: () {
                              _startPhotoCapture();
                            },
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCameraPreview({
    required ButtonArea area,
    required BoxConstraints constraints,
    CameraController? cameraController,
    bool isCameraInitialized = false,
    FrameTemplate? selectedTemplate,
  }) {
    // Konversi nilai normalized (0-1) ke piksel
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

    if (!isCameraInitialized || cameraController == null) {
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
                fit: BoxFit.fill,
                child: SizedBox(
                  width: cameraController.value.previewSize!.height,
                  height: cameraController.value.previewSize!.width,
                  child: CameraPreview(cameraController),
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
                      'Foto $_countdownPhotoIndex / ${selectedTemplate?.numberOfPhotoStrips ?? 1}',
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

  Future<void> _startPhotoCapture() async {
    if (_cameraController == null || !_isCameraInitialized) {
      context.showAlertError(
        message: 'Kamera belum siap. Silakan tunggu sebentar.',
      );
      return;
    }

    final int totalPhotos = widget.selectedTemplate?.numberOfPhotoStrips ?? 1;

    // Mode retake: hanya ambil 1 foto lalu pop dengan File hasilnya
    if (widget.retakePhotoIndex != null) {
      await _retakeSinglePhoto(widget.retakePhotoIndex!);
      return;
    }

    setState(() {
      _uploadedPhotos.clear();
    });

    for (int i = 0; i < totalPhotos; i++) {
      // Countdown 3, 2, 1 tampil di atas kamera preview
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
      if (mounted) setState(() => _isCameraInitialized = false);
      await _cameraController?.dispose();
      _cameraController = null;
      if (!mounted) return;
      context.push(
        ResultPage(
          selectedTemplate: widget.selectedTemplate,
          templateImageSize: widget.templateImageSize,
          uploadedPhotos: _uploadedPhotos,
        ),
      );
    }
  }

  Future<void> _retakeSinglePhoto(int photoIndex) async {
    // Hitung mundur 3, 2, 1
    for (int countdown = 3; countdown > 0; countdown--) {
      if (!mounted) return;
      setState(() {
        _countdownValue = countdown;
        _countdownPhotoIndex = photoIndex + 1;
      });
      await Future.delayed(Duration(seconds: 1));
    }

    if (!mounted) return;
    setState(() => _countdownValue = 0);

    try {
      final XFile photo = await _cameraController!.takePicture();
      if (mounted) setState(() => _isCameraInitialized = false);
      await _cameraController?.dispose();
      _cameraController = null;
      if (!mounted) return;
      Navigator.pop(context, File(photo.path));
    } catch (e) {
      if (!mounted) return;
      setState(() => _countdownValue = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error mengambil foto: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
