import 'dart:io';

import 'package:flutter/material.dart';

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
            decoration: BoxDecoration(
              color: widget.color.withAlpha(30),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.color,
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
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF636E72),
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
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {
                      // Show full preview
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              widget.frame!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: Image.file(
                        widget.frame!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: widget.onUpload,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                              color: widget.color,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        InkWell(
                          onTap: widget.onDelete,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                              color: Colors.red,
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
          else
            Padding(
              padding: EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: widget.onUpload,
                icon: Icon(Icons.upload_file),
                label: Text('Upload Frame'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(double.infinity, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
