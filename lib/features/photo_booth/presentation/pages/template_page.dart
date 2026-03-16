import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/style/color/colors_app.dart';
import '../../../setting/data/datasource/frame_template_local_datasource.dart';
import '../../../setting/data/models/request/frame_template.dart';
import 'camera_page.dart';

import '../../../../core/component/buttons.dart';

class TemplatePage extends StatefulWidget {
  const TemplatePage({super.key});

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  FrameTemplate? _selectedTemplate;
  List<FrameTemplate> _availableTemplates = [];
  int _currentTemplateIndex = 0;
  late PageController _pageController;

  // Template image size (untuk BoxFit.contain offset correction)
  Size? _templateImageSize;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadTemplates();
  }

  @override
  void dispose() {
    _pageController.dispose();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
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
      context.push(
        CameraPage(
          selectedTemplate: _selectedTemplate,
          templateImageSize: _templateImageSize,
        ),
      );
    }
  }

  Future<void> _loadTemplates() async {
    final templates = await FrameTemplateLocalDatasource().loadAllTemplates();
    setState(() {
      _availableTemplates = templates;
    });
  }

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
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: _availableTemplates.isEmpty
                ? templateIsEmpty()
                : listTemplate(context),
          ),
        ),
      ),
    );
  }

  Column listTemplate(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Header dengan judul dan indikator
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Text(
                'Pilih Template',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ColorsApp.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '${_currentTemplateIndex + 1} / ${_availableTemplates.length}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Template Display Area
        Expanded(
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
          Expanded(
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

  Container templateIsEmpty() {
    return Container(
      padding: EdgeInsets.all(32),
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_album_outlined, size: 80, color: Colors.grey[300]),
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
}

// class TemplatePage extends StatefulWidget {
//   const TemplatePage({super.key});

//   @override
//   State<TemplatePage> createState() => _TemplatePageState();
// }

// class _TemplatePageState extends State<TemplatePage> {
//   FrameTemplate? _selectedTemplate;
//   List<FrameTemplate> _availableTemplates = [];

//   // Template image size (untuk BoxFit.contain offset correction)
//   Size? _templateImageSize;

//   @override
//   void initState() {
//     super.initState();
//     // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     _loadTemplates();
//   }

//   @override
//   void dispose() {
//     // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     super.dispose();
//   }

//   Future<void> _loadTemplates() async {
//     final templates = await FrameTemplateLocalDatasource().loadAllTemplates();
//     setState(() {
//       _availableTemplates = templates;
//     });
//   }

//   Future<void> _loadTemplateImageSize(String imagePath) async {
//     final file = File(imagePath);
//     if (!file.existsSync()) return;

//     final completer = Completer<Size>();
//     final imageProvider = FileImage(file);
//     final stream = imageProvider.resolve(const ImageConfiguration());
//     late ImageStreamListener listener;
//     listener = ImageStreamListener(
//       (ImageInfo info, bool _) {
//         if (!completer.isCompleted) {
//           completer.complete(
//             Size(info.image.width.toDouble(), info.image.height.toDouble()),
//           );
//         }
//         stream.removeListener(listener);
//       },
//       onError: (e, st) {
//         if (!completer.isCompleted) completer.completeError(e);
//         stream.removeListener(listener);
//       },
//     );
//     stream.addListener(listener);

//     try {
//       final size = await completer.future;
//       if (mounted) {
//         setState(() {
//           _templateImageSize = size;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading template image size: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SizedBox.expand(
//           child: Padding(
//             padding: EdgeInsets.all(16),
//             child: _availableTemplates.isEmpty
//                 ? templateIsEmpty()
//                 : listTemplate(context),
//           ),
//         ),
//       ),
//     );
//   }

//   Column listTemplate(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (_selectedTemplate != null)
//           Container(
//             padding: EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: ColorsApp.primary,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.check_circle, color: Colors.white),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'Template dipilih: ${_selectedTemplate!.name}',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     context.push(
//                       CameraPage(
//                         selectedTemplate: _selectedTemplate,
//                         templateImageSize: _templateImageSize,
//                       ),
//                     );
//                   },
//                   style: TextButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: ColorsApp.primary,
//                     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   ),
//                   child: Text('Lanjut Ambil Foto'),
//                 ),
//               ],
//             ),
//           ),
//         SizedBox(height: 12),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 12,
//             mainAxisSpacing: 12,
//             childAspectRatio: 0.75,
//           ),
//           itemCount: _availableTemplates.length,
//           itemBuilder: (context, index) {
//             final template = _availableTemplates[index];
//             final isSelected = _selectedTemplate?.id == template.id;
//             return _buildTemplateCard(template, isSelected);
//           },
//         ),
//       ],
//     );
//   }

//   Container templateIsEmpty() {
//     return Container(
//       padding: EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(20),
//             blurRadius: 20,
//             offset: Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.photo_album_outlined, size: 80, color: Colors.grey[300]),
//             SizedBox(height: 16),
//             Text(
//               'Belum Ada Template',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[600],
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Buat template terlebih dahulu',
//               style: TextStyle(fontSize: 14, color: Colors.grey[500]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   _buildTemplateCard(FrameTemplate template, bool isSelected) {
//     final frameFile = File(template.framePath);
//     final frameExists = frameFile.existsSync();

//     return InkWell(
//       onTap: () {
//         setState(() {
//           _selectedTemplate = template;
//           _templateImageSize = null; // reset lalu muat ulang
//         });
//         _loadTemplateImageSize(template.framePath);
//       },
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: isSelected ? ColorsApp.primary : Colors.grey[300]!,
//             width: isSelected ? 3 : 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withAlpha(10),
//               blurRadius: 10,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Preview Frame
//             Expanded(
//               child: Container(
//                 margin: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: frameExists
//                       ? Image.file(frameFile, fit: BoxFit.cover)
//                       : Center(
//                           child: Icon(
//                             Icons.broken_image,
//                             color: Colors.grey[400],
//                             size: 40,
//                           ),
//                         ),
//                 ),
//               ),
//             ),
//             // Info
//             Padding(
//               padding: EdgeInsets.all(8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     template.name,
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Icon(Icons.photo_library, size: 12, color: Colors.grey),
//                       SizedBox(width: 4),
//                       Text(
//                         '${template.numberOfPhotoStrips} Photos',
//                         style: TextStyle(fontSize: 11, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                   if (isSelected)
//                     Container(
//                       margin: EdgeInsets.only(top: 8),
//                       padding: EdgeInsets.symmetric(vertical: 4),
//                       decoration: BoxDecoration(
//                         color: ColorsApp.primary,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '✓ Terpilih',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 11,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
