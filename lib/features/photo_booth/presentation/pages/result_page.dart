import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image/image.dart' as img;

import '../../../../core/component/space.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/style/color/colors_app.dart';
import '../../../setting/data/datasource/printer_datasource.dart';
import '../../../history/data/datasource/print_history_datasource.dart';
import 'camera_page.dart';
import 'main_page.dart';
import '../../../setting/data/datasource/custom_button_local_datasource.dart';
import '../../../setting/data/datasource/custom_frame_local_datasource.dart';
import '../../../setting/data/models/request/button_area.dart';
import '../../../setting/data/models/request/frame_template.dart';
import '../widgets/build_tappable_area.dart';

class ResultPage extends StatefulWidget {
  final FrameTemplate? selectedTemplate;
  final Size? templateImageSize;
  final Map<int, File>? uploadedPhotos;
  const ResultPage({
    super.key,
    this.selectedTemplate,
    this.templateImageSize,
    this.uploadedPhotos,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final PrinterDatasource _printerDatasource = PrinterDatasource();
  final PrintHistoryDatasource _printHistoryDatasource =
      PrintHistoryDatasource();

  File? _resultFrame;
  ButtonArea? _resultPreviewArea;
  List<ButtonArea> _buttonAreasResult = [];

  // Salinan lokal yang bisa diupdate saat retake
  late Map<int, File> _photos;

  final GlobalKey _compositeKey = GlobalKey();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _photos = Map<int, File>.from(widget.uploadedPhotos ?? {});
    _loadSavedFrames();
    _loadSavedButtonAreas();
    print('uploadedPhotos in ResultPage: ${widget.uploadedPhotos}');
  }

  @override
  void dispose() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _loadSavedFrames() {
    CustomFrameLocalDatasource().loadSavedFrames(
      onLoaded: (main, camera, result) {
        setState(() {
          _resultFrame = result;
        });
      },
    );
  }

  void _loadSavedButtonAreas() {
    CustomButtonLocalDatasource().loadConfiguration(
      onLoadedResultPreview: (resultPreviewArea) {
        setState(() {
          _resultPreviewArea = resultPreviewArea;
        });
      },
      onLoadedResult: (buttonAreasResult) {
        setState(() {
          _buttonAreasResult = buttonAreasResult;
        });
      },

      onError: (e) {
        debugPrint('Error loading button areas: $e');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.pushAndRemoveUntil(MainPage(), (route) => route.isFirst);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_resultFrame == null)
                  Container(
                    color: Colors.grey[300],
                    width: double.infinity,
                    height: double.infinity,
                    child: const Center(
                      child: Text(
                        'No Main Frame Set',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    ),
                  )
                else if (_resultFrame != null)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Image.file(
                        _resultFrame!,
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: double.infinity,
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
                          //  area tappable
                          if (_resultPreviewArea != null)
                            buildTappableArea(
                              area: _resultPreviewArea!,
                              constraints: stackConstraints,
                              isResultPreview: true,
                              child: _buildResultPreviewWidget(
                                _resultPreviewArea!,
                                stackConstraints,
                              ),
                            ),
                          if (_loading)
                            Container(
                              color: Colors.transparent,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Loading...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // area button di result frame
                          ..._buttonAreasResult.map((area) {
                            return buildTappableArea(
                              area: area,
                              constraints: stackConstraints,
                              onTap: () {
                                debugPrint(
                                  'area print tapped ${area.function}',
                                );
                                if (area.function == 'Print') {
                                  _saveAndPrintImage();
                                } else if (area.function == 'Retake') {
                                  _handleRetake();
                                } else if (area.function == 'Share') {
                                  _saveCompositeImage();
                                }
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

    if (widget.templateImageSize != null) {
      final imageAspectRatio =
          widget.templateImageSize!.width / widget.templateImageSize!.height;
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
              if (widget.selectedTemplate != null &&
                  widget.templateImageSize != null)
                _buildTemplateAreaOverlay(
                  containerWidth: actualWidth,
                  containerHeight: actualHeight,
                  imageSize: widget.templateImageSize!,
                ),
              // Hanya tampilkan image jika ada template
              if (widget.selectedTemplate?.framePath != null)
                Image.file(
                  File(widget.selectedTemplate!.framePath),
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
  //   final double actualHeight = widget.templateImageSize != null
  //       ? pixelWidth *
  //             (widget.templateImageSize!.height /
  //                 widget.templateImageSize!.width)
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
  //           if (widget.selectedTemplate != null &&
  //               widget.templateImageSize != null)
  //             _buildTemplateAreaOverlay(
  //               containerWidth: pixelWidth,
  //               containerHeight: actualHeight,
  //               imageSize: widget.templateImageSize!,
  //             ),
  //           // Hanya tampilkan image jika ada template
  //           if (widget.selectedTemplate?.framePath != null)
  //             Image.file(
  //               File(widget.selectedTemplate!.framePath),
  //               width: double.infinity,
  //               fit: BoxFit.fitWidth,
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
            ...widget.selectedTemplate?.photoAreas.asMap().entries.map((entry) {
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
    if (_photos.containsKey(index)) {
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
                image: FileImage(_photos[index]!),
                fit: BoxFit.fill,
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

  Future<void> _saveAndPrintImage() async {
    setState(() {
      _loading = true;
    });
    if (_photos.length != widget.selectedTemplate?.numberOfPhotoStrips) {
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

      try {
        await _printerDatasource.printImage(pngBytes);

        // Record print in history
        await _printHistoryDatasource.recordPrint();

        setState(() {
          _loading = false;
        });

        if (mounted) {
          context.showAlertSuccess(
            message: 'Test print berhasil! Periksa hasil cetakan pada printer.',
          );
        }
      } catch (e) {
        if (mounted) {
          context.showAlertError(message: 'Test print gagal: $e');
          debugPrint('Test print error: $e');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showAlertError(message: 'Gagal menyimpan gambar: $e');
      }
    }
  }

  Future<void> _saveCompositeImage() async {
    if (_photos.length != widget.selectedTemplate?.numberOfPhotoStrips) {
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

      // Simpan setiap foto individual yang dipakai ke galeri
      for (
        int i = 0;
        i < (widget.selectedTemplate?.numberOfPhotoStrips ?? 1);
        i++
      ) {
        if (_photos.containsKey(i)) {
          await Gal.putImage(_photos[i]!.path, album: 'Boothera');
        }
      }

      // Simpan hasil komposit ke galeri
      await Gal.putImage(imageFile.path, album: 'Boothera');

      String? videoPath = await _createVideoFromPhotos();

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
                                    'whatsapp://send?phone=$rawNumber&text=Foto+dari+Photo+Booth',
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

  Future<void> _handleRetake() async {
    final int totalPhotos = widget.selectedTemplate?.numberOfPhotoStrips ?? 1;

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
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                SizedBox(height: 12),
                ...List.generate(totalPhotos, (index) {
                  final hasPhoto = _photos.containsKey(index);
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
                      _photos.clear();
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

  Future<void> _retakeSinglePhoto(int photoIndex) async {
    final File? newPhoto = await context.push<File>(
      CameraPage(
        selectedTemplate: widget.selectedTemplate,
        templateImageSize: widget.templateImageSize,
        retakePhotoIndex: photoIndex,
      ),
    );
    if (newPhoto != null && mounted) {
      setState(() {
        _photos[photoIndex] = newPhoto;
      });
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
  }

  Future<String?> _createVideoFromPhotos() async {
    try {
      if (_photos.isEmpty) {
        debugPrint('Tidak ada foto untuk membuat video');
        return null;
      }

      setState(() {
        _loading = true;
      });

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final outputPath = '${directory.path}/photobooth_video_$timestamp.mp4';

      const int width = 1080;
      const int height = 1920;
      const int fps = 30;

      const double slideDuration = 0.5; // detik
      final int framesPerSlide = (fps * slideDuration).toInt();

      final sortedKeys = _photos.keys.toList()..sort();

      /// setup encoder
      await FlutterQuickVideoEncoder.setup(
        width: width,
        height: height,
        fps: fps,
        videoBitrate: 2500000,
        audioChannels: 0,
        audioBitrate: 64000,
        sampleRate: 44100,
        filepath: outputPath,
        profileLevel: ProfileLevel.mainAutoLevel,
      );

      /// LOOP VIDEO 5x
      for (int loop = 0; loop < 5; loop++) {
        for (int key in sortedKeys) {
          final photoFile = _photos[key]!;

          /// baca file image
          final bytes = await photoFile.readAsBytes();

          img.Image? image = img.decodeImage(bytes);

          if (image == null) continue;

          /// resize ke 1080x1920
          image = img.copyResize(image, width: width, height: height);

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

      await Gal.putVideo(outputPath, album: 'Boothera Video');

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
  //     if (_photos.isEmpty) {
  //       debugPrint('Tidak ada foto untuk membuat video');
  //       return null;
  //     }

  //     final directory = await getApplicationDocumentsDirectory();
  //     final timestamp = DateTime.now().millisecondsSinceEpoch;

  //     final tempVideo = '${directory.path}/temp_video_$timestamp.mp4';
  //     final finalVideo = '${directory.path}/photobooth_video_$timestamp.mp4';

  //     final listFilePath = '${directory.path}/photo_list_$timestamp.txt';
  //     final listFile = File(listFilePath);

  //     final sortedKeys = _photos.keys.toList()..sort();

  //     String fileListContent = '';

  //     for (int key in sortedKeys) {
  //       final photoFile = _photos[key]!;
  //       final safePath = photoFile.path.replaceAll("'", "\\'");

  //       fileListContent += "file '$safePath'\n";
  //       fileListContent += "duration 1\n";
  //     }

  //     if (sortedKeys.isNotEmpty) {
  //       final lastPhoto = _photos[sortedKeys.last]!;
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
}
