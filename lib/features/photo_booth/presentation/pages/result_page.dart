import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../../../core/component/buttons.dart';
import '../../../../core/component/space.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/style/color/colors_app.dart';
import '../../../history/data/datasource/print_history_datasource.dart';
import '../../../setting/data/datasource/custom_button_local_datasource.dart';
import '../../../setting/data/datasource/custom_frame_local_datasource.dart';
import '../../../setting/data/datasource/printer_datasource.dart';
import '../../../setting/data/models/request/button_area.dart';
import '../../../setting/data/models/request/frame_template.dart';
import '../../data/models/request/create_photobooth_request_model.dart';
import '../bloc/photobooth/photobooth_bloc.dart';
import '../bloc/qrcode/qrcode_bloc.dart';
import '../widgets/build_tappable_area.dart';
import 'camera_page.dart';
import 'main_page.dart';

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
  bool _loadingVidio = false;

  // String? _description = '';
  String? _qrImageUrl;
  String? _qrVideoUrl;
  int? idPhoto;

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _photos = Map<int, File>.from(widget.uploadedPhotos ?? {});
    _loadSavedFrames();
    _loadSavedButtonAreas();
    // _loadDescription();
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

  // Future<void> _loadDescription() async {
  //   try {
  //     final description = await DescriptionWaLocalDatasource()
  //         .loadDescription();
  //     if (mounted) {
  //       setState(() {
  //         _description = description;
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       context.showAlertError(message: 'Error loading settings: $e');
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.pushAndRemoveUntil(MainPage(), (route) => route.isFirst);
          context.read<PhotoboothBloc>().add(
            PhotoboothEvent.deleteFile(idPhoto ?? 0),
          );
        }
      },
      child: BlocListener<QrcodeBloc, QrcodeState>(
        listener: (context, state) {
          switch (state) {
            case LoadingQrCode():
              setState(() {
                _loading = true;
              });
              break;
            case ErrorQrCode(:final error):
              context.showAlertError(message: 'Gagal membuat QR code: $error');
              setState(() {
                _loading = false;
              });
              break;
            case CreateQrSuccess(:final response):
              setState(() {
                _qrImageUrl = response.qrImageUrl?.replaceFirst(
                  'http://',
                  'https://',
                );
                _loading = false;
              });
              debugPrint('QR code created: $_qrImageUrl');
              break;
            case CreateQrVideoSuccess(:final response):
              setState(() {
                _qrVideoUrl = response.qrImageUrl?.replaceFirst(
                  'http://',
                  'https://',
                );
                _loadingVidio = false;
              });
              debugPrint('QR video code created: $_qrVideoUrl');
              break;
          }
        },
        child: BlocListener<PhotoboothBloc, PhotoboothState>(
          listener: (context, state) {
            switch (state) {
              case LoadingPhotobooth():
                setState(() {
                  _loading = true;
                });
                break;
              case LoadingPhotobooth3():
                setState(() {
                  _loadingVidio = true;
                });
                break;

              case CreateFileSuccess(:final response):
                context.read<QrcodeBloc>().add(
                  QrcodeEvent.createQr(response.data?.token ?? ''),
                );

                setState(() {
                  idPhoto = response.data?.id;
                });
                break;

              case CreateFileVidioSuccess(:final response):
                context.read<QrcodeBloc>().add(
                  QrcodeEvent.createQrVideo(response.data?.token ?? ''),
                );

                setState(() {
                  idPhoto = response.data?.id;
                });
                break;

              case ErrorPhotobooth(:final error):
                context.showAlertError(message: 'Upload gagal: $error');
                setState(() {
                  _loading = false;
                  _loadingVidio = false;
                });
                break;
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
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
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
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 28,
                                        vertical: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(35),
                                            blurRadius: 12,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                            color: ColorsApp.primary,
                                            strokeWidth: 4,
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Loading...',
                                            style: TextStyle(
                                              color: ColorsApp.primary,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
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
                                      setState(() {
                                        _loading = true;
                                      });
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

                    if (_qrImageUrl != null)
                      Positioned.fill(
                        child: Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ColorsApp.grey.withAlpha(225),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: LayoutBuilder(
                            builder: (context, overlayConstraints) {
                              final cardSize = math.min(
                                (overlayConstraints.maxWidth * 0.6).clamp(
                                  180.0,
                                  320.0,
                                ),
                                (overlayConstraints.maxHeight * 0.32).clamp(
                                  180.0,
                                  320.0,
                                ),
                              );
                              final qrSize = (cardSize * 0.72).clamp(
                                130.0,
                                240.0,
                              );

                              return Center(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (_qrImageUrl != null)
                                        Container(
                                          height: cardSize,
                                          width: cardSize,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(
                                                  50,
                                                ),
                                                spreadRadius: 2,
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              SpaceHeight(8),
                                              Text(
                                                'Foto QR Code',
                                                style: TextStyle(
                                                  color: ColorsApp.primary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SpaceHeight(8),
                                              Center(
                                                child: Container(
                                                  width: qrSize,
                                                  height: qrSize,
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withAlpha(45),
                                                        spreadRadius: 1,
                                                        blurRadius: 12,
                                                        offset: Offset(0, 6),
                                                      ),
                                                    ],
                                                  ),
                                                  child: SvgPicture.network(
                                                    _qrImageUrl!,
                                                    fit: BoxFit.contain,
                                                    placeholderBuilder:
                                                        (context) => Center(
                                                          child: SizedBox(
                                                            width: 24,
                                                            height: 24,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Icon(
                                          Icons.qr_code_2,
                                          size: 48,
                                          color: Colors.red,
                                        ),
                                      SpaceHeight(16),
                                      if (_qrVideoUrl != null)
                                        Container(
                                          height: cardSize,
                                          width: cardSize,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(
                                                  50,
                                                ),
                                                spreadRadius: 2,
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                SpaceHeight(8),
                                                Text(
                                                  'Gif QR Code',
                                                  style: TextStyle(
                                                    color: ColorsApp.primary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SpaceHeight(8),
                                                Container(
                                                  width: qrSize,
                                                  height: qrSize,
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withAlpha(45),
                                                        spreadRadius: 1,
                                                        blurRadius: 12,
                                                        offset: Offset(0, 6),
                                                      ),
                                                    ],
                                                  ),
                                                  child: SvgPicture.network(
                                                    _qrVideoUrl!,
                                                    fit: BoxFit.contain,
                                                    placeholderBuilder:
                                                        (context) => Center(
                                                          child: SizedBox(
                                                            width: 24,
                                                            height: 24,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      else
                                        Button.filled(
                                          width: math.min(
                                            context.deviceWidth * 0.6,
                                            cardSize,
                                          ),
                                          label: 'Generate Gif ',
                                          onPressed: () {
                                            _createVideoFromPhotos();
                                          },
                                          loading: _loadingVidio,
                                          color: ColorsApp.primary,
                                        ),
                                      SpaceHeight(16),
                                      Text(
                                        'Tekan tutup untuk kembali ke halaman utama, file foto akan terhapus otomatis setelah tekan tutup.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SpaceHeight(12),
                                      BlocConsumer<
                                        PhotoboothBloc,
                                        PhotoboothState
                                      >(
                                        listener: (context, state) {
                                          switch (state) {
                                            case DeleteFileSuccess():
                                              context.pushAndRemoveUntil(
                                                MainPage(),
                                                (route) => route.isFirst,
                                              );
                                              setState(() {
                                                _qrImageUrl = null;
                                                _qrVideoUrl = null;
                                              });
                                              break;
                                            case ErrorPhotobooth(:final error):
                                              context.showAlertError(
                                                message: error,
                                              );
                                              context.pushAndRemoveUntil(
                                                MainPage(),
                                                (route) => route.isFirst,
                                              );
                                              setState(() {
                                                _qrImageUrl = null;
                                                _qrVideoUrl = null;
                                              });
                                              break;
                                          }
                                        },
                                        builder: (context, state) {
                                          if (state is LoadingPhotobooth2) {
                                            return Button.filled(
                                              width: math.min(
                                                context.deviceWidth * 0.6,
                                                cardSize,
                                              ),
                                              label: 'Loading...',
                                              onPressed: () {},
                                              color: ColorsApp.primary,
                                              loading: true,
                                            );
                                          }
                                          return Button.filled(
                                            width: math.min(
                                              context.deviceWidth * 0.6,
                                              cardSize,
                                            ),
                                            label: 'Tutup',
                                            onPressed: () {
                                              context
                                                  .read<PhotoboothBloc>()
                                                  .add(
                                                    PhotoboothEvent.deleteFile(
                                                      idPhoto ?? 0,
                                                    ),
                                                  );
                                            },
                                            color: ColorsApp.primary,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
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

        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showAlertError(message: 'Gagal menyimpan gambar: $e');
      }
      setState(() {
        _loading = false;
      });
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

      // Siapkan foto yang sudah mirror untuk galeri dan upload backend.
      final List<File> flippedPhotosForUpload = [];
      final sortedPhotoKeys = _photos.keys.toList()..sort();

      for (final i in sortedPhotoKeys) {
        final originalPhoto = _photos[i];
        if (originalPhoto == null) continue;

        final originalBytes = await originalPhoto.readAsBytes();
        img.Image? originalImage = img.decodeImage(originalBytes);

        if (originalImage == null) continue;

        final flippedImage = img.flipHorizontal(originalImage);

        final tempDir = await getApplicationDocumentsDirectory();
        final flippedPath = '${tempDir.path}/flipped_photo_${i}_$timestamp.jpg';
        final flippedFile = File(flippedPath);
        await flippedFile.writeAsBytes(img.encodeJpg(flippedImage));

        flippedPhotosForUpload.add(flippedFile);
      }

      if (imageFile.existsSync()) {
        if (mounted) {
          final createFiles = CreatePhotoboothRequestModel(
            photoTemplate: imageFile,
            photoOri: flippedPhotosForUpload,
          );

          context.read<PhotoboothBloc>().add(
            PhotoboothEvent.createFile(createFiles),
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
            backgroundColor: ColorsApp.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'Konfirmasi',
              style: TextStyle(
                color: ColorsApp.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Apakah Anda yakin ingin mengambil ulang foto?',
              style: TextStyle(fontSize: 14, color: ColorsApp.textSecondary),
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
                  backgroundColor: ColorsApp.primary,
                ),
                child: Text(
                  'Ambil Ulang',
                  style: TextStyle(color: Colors.white),
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
                    context.push(
                      CameraPage(
                        selectedTemplate: widget.selectedTemplate,
                        templateImageSize: widget.templateImageSize,
                        retakePhotoIndex: null,
                      ),
                    );
                    setState(() {
                      _photos.clear();
                    });
                    context.showAlertSuccess(
                      message: 'Silakan ambil ulang semua foto',
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

  Future<File?> _createVideoFromPhotos() async {
    try {
      if (_photos.isEmpty) {
        debugPrint('Tidak ada foto untuk membuat video');
        return null;
      }

      setState(() {
        _loadingVidio = true;
      });

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final outputPath = '${directory.path}/photobooth_video_$timestamp.mp4';

      final sortedKeys = _photos.keys.toList()..sort();

      // Ambil ukuran dari foto pertama untuk menentukan orientasi video
      final firstPhotoBytes = await _photos[sortedKeys.first]!.readAsBytes();
      final firstImage = img.decodeImage(firstPhotoBytes);

      if (firstImage == null) {
        debugPrint('Gagal decode foto pertama');
        setState(() {
          _loadingVidio = false;
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
          final photoFile = _photos[key]!;

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
        final videoFile = File(outputPath);
        if (videoFile.existsSync()) {
          context.read<PhotoboothBloc>().add(
            PhotoboothEvent.createFileVidio(videoFile, idPhoto ?? 0),
          );
        } else {
          context.showAlertError(message: 'Gagal membuat video');
        }
      }

      debugPrint("Video berhasil dibuat: $outputPath");

      return File(outputPath);
    } catch (e) {
      setState(() {
        _loadingVidio = false;
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
