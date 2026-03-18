import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_photo_booth/core/component/custom_textformfield.dart';
import 'package:flutter_photo_booth/core/component/space.dart';
import 'package:flutter_photo_booth/core/extensions/build_context_ext.dart';
import 'package:flutter_photo_booth/core/style/color/colors_app.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/datasource/frame_template_local_datasource.dart';
import '../../data/models/request/button_area.dart';
import '../../data/models/request/frame_template.dart';

class CreateFrameTemplate extends StatefulWidget {
  final FrameTemplate? editingTemplate;

  const CreateFrameTemplate({super.key, this.editingTemplate});

  @override
  State<CreateFrameTemplate> createState() => _CreateFrameTemplateState();
}

class _CreateFrameTemplateState extends State<CreateFrameTemplate> {
  final TextEditingController _templateNameController = TextEditingController();

  int _numberOfPhotoStrips = 1;

  File? _templateFrame;

  final ImagePicker _picker = ImagePicker();

  ButtonArea? _selectedArea;

  bool _isResizing = false;
  bool _isDragging = false;

  List<ButtonArea> _photoAreas = []; // Area untuk foto

  String? _editingTemplateId;

  @override
  void initState() {
    super.initState();
    _loadEditingTemplate();
  }

  void _loadEditingTemplate() {
    if (widget.editingTemplate != null) {
      final template = widget.editingTemplate!;
      _editingTemplateId = template.id;
      _templateNameController.text = template.name;
      _numberOfPhotoStrips = template.numberOfPhotoStrips;
      _templateFrame = File(template.framePath);
      _photoAreas = template.photoAreas
          .map(
            (area) => ButtonArea(
              x: area.x,
              y: area.y,
              width: area.width,
              height: area.height,
              function: area.function,
            ),
          )
          .toList();
    }
  }

  @override
  void dispose() {
    _templateNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editingTemplateId == null
              ? 'Create Frame Template'
              : 'Edit Frame Template',
        ),
        actions: [
          IconButton(
            onPressed: _saveTemplate,
            icon: Icon(Icons.save_rounded),
            tooltip: 'Save Template',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              'Nama Template',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ColorsApp.primary,
              ),
            ),
            SpaceHeight(4),
            CustomTextFormField(
              controller: _templateNameController,
              hintText: 'Masukkan nama template',
              focusedBorderColor: ColorsApp.primary,
            ),
            SpaceHeight(12),
            // Number of Photo Strips
            Text(
              'Nomor Strip Foto',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ColorsApp.primary,
              ),
            ),
            SpaceHeight(4),
            Text(
              'Strip: $_numberOfPhotoStrips',
              style: TextStyle(color: ColorsApp.textSecondary, fontSize: 12),
            ),
            SpaceHeight(12),
            _buildNumberSelector(),
            SpaceHeight(12),
            if (_templateFrame == null)
              _buildPickImageButton()
            else
              _buildTemplatePreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberSelector() {
    return Wrap(
      children: List.generate(8, (index) {
        final number = index + 1;
        final isSelected = _numberOfPhotoStrips == number;
        return Padding(
          padding: EdgeInsets.only(right: 12, bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                _numberOfPhotoStrips = number;
                // Reset areas jika jumlah berubah
                if (_photoAreas.length > number) {
                  _photoAreas = _photoAreas.take(number).toList();
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorsApp.primary
                    : ColorsApp.primary.withAlpha(77),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? ColorsApp.primary
                      : ColorsApp.primary.withAlpha(77),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPickImageButton() {
    return InkWell(
      onTap: _pickTemplateImage,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.withAlpha(50),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey),
            SpaceHeight(16),
            Text(
              'Select Frame Image',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SpaceHeight(8),
            Text(
              'Choose a PNG image with transparency',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SpaceHeight(24),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: ColorsApp.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image, color: Colors.white, size: 20),
                  SpaceWidth(8),
                  Text(
                    'Pick Image',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  Widget _buildTemplatePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Actions
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickTemplateImage,
                icon: Icon(Icons.image, size: 18),
                label: Text('Change Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsApp.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SpaceWidth(12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ColorsApp.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Areas: ${_photoAreas.length}/$_numberOfPhotoStrips',
                style: TextStyle(
                  color: _photoAreas.length == _numberOfPhotoStrips
                      ? Color(0xFF4CAF50)
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SpaceHeight(16),
        Container(
          decoration: BoxDecoration(
            color: ColorsApp.grey,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
            border: Border.all(color: ColorsApp.grey, width: 3),
          ),
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Image.file(
                          _templateFrame!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                    // Overlay layer untuk areas
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
                              // Gambar area foto
                              ..._photoAreas.asMap().entries.map((entry) {
                                int index = entry.key;
                                ButtonArea area = entry.value;
                                return _buildAreaWidget(
                                  index: index,
                                  area: area,
                                  constraints: stackConstraints,
                                );
                              }),
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
      ],
    );
  }

  // Fungsi untuk menyimpan template
  Future<void> _saveTemplate() async {
    // Validasi nama template
    if (_templateNameController.text.trim().isEmpty) {
      context.showAlertError(message: 'Nama template tidak boleh kosong');
      return;
    }

    // Validasi frame image
    if (_templateFrame == null) {
      context.showAlertError(message: 'Pilih frame image terlebih dahulu');
      return;
    }

    // Validasi jumlah area foto
    if (_photoAreas.length != _numberOfPhotoStrips) {
      context.showAlertError(
        message:
            'Jumlah area foto harus sama dengan jumlah strip ($_numberOfPhotoStrips)',
      );
      return;
    }

    try {
      // Buat atau update template
      final template = FrameTemplate(
        id:
            _editingTemplateId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _templateNameController.text.trim(),
        numberOfPhotoStrips: _numberOfPhotoStrips,
        framePath: _templateFrame!.path,
        photoAreas: _photoAreas,
        createdAt: widget.editingTemplate?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simpan template
      await FrameTemplateLocalDatasource().saveTemplate(
        template,
        onSuccess: () {
          context.showAlertSuccess(
            message: _editingTemplateId == null
                ? 'Template berhasil dibuat!'
                : 'Template berhasil diupdate!',
          );

          // Kembali ke halaman sebelumnya
          Future.delayed(Duration(seconds: 1), () {
            if (mounted) {
              context.pop(true);
            }
          });
        },
        onError: (error) {
          context.showAlertError(message: 'Gagal menyimpan template: $error');
        },
      );
    } catch (e) {
      if (mounted) {
        context.showAlertError(message: 'Error: $e');
      }
    }
  }

  Future<void> _pickTemplateImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Hapus file gambar lama jika sedang edit template
        if (_templateFrame != null && await _templateFrame!.exists()) {
          await _templateFrame!.delete();
        }

        // Salin file ke permanent directory
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName =
            'frame_${DateTime.now().millisecondsSinceEpoch}.png';
        final String permanentPath = '${appDir.path}/$fileName';

        // Copy file dari temporary ke permanent
        final File tempFile = File(image.path);
        final File permanentFile = await tempFile.copy(permanentPath);

        setState(() {
          _templateFrame = permanentFile;
          // Reset area saat mengganti template
          _photoAreas.clear();
          _selectedArea = null;
        });

        if (mounted) {
          context.showAlertSuccess(message: 'Image loaded successfully!');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showAlertError(message: 'Failed to pick image: $e');
      }
    }
  }

  // Fungsi untuk mengecek apakah tap berada di dalam area yang sudah ada
  bool _isTapInsideExistingArea(
    Offset tapPosition,
    BoxConstraints constraints,
  ) {
    final containerWidth = constraints.maxWidth;
    final containerHeight = constraints.maxHeight;

    for (var area in _photoAreas) {
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

    return false;
  }

  // Fungsi untuk menambahkan area foto baru
  void _addButtonArea(TapDownDetails details, BoxConstraints constraints) {
    // Cek apakah sudah mencapai limit jumlah area
    if (_photoAreas.length >= _numberOfPhotoStrips) {
      return;
    }

    final containerWidth = constraints.maxWidth;
    final containerHeight = constraints.maxHeight;

    const defaultWidthPercent = 0.50; // 25% lebar
    const defaultHeightPercent = 0.25; // 25% tinggi

    setState(() {
      _photoAreas.add(
        ButtonArea(
          x:
              (details.localPosition.dx / containerWidth) -
              (defaultWidthPercent / 2),
          y:
              (details.localPosition.dy / containerHeight) -
              (defaultHeightPercent / 2),
          width: defaultWidthPercent,
          height: defaultHeightPercent,
          function: 'Photo ${_photoAreas.length + 1}',
        ),
      );
    });
  }

  // Fungsi untuk mendapatkan warna berbeda untuk setiap area foto
  Color _getColorForPhotoArea(int index) {
    final colors = [
      Color(0xFF00B8D4), // Cyan
      Color(0xFFFF6B9D), // Pink
      Color(0xFF9D4EDD), // Purple
      Color(0xFFFFA726), // Orange
      Color(0xFF66BB6A), // Green
      Color(0xFFEF5350), // Red
      Color(0xFF42A5F5), // Blue
      Color(0xFFFFEE58), // Yellow
    ];
    return colors[index % colors.length];
  }

  // Widget untuk menampilkan area foto
  Widget _buildAreaWidget({
    required int index,
    required ButtonArea area,
    required BoxConstraints constraints,
  }) {
    final isSelected = _selectedArea == area;
    final color = _getColorForPhotoArea(
      index,
    ); // Warna berbeda untuk setiap area

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

    return Positioned(
      left: pixelX,
      top: pixelY,
      child: GestureDetector(
        onTap: () => _selectArea(index),
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: _isResizing
            ? null
            : (details) => _updateAreaPosition(index, details, constraints),
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
          });
        },
        child: Container(
          width: pixelWidth,
          height: pixelHeight,
          decoration: BoxDecoration(
            color: color.withAlpha(80),
            border: Border.all(
              color: isSelected ? Colors.white : color,
              width: isSelected ? 3 : 2,
            ),
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

              // Tombol hapus (hanya tampil saat dipilih)
              if (isSelected)
                Positioned(
                  top: -12,
                  right: -12,
                  child: GestureDetector(
                    onTap: () => _deleteArea(index),
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
              if (isSelected) ..._buildResizeHandles(index, area, constraints),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membuat resize handles
  List<Widget> _buildResizeHandles(
    int index,
    ButtonArea area,
    BoxConstraints constraints,
  ) {
    const handleSize = 32.0;
    const hitAreaPadding = 12.0;
    final handleColor = _getColorForPhotoArea(index); // Warna sesuai area foto
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
              area.width = (area.width + normalizedDeltaWidth).clamp(0.1, 1.0);
              area.height = (area.height + normalizedDeltaHeight).clamp(
                0.1,
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

  // Fungsi untuk memilih area
  void _selectArea(int index) {
    setState(() {
      _selectedArea = _photoAreas[index];
    });
  }

  // Fungsi untuk update posisi area saat di-drag
  void _updateAreaPosition(
    int index,
    DragUpdateDetails details,
    BoxConstraints constraints,
  ) {
    final containerWidth = constraints.maxWidth;
    final containerHeight = constraints.maxHeight;
    final normalizedDeltaX = details.delta.dx / containerWidth;
    final normalizedDeltaY = details.delta.dy / containerHeight;

    setState(() {
      _photoAreas[index].x += normalizedDeltaX;
      _photoAreas[index].y += normalizedDeltaY;
    });
  }

  // Fungsi untuk menghapus area
  void _deleteArea(int index) {
    setState(() {
      if (_selectedArea == _photoAreas[index]) {
        _selectedArea = null;
      }
      _photoAreas.removeAt(index);
    });
  }
}
