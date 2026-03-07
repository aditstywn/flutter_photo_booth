import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_photo_booth/core/extensions/build_context_ext.dart';

import '../../../../core/component/space.dart';
import '../../../../core/component/tab_selector.dart';
import '../../data/datasource/custom_button_local_datasource.dart';
import '../../data/datasource/custom_frame_local_datasource.dart';
import '../../data/models/request/button_area.dart';
import '../widgets/color_and_icon_frame_area.dart';

class CustomButtonTemaPage extends StatefulWidget {
  const CustomButtonTemaPage({super.key});

  @override
  State<CustomButtonTemaPage> createState() => _CustomButtonTemaPageState();
}

class _CustomButtonTemaPageState extends State<CustomButtonTemaPage> {
  File? _mainFrame;
  File? _cameraFrame;
  File? _resultFrame;
  String _selectedFrame = 'main';

  // Pengaturan Frame Pembuka/Welcome Screen
  List<ButtonArea> _buttonAreasMain = [];

  // Pengaturan Frame Kamera
  ButtonArea? _cameraPreviewArea;
  List<ButtonArea> _cameraButtonAreas = []; // Untuk tombol Take Photo

  // Pengaturan Frame Hasil
  ButtonArea? _resultPreviewArea;
  List<ButtonArea> _buttonAreasResult = [];

  ButtonArea? _selectedArea; // Area yang sedang dipilih untuk edit

  String _selectedFunction = 'Start'; // Fungsi default untuk ditempatkan

  bool _isResizing = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _loadSavedFrames();
    _loadSavedButtonAreas();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Button'),
        actions: [
          IconButton(
            onPressed: () {
              CustomButtonLocalDatasource().saveConfiguration(
                buttonAreasLanding: _buttonAreasMain,
                cameraPreviewArea: _cameraPreviewArea,
                cameraButtonAreas: _cameraButtonAreas,
                resultPreviewArea: _resultPreviewArea,
                buttonAreasResult: _buttonAreasResult,
                onSuccess: () {
                  context.showAlertSuccess(
                    message: 'Konfigurasi berhasil disimpan',
                  );
                },
                onError: (e) {
                  context.showAlertError(
                    message: 'Gagal menyimpan konfigurasi',
                  );
                },
              );
            },
            icon: Icon(Icons.save_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ScrollableHorizontalTabSelector(
            fontSize: 12,
            borderRadius: 8,
            margin: EdgeInsets.zero,
            items: [
              TabItem(id: 'main', label: 'main ', icon: Icons.home_rounded),
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
                _selectedFunction = id == 'main'
                    ? 'Start'
                    : id == 'camera'
                    ? 'Camera'
                    : 'Preview';
                _selectedArea =
                    null; // Reset area yang dipilih saat ganti frame
              });
            },
          ),
          SpaceHeight(12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (_selectedFrame == 'main') ...[
                _buildFunctionChip('Start'),
              ] else if (_selectedFrame == 'camera') ...[
                _buildFunctionChip('Camera'),
                _buildFunctionChip('Take Photo'),
              ] else ...[
                _buildFunctionChip('Preview'),
                _buildFunctionChip('Retake'),
                _buildFunctionChip('Print'),
                _buildFunctionChip('Scan QR'),
              ],
            ],
          ),
          SpaceHeight(10),
          _buildEditSection(),
        ],
      ),
    );
  }

  Widget _buildFunctionChip(String function) {
    final isSelected = _selectedFunction == function;
    final bool isUsed;

    if (_selectedFrame == 'main') {
      isUsed = _buttonAreasMain.any((area) => area.function == function);
    } else if (_selectedFrame == 'camera') {
      // Untuk kamera, cek berdasarkan tipe fungsi
      if (function == 'Camera') {
        isUsed = _cameraPreviewArea != null;
      } else {
        isUsed = _cameraButtonAreas.any((area) => area.function == function);
      }
    } else {
      // Untuk hasil, cek jika fungsi digunakan di area tombol
      if (function == 'Preview') {
        isUsed = _resultPreviewArea != null;
      } else {
        isUsed = _buttonAreasResult.any((area) => area.function == function);
      }
    }

    final color = getColorForFunction(function);

    return Opacity(
      opacity: isUsed ? 0.5 : 1.0,
      child: InkWell(
        onTap: isUsed
            ? null
            : () {
                setState(() {
                  _selectedFunction = function;
                });
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: BoxConstraints(minWidth: 80),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isUsed
                ? Colors.grey[300]
                : (isSelected ? color : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isUsed ? Colors.grey : color, width: 2),
          ),
          child: Text(
            function,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isUsed
                  ? Colors.grey[600]
                  : (isSelected ? Colors.white : color),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildEditSection() {
    File? currentFrame = _selectedFrame == 'main'
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
        child: LayoutBuilder(
          builder: (context, outerConstraints) {
            return GestureDetector(
              onTapDown: (details) {
                // Jangan tambahkan area jika sedang resize atau drag
                if (!_isResizing && !_isDragging) {
                  // Cek apakah tap berada di dalam area yang sudah ada
                  if (!_isTapInsideExistingArea(
                    details.localPosition,
                    outerConstraints,
                  )) {
                    _addButtonArea(details, outerConstraints);
                  }
                }
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Base layer dengan ukuran pasti
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
                          currentFrame,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  // Overlay layer untuk areas - gunakan LayoutBuilder untuk mendapatkan ukuran sebenarnya
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
                              ..._buttonAreasMain.asMap().entries.map((entry) {
                                int index = entry.key;
                                ButtonArea area = entry.value;
                                return _buildAreaWidget(
                                  index: index,
                                  area: area,
                                  isCameraPreview: false,
                                  isResultPreview: false,
                                  constraints: stackConstraints,
                                );
                              }),
                            ] else if (_selectedFrame == 'camera') ...[
                              if (_cameraPreviewArea != null)
                                _buildAreaWidget(
                                  index: 0,
                                  area: _cameraPreviewArea!,
                                  isCameraPreview: true,
                                  isResultPreview: false,
                                  constraints: stackConstraints,
                                ),
                              ..._cameraButtonAreas.asMap().entries.map((
                                entry,
                              ) {
                                int index = entry.key;
                                ButtonArea area = entry.value;
                                return _buildAreaWidget(
                                  index: index,
                                  area: area,
                                  isCameraPreview: false,
                                  isResultPreview: false,
                                  constraints: stackConstraints,
                                );
                              }),
                            ] else if (_selectedFrame == 'result') ...[
                              if (_resultPreviewArea != null)
                                _buildAreaWidget(
                                  index: 0,
                                  area: _resultPreviewArea!,
                                  isCameraPreview: false,
                                  isResultPreview: true,
                                  constraints: stackConstraints,
                                ),
                              ..._buttonAreasResult.asMap().entries.map((
                                entry,
                              ) {
                                int index = entry.key;
                                ButtonArea area = entry.value;
                                return _buildAreaWidget(
                                  index: index,
                                  area: area,
                                  isCameraPreview: false,
                                  isResultPreview: false,
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
          },
        ),
      ),
    );
  }

  Widget _buildAreaWidget({
    required int index,
    required ButtonArea area,
    required bool isCameraPreview,
    required bool isResultPreview,
    required BoxConstraints constraints,
  }) {
    final isSelected = _selectedArea == area;
    // Treat both 'Camera' and 'Preview' as preview areas with green color
    final isPreviewArea = isCameraPreview || isResultPreview;
    final color = isPreviewArea
        ? Color(0xFF00B894) // Hijau untuk preview area
        : getColorForFunction(area.function);

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
      child: GestureDetector(
        onTap: () => _selectArea(index, isCameraPreview, isResultPreview),
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: _isResizing
            ? null
            : (details) => _updateAreaPosition(
                index,
                details,
                isCameraPreview,
                isResultPreview,
                constraints,
              ),
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
          });
        },
        child: Container(
          width: pixelWidth,
          height: pixelHeight,
          decoration: BoxDecoration(
            color: color.withAlpha(50),
            border: Border.all(
              color: isSelected ? Colors.white : color,
              width: isSelected ? 3 : 2,
            ),
            borderRadius: isPreviewArea
                ? BorderRadius.zero
                : BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withAlpha(128),
                      blurRadius: 15,
                      offset: Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Stack(
            children: [
              // Label fungsi
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPreviewArea
                          ? Icons.camera_alt
                          : getIconForFunction(area.function),
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ),

              // Tombol hapus (hanya tampil saat dipilih)
              if (isSelected)
                Positioned(
                  top: -12,
                  right: -12,
                  child: GestureDetector(
                    onTap: () =>
                        _deleteArea(index, isCameraPreview, isResultPreview),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(77),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),

              // Handle resize (hanya tampil saat dipilih)
              if (isSelected)
                ..._buildResizeHandles(
                  index,
                  area,
                  isCameraPreview,
                  isResultPreview,
                  constraints,
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResizeHandles(
    int index,
    ButtonArea area,
    bool isCameraPreview,
    bool isResultPreview,
    BoxConstraints constraints,
  ) {
    const handleSize = 32.0;
    const hitAreaPadding = 12.0;
    const handleColor = Color(0xFF5F72EB);
    final containerWidth = constraints.maxWidth;
    final containerHeight = constraints.maxHeight;

    return [
      // Handle kanan-bawah (resize lebar dan tinggi)
      Positioned(
        right: -handleSize / 2,
        bottom: -handleSize / 2,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            setState(() {
              _isResizing = true;
            });
          },
          onPanUpdate: (details) {
            setState(() {
              final normalizedDeltaWidth = details.delta.dx / containerWidth;
              final normalizedDeltaHeight = details.delta.dy / containerHeight;
              area.width = (area.width + normalizedDeltaWidth).clamp(0.05, 1.0);
              area.height = (area.height + normalizedDeltaHeight).clamp(
                0.03,
                1.0,
              );
            });
          },
          onPanEnd: (details) {
            setState(() {
              _isResizing = false;
            });
          },
          child: Container(
            width: handleSize + hitAreaPadding * 2,
            height: handleSize + hitAreaPadding * 2,
            padding: EdgeInsets.all(hitAreaPadding),
            child: Container(
              decoration: BoxDecoration(
                color: handleColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(77),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.zoom_out_map, size: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    ];
  }

  bool _isTapInsideExistingArea(
    Offset tapPosition,
    BoxConstraints constraints,
  ) {
    final containerWidth = constraints.maxWidth;
    final containerHeight = constraints.maxHeight;
    // Cek area tombol untuk frame main
    if (_selectedFrame == 'main') {
      for (var area in _buttonAreasMain) {
        final pixelX = area.x * containerWidth;
        final pixelY = area.y * containerHeight;
        final pixelWidth = area.width * containerWidth;
        final pixelHeight = area.height * containerHeight;
        if (tapPosition.dx >= pixelX &&
            tapPosition.dx <= pixelX + pixelWidth &&
            tapPosition.dy >= pixelY &&
            tapPosition.dy <= pixelY + pixelHeight) {
          return true;
        }
      }
    }

    // Cek area camera
    if (_selectedFrame == 'camera' && _cameraPreviewArea != null) {
      final area = _cameraPreviewArea!;
      final pixelX = area.x * containerWidth;
      final pixelY = area.y * containerHeight;
      final pixelWidth = area.width * containerWidth;
      final pixelHeight = area.height * containerHeight;
      if (tapPosition.dx >= pixelX &&
          tapPosition.dx <= pixelX + pixelWidth &&
          tapPosition.dy >= pixelY &&
          tapPosition.dy <= pixelY + pixelHeight) {
        return true;
      }
    }

    // Cek area tombol kamera
    if (_selectedFrame == 'camera') {
      for (var area in _cameraButtonAreas) {
        final pixelX = area.x * containerWidth;
        final pixelY = area.y * containerHeight;
        final pixelWidth = area.width * containerWidth;
        final pixelHeight = area.height * containerHeight;
        if (tapPosition.dx >= pixelX &&
            tapPosition.dx <= pixelX + pixelWidth &&
            tapPosition.dy >= pixelY &&
            tapPosition.dy <= pixelY + pixelHeight) {
          return true;
        }
      }
    }

    if (_selectedFrame == 'result' && _resultPreviewArea != null) {
      final area = _resultPreviewArea!;
      final pixelX = area.x * containerWidth;
      final pixelY = area.y * containerHeight;
      final pixelWidth = area.width * containerWidth;
      final pixelHeight = area.height * containerHeight;
      if (tapPosition.dx >= pixelX &&
          tapPosition.dx <= pixelX + pixelWidth &&
          tapPosition.dy >= pixelY &&
          tapPosition.dy <= pixelY + pixelHeight) {
        return true;
      }
    }

    // Cek area tombol hasil
    if (_selectedFrame == 'result') {
      for (var area in _buttonAreasResult) {
        final pixelX = area.x * containerWidth;
        final pixelY = area.y * containerHeight;
        final pixelWidth = area.width * containerWidth;
        final pixelHeight = area.height * containerHeight;
        if (tapPosition.dx >= pixelX &&
            tapPosition.dx <= pixelX + pixelWidth &&
            tapPosition.dy >= pixelY &&
            tapPosition.dy <= pixelY + pixelHeight) {
          return true;
        }
      }
    }

    return false;
  }

  void _addButtonArea(TapDownDetails details, BoxConstraints constraints) {
    final containerWidth = constraints.maxWidth;
    final containerHeight = constraints.maxHeight;

    const defaultWidthPercent = 0.3; // 30% lebar
    const defaultHeightPercent = 0.10; // 10% tinggi

    if (_selectedFrame == 'main') {
      // Mode main - cek apakah area sudah ada
      if (_buttonAreasMain.any((area) => area.function == _selectedFunction)) {
        return;
      }

      setState(() {
        _buttonAreasMain.add(
          ButtonArea(
            x:
                (details.localPosition.dx / containerWidth) -
                (defaultWidthPercent / 2),
            y:
                (details.localPosition.dy / containerHeight) -
                (defaultHeightPercent / 2),
            width: defaultWidthPercent,
            height: defaultHeightPercent,
            function: _selectedFunction,
          ),
        );
      });

      context.showAlertSuccess(message: 'Area $_selectedFunction ditambahkan');
    } else if (_selectedFrame == 'camera') {
      if (_selectedFunction == 'Camera') {
        // Mode Camera - hanya satu area yang diperbolehkan
        // Jika sudah ada, jangan buat yang baru
        if (_cameraPreviewArea != null) {
          return;
        }

        setState(() {
          const widthPercent = 0.6; // 60% lebar container
          final heightPercent = widthPercent * (9 / 16);

          _cameraPreviewArea = ButtonArea(
            x: (details.localPosition.dx / containerWidth) - (widthPercent / 2),
            y:
                (details.localPosition.dy / containerHeight) -
                (heightPercent / 2),
            width: widthPercent,
            height: heightPercent,
            function: 'Camera',
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Area Camera ditambahkan'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFF00B894),
          ),
        );
      } else {
        // Tombol Take Photo - cek jika sudah ada
        if (_cameraButtonAreas.any(
          (area) => area.function == _selectedFunction,
        )) {
          return;
        }

        setState(() {
          _cameraButtonAreas.add(
            ButtonArea(
              x:
                  (details.localPosition.dx / containerWidth) -
                  (defaultWidthPercent / 2),
              y:
                  (details.localPosition.dy / containerHeight) -
                  (defaultHeightPercent / 2),
              width: defaultWidthPercent,
              height: defaultHeightPercent,
              function: _selectedFunction,
            ),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Area $_selectedFunction ditambahkan'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFF5F72EB),
          ),
        );
      }
    } else {
      if (_selectedFunction == 'Preview') {
        // Mode Result - hanya satu area preview yang diperbolehkan
        if (_resultPreviewArea != null) {
          return;
        }

        setState(() {
          const widthPercent = 0.6; // 60% lebar container
          final heightPercent = widthPercent * (9 / 16);

          _resultPreviewArea = ButtonArea(
            x: (details.localPosition.dx / containerWidth) - (widthPercent / 2),
            y:
                (details.localPosition.dy / containerHeight) -
                (heightPercent / 2),
            width: widthPercent,
            height: heightPercent,
            function: 'Camera',
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Area Camera ditambahkan'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFF00B894),
          ),
        );
      } else {
        // Frame hasil - mode area tombol
        // Cek jika fungsi sudah ada - abaikan secara diam-diam
        if (_buttonAreasResult.any(
          (area) => area.function == _selectedFunction,
        )) {
          return;
        }

        setState(() {
          _buttonAreasResult.add(
            ButtonArea(
              x:
                  (details.localPosition.dx / containerWidth) -
                  (defaultWidthPercent / 2),
              y:
                  (details.localPosition.dy / containerHeight) -
                  (defaultHeightPercent / 2),
              width: defaultWidthPercent,
              height: defaultHeightPercent,
              function: _selectedFunction,
            ),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Area $_selectedFunction ditambahkan'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _selectArea(int index, bool isCameraPreview, bool isResultPreview) {
    setState(() {
      if (_selectedFrame == 'main') {
        _selectedArea = _buttonAreasMain[index];
      } else if (isCameraPreview) {
        _selectedArea = _cameraPreviewArea;
      } else if (_selectedFrame == 'camera') {
        _selectedArea = _cameraButtonAreas[index];
      } else if (isResultPreview) {
        _selectedArea = _resultPreviewArea;
      } else {
        _selectedArea = _buttonAreasResult[index];
      }
    });
  }

  void _updateAreaPosition(
    int index,
    DragUpdateDetails details,
    bool isCameraPreview,
    bool isResultPreview,
    BoxConstraints constraints,
  ) {
    final containerWidth = constraints.maxWidth;
    final containerHeight = constraints.maxHeight;
    final normalizedDeltaX = details.delta.dx / containerWidth;
    final normalizedDeltaY = details.delta.dy / containerHeight;

    setState(() {
      if (_selectedFrame == 'main') {
        _buttonAreasMain[index].x += normalizedDeltaX;
        _buttonAreasMain[index].y += normalizedDeltaY;
      } else if (isCameraPreview && _cameraPreviewArea != null) {
        _cameraPreviewArea!.x += normalizedDeltaX;
        _cameraPreviewArea!.y += normalizedDeltaY;
      } else if (_selectedFrame == 'camera') {
        _cameraButtonAreas[index].x += normalizedDeltaX;
        _cameraButtonAreas[index].y += normalizedDeltaY;
      } else if (isResultPreview && _resultPreviewArea != null) {
        _resultPreviewArea!.x += normalizedDeltaX;
        _resultPreviewArea!.y += normalizedDeltaY;
      } else {
        _buttonAreasResult[index].x += normalizedDeltaX;
        _buttonAreasResult[index].y += normalizedDeltaY;
      }
    });
  }

  void _deleteArea(int index, bool isCameraPreview, bool isResultPreview) {
    if (isCameraPreview) {
      setState(() {
        _selectedArea = null;
        _cameraPreviewArea = null;
      });

      context.showAlertSuccess(message: 'Area Camera dihapus');
    } else if (isResultPreview) {
      setState(() {
        _selectedArea = null;
        _resultPreviewArea = null;
      });

      context.showAlertSuccess(message: 'Area Result dihapus');
    } else {
      // Cek frame mana yang aktif

      if (_selectedFrame == 'main') {
        // Hapus dari area tombol untuk frame main
        final deletedFunction = _buttonAreasMain[index].function;
        setState(() {
          if (_selectedArea == _buttonAreasMain[index]) {
            _selectedArea = null;
          }
          _buttonAreasMain.removeAt(index);
        });

        context.showAlertSuccess(message: 'Area $deletedFunction dihapus');
      } else if (_selectedFrame == 'camera') {
        // Hapus dari area tombol kamera
        final deletedFunction = _cameraButtonAreas[index].function;
        setState(() {
          if (_selectedArea == _cameraButtonAreas[index]) {
            _selectedArea = null;
          }
          _cameraButtonAreas.removeAt(index);
        });

        context.showAlertSuccess(message: 'Area $deletedFunction dihapus');
      } else {
        // Hapus dari area tombol hasil
        final deletedFunction = _buttonAreasResult[index].function;
        setState(() {
          if (_selectedArea == _buttonAreasResult[index]) {
            _selectedArea = null;
          }
          _buttonAreasResult.removeAt(index);
        });

        context.showAlertSuccess(message: 'Area $deletedFunction dihapus');
      }
    }
  }
}
