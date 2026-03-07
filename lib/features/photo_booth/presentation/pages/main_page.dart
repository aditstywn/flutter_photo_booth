import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_ext.dart';
import '../../../setting/data/datasource/custom_button_local_datasource.dart';
import '../../../setting/data/datasource/custom_frame_local_datasource.dart';
import '../../../setting/data/models/request/button_area.dart';
import '../widgets/build_tappable_area.dart';
import 'template_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  File? _mainFrame;
  List<ButtonArea> _buttonAreasMain = [];

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadSavedFrames();
    _loadSavedButtonAreas();
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
          _mainFrame = main;
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

      onError: (e) {
        debugPrint('Error loading button areas: $e');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_mainFrame == null)
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
              else if (_mainFrame != null)
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Image.file(
                      _mainFrame!,
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
                        ..._buttonAreasMain.map((area) {
                          return buildTappableArea(
                            area: area,
                            constraints: stackConstraints,
                            onTap: () {
                              context.push(TemplatePage());
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
}
