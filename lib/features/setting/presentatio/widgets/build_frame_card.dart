import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_photo_booth/core/component/space.dart';

import '../../../../core/component/buttons.dart';
import '../../../../core/style/color/colors_app.dart';

class BuildFrameCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final File? frame;
  final VoidCallback onUpload;
  final VoidCallback onDelete;
  const BuildFrameCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.frame,
    required this.onUpload,
    required this.onDelete,
  });

  @override
  State<BuildFrameCard> createState() => _BuildFrameCardState();
}

class _BuildFrameCardState extends State<BuildFrameCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorsApp.primary.withAlpha(150),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorsApp.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: ColorsApp.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Preview or Upload Button
          if (widget.frame != null)
            Container(
              padding: EdgeInsets.all(20),
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // Show full preview
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: ClipRRect(
                              child: Image.file(
                                widget.frame!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 8,
                            ),
                          ],
                        ),

                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          child: Image.file(
                            widget.frame!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SpaceWidth(10),
                  SizedBox(
                    width: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: widget.onUpload,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ColorsApp.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(51),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.edit,
                              color: ColorsApp.white,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        InkWell(
                          onTap: widget.onDelete,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ColorsApp.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(51),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.delete,
                              color: ColorsApp.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          //   SizedBox(
          //     height: 200,
          //     width: double.infinity,
          //     child: Stack(
          //       children: [
          //         InkWell(
          //           onTap: () {
          //             // Show full preview
          //             showDialog(
          //               context: context,
          //               builder: (context) => Dialog(
          //                 backgroundColor: Colors.transparent,
          //                 child: ClipRRect(
          //                   child: Image.file(
          //                     widget.frame!,
          //                     fit: BoxFit.contain,
          //                   ),
          //                 ),
          //               ),
          //             );
          //           },
          //           child: ClipRRect(
          //             borderRadius: BorderRadius.only(
          //               bottomLeft: Radius.circular(20),
          //               bottomRight: Radius.circular(20),
          //             ),
          //             child: Image.file(
          //               widget.frame!,
          //               width: double.infinity,
          //               height: double.infinity,
          //               fit: BoxFit.cover,
          //             ),
          //           ),
          //         ),
          //         Positioned(
          //           top: 12,
          //           right: 12,
          //           child: Row(
          //             children: [
          //               InkWell(
          //                 onTap: widget.onUpload,
          //                 child: Container(
          //                   padding: EdgeInsets.all(10),
          //                   decoration: BoxDecoration(
          //                     color: Colors.white,
          //                     shape: BoxShape.circle,
          //                     boxShadow: [
          //                       BoxShadow(
          //                         color: Colors.black.withAlpha(51),
          //                         blurRadius: 8,
          //                       ),
          //                     ],
          //                   ),
          //                   child: Icon(
          //                     Icons.edit,
          //                     color: ColorsApp.primary,
          //                     size: 20,
          //                   ),
          //                 ),
          //               ),
          //               SizedBox(width: 8),
          //               InkWell(
          //                 onTap: widget.onDelete,
          //                 child: Container(
          //                   padding: EdgeInsets.all(10),
          //                   decoration: BoxDecoration(
          //                     color: Colors.white,
          //                     shape: BoxShape.circle,
          //                     boxShadow: [
          //                       BoxShadow(
          //                         color: Colors.black.withAlpha(51),
          //                         blurRadius: 8,
          //                       ),
          //                     ],
          //                   ),
          //                   child: Icon(
          //                     Icons.delete,
          //                     color: ColorsApp.error,
          //                     size: 20,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ],
          //     ),
          //   )
          else
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Button.filled(
                label: 'Upload Frame',
                onPressed: widget.onUpload,
                color: ColorsApp.primary,
                icon: Icon(
                  Icons.file_upload_outlined,
                  size: 25,
                  color: ColorsApp.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
