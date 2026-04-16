import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/component/buttons.dart';
import '../../../../core/component/space.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/style/color/colors_app.dart';
import '../../../history/data/datasource/print_history_datasource.dart';
import '../../../setting/data/datasource/custom_button_local_datasource.dart';
import '../../../setting/data/datasource/custom_frame_local_datasource.dart';
import '../../../setting/data/datasource/description_wa_local_datasource.dart';
import '../../../setting/data/datasource/printer_datasource.dart';
import '../../../setting/data/models/request/button_area.dart';
import '../../../setting/data/models/request/frame_template.dart';
import '../../data/models/request/create_photobooth_request_model.dart';
import '../bloc/photobooth/photobooth_bloc.dart';
import '../bloc/qrcode/qrcode_bloc.dart';
import '../widgets/build_tappable_area.dart';
import 'camera_page.dart';
import 'main_page.dart';

Future<List<String>> _flipAndStorePhotosIsolate(
  Map<String, dynamic> params,
) async {
  final photoPaths = List<String>.from(params['photoPaths'] as List);
  final outputDir = params['outputDir'] as String;
  final timestamp = params['timestamp'] as int;

  final List<String> flippedPaths = [];

  for (var i = 0; i < photoPaths.length; i++) {
    final originalFile = File(photoPaths[i]);
    if (!originalFile.existsSync()) continue;

    final originalBytes = await originalFile.readAsBytes();
    final originalImage = img.decodeImage(originalBytes);
    if (originalImage == null) continue;

    final flippedImage = img.flipHorizontal(originalImage);
    final flippedPath = '$outputDir/flipped_photo_${i}_$timestamp.jpg';
    final flippedFile = File(flippedPath);
    await flippedFile.writeAsBytes(img.encodeJpg(flippedImage));
    flippedPaths.add(flippedPath);
  }

  return flippedPaths;
}

Future<List<Uint8List>> _prepareVideoFramesIsolate(
  Map<String, dynamic> params,
) async {
  final photoPaths = List<String>.from(params['photoPaths'] as List);
  final canvasWidth = params['canvasWidth'] as int;
  final canvasHeight = params['canvasHeight'] as int;
  final shouldFlip = params['shouldFlip'] as bool;

  img.Image fitToCanvas(
    img.Image source,
    int targetCanvasWidth,
    int targetCanvasHeight,
  ) {
    final canvasAspect = targetCanvasWidth / targetCanvasHeight;
    final sourceAspect = source.width / source.height;

    int targetWidth;
    int targetHeight;
    if (sourceAspect > canvasAspect) {
      targetWidth = targetCanvasWidth;
      targetHeight = (targetCanvasWidth / sourceAspect).round();
    } else {
      targetHeight = targetCanvasHeight;
      targetWidth = (targetCanvasHeight * sourceAspect).round();
    }

    final resized = img.copyResize(
      source,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.linear,
    );

    final canvas = img.Image(
      width: targetCanvasWidth,
      height: targetCanvasHeight,
    );
    img.fill(canvas, color: img.ColorRgb8(0, 0, 0));

    final offsetX = ((targetCanvasWidth - targetWidth) / 2).round();
    final offsetY = ((targetCanvasHeight - targetHeight) / 2).round();
    img.compositeImage(canvas, resized, dstX: offsetX, dstY: offsetY);
    return canvas;
  }

  final List<Uint8List> preparedFrames = [];

  for (final path in photoPaths) {
    final bytes = await File(path).readAsBytes();
    var image = img.decodeImage(bytes);
    if (image == null) continue;

    if (shouldFlip) {
      image = img.flipHorizontal(image);
    }

    final fitted = fitToCanvas(image, canvasWidth, canvasHeight);
    preparedFrames.add(fitted.getBytes(order: img.ChannelOrder.rgba));
  }

  return preparedFrames;
}

class _PreparedUploadAssets {
  final File compositeFile;
  final List<File> flippedPhotos;

  const _PreparedUploadAssets({
    required this.compositeFile,
    required this.flippedPhotos,
  });
}

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

  String? _description = '';
  String? _qrImageUrl;
  String? expiredAt;
  String? _qrVideoUrl;
  int? idPhoto;

  File? _cachedCompositeFile;
  List<File>? _cachedFlippedPhotos;
  int _assetGeneration = 0;
  Future<_PreparedUploadAssets?>? _prepareUploadAssetsTask;

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _photos = Map<int, File>.from(widget.uploadedPhotos ?? {});
    _loadSavedFrames();
    _loadSavedButtonAreas();
    _loadDescription();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _warmUpUploadAssetsIfReady();
    });
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _warmUpUploadAssetsIfReady();
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.pushAndRemoveUntil(MainPage(), (route) => route.isFirst);
          // context.read<PhotoboothBloc>().add(
          //   PhotoboothEvent.deleteFile(idPhoto ?? 0),
          // );
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
                expiredAt = response.expiredAt;
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
                                      // _saveCompositeImageWa();
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
                                      Text(
                                        'Qr code berlaku sampai \n ${expiredAt ?? '-'}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SpaceHeight(8),
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
                                        'Tekan tutup untuk kembali ke halaman utama,\n dan memulai sesi baru',
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
                                              context.pushAndRemoveUntil(
                                                MainPage(),
                                                (route) => route.isFirst,
                                              );
                                              setState(() {
                                                _qrImageUrl = null;
                                                _qrVideoUrl = null;
                                              });
                                              // context
                                              //     .read<PhotoboothBloc>()
                                              //     .add(
                                              //       PhotoboothEvent.deleteFile(
                                              //         idPhoto ?? 0,
                                              //       ),
                                              //     );
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
    if (!_isPhotoSetComplete) {
      context.showAlertError(message: 'Please upload all photos first');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      return;
    }

    try {
      final preparedAssets = await _getOrPrepareUploadAssets(showErrors: true);
      if (preparedAssets == null) {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
        return;
      }

      if (mounted) {
        final createFiles = CreatePhotoboothRequestModel(
          photoTemplate: preparedAssets.compositeFile,
          photoOri: preparedAssets.flippedPhotos,
        );

        context.read<PhotoboothBloc>().add(
          PhotoboothEvent.createFile(createFiles),
        );
      }
    } catch (e) {
      if (mounted) {
        context.showAlertError(message: 'Gagal menyimpan gambar: $e');
        setState(() {
          _loading = false;
        });
      }
    }
  }

  bool get _isPhotoSetComplete {
    final total = widget.selectedTemplate?.numberOfPhotoStrips;
    if (total == null) return false;
    return _photos.length == total;
  }

  void _invalidateUploadAssetsCache() {
    _assetGeneration += 1;
    _cachedCompositeFile = null;
    _cachedFlippedPhotos = null;
  }

  void _warmUpUploadAssetsIfReady() {
    if (!_isPhotoSetComplete) return;
    _getOrPrepareUploadAssets(showErrors: false);
  }

  Future<_PreparedUploadAssets?> _getOrPrepareUploadAssets({
    required bool showErrors,
  }) async {
    final cachedComposite = _cachedCompositeFile;
    final cachedFlipped = _cachedFlippedPhotos;

    if (cachedComposite != null &&
        cachedComposite.existsSync() &&
        cachedFlipped != null &&
        cachedFlipped.isNotEmpty &&
        cachedFlipped.every((file) => file.existsSync())) {
      return _PreparedUploadAssets(
        compositeFile: cachedComposite,
        flippedPhotos: cachedFlipped,
      );
    }

    if (_prepareUploadAssetsTask != null) {
      return _prepareUploadAssetsTask;
    }

    final task = _prepareUploadAssets(showErrors: showErrors);
    _prepareUploadAssetsTask = task;

    try {
      return await task;
    } finally {
      if (identical(_prepareUploadAssetsTask, task)) {
        _prepareUploadAssetsTask = null;
      }
    }
  }

  Future<_PreparedUploadAssets?> _prepareUploadAssets({
    required bool showErrors,
  }) async {
    if (!_isPhotoSetComplete) {
      if (showErrors && mounted) {
        context.showAlertError(message: 'Please upload all photos first');
      }
      return null;
    }

    final generationAtStart = _assetGeneration;

    try {
      await WidgetsBinding.instance.endOfFrame;

      final boundaryContext = _compositeKey.currentContext;
      if (boundaryContext == null) {
        if (showErrors && mounted) {
          context.showAlertError(message: 'Preview belum siap, coba lagi.');
        }
        return null;
      }

      final renderObject = boundaryContext.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        if (showErrors && mounted) {
          context.showAlertError(message: 'Preview belum siap, coba lagi.');
        }
        return null;
      }

      // Delay singkat untuk memastikan area preview sudah terpaint sempurna.
      await Future.delayed(Duration(milliseconds: 60));

      final ui.Image image = await renderObject.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Gagal konversi hasil komposit.');
      }
      final pngBytes = byteData.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '${directory.path}/photoboot_$timestamp.png';

      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes, flush: true);

      final sortedPhotoKeys = _photos.keys.toList()..sort();
      final sortedPhotoPaths = sortedPhotoKeys
          .map((key) => _photos[key]?.path)
          .whereType<String>()
          .toList();

      final flippedPhotoPaths = await compute(_flipAndStorePhotosIsolate, {
        'photoPaths': sortedPhotoPaths,
        'outputDir': directory.path,
        'timestamp': timestamp,
      });

      final flippedPhotosForUpload = flippedPhotoPaths
          .map(File.new)
          .where((file) => file.existsSync())
          .toList();

      if (flippedPhotosForUpload.isEmpty) {
        throw Exception('Gagal menyiapkan foto asli.');
      }

      final preparedAssets = _PreparedUploadAssets(
        compositeFile: imageFile,
        flippedPhotos: flippedPhotosForUpload,
      );

      if (mounted && generationAtStart == _assetGeneration) {
        _cachedCompositeFile = preparedAssets.compositeFile;
        _cachedFlippedPhotos = preparedAssets.flippedPhotos;
      }

      return preparedAssets;
    } catch (e) {
      if (showErrors && mounted) {
        context.showAlertError(message: 'Gagal menyiapkan file upload: $e');
      }
      return null;
    }
  }

  Future<void> _saveCompositeImageWa() async {
    if (_photos.length != widget.selectedTemplate?.numberOfPhotoStrips) {
      context.showAlertError(message: 'Please upload all photos first');
      return;
    }

    try {
      await WidgetsBinding.instance.endOfFrame;

      // Tangkap widget komposit sebagai gambar
      final boundaryContext = _compositeKey.currentContext;
      if (boundaryContext == null) {
        if (mounted) {
          context.showAlertError(message: 'Preview belum siap, coba lagi.');
        }
        return;
      }
      final RenderRepaintBoundary boundary =
          boundaryContext.findRenderObject() as RenderRepaintBoundary;

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

      final sortedPhotoKeys = _photos.keys.toList()..sort();
      final sortedPhotoPaths = sortedPhotoKeys
          .map((key) => _photos[key]?.path)
          .whereType<String>()
          .toList();

      // foto_ori
      for (final oriPath in sortedPhotoPaths) {
        await Gal.putImage(oriPath, album: 'Boothera');
      }

      // Simpan foto template
      await Gal.putImage(imageFile.path, album: 'Boothera');

      if (imageFile.existsSync()) {
        if (mounted) {
          setState(() {
            _loading = false;
          });
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
                          context.pushAndRemoveUntil(
                            MainPage(),
                            (route) => route.isFirst,
                          );
                          setState(() {
                            _qrImageUrl = null;
                            _qrVideoUrl = null;
                          });
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
                    _invalidateUploadAssetsCache();
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
      _invalidateUploadAssetsCache();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _warmUpUploadAssetsIfReady();
      });
      context.showAlertSuccess(
        message: 'Foto ${photoIndex + 1} berhasil diupdate',
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

      final sortedPhotoPaths = sortedKeys
          .map((key) => _photos[key]?.path)
          .whereType<String>()
          .toList();

      // Pre-process semua foto di isolate agar animasi loading tetap halus.
      final preparedFrames = await compute(_prepareVideoFramesIsolate, {
        'photoPaths': sortedPhotoPaths,
        'canvasWidth': width,
        'canvasHeight': height,
        'shouldFlip': true,
      });

      if (preparedFrames.isEmpty) {
        debugPrint('Gagal menyiapkan frame video');
        setState(() {
          _loadingVidio = false;
        });
        return null;
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
        for (final rgba in preparedFrames) {
          /// tampilkan foto selama 0.5 detik
          for (int i = 0; i < framesPerSlide; i++) {
            await FlutterQuickVideoEncoder.appendVideoFrame(rgba);
          }

          // Beri kesempatan UI melakukan repaint di sela encoding.
          await Future.delayed(Duration.zero);
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
