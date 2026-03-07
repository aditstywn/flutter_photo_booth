import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_photo_booth/core/component/space.dart';
import 'package:flutter_photo_booth/core/extensions/build_context_ext.dart';

import '../../data/datasource/frame_template_local_datasource.dart';
import '../../data/models/request/frame_template.dart';
import 'create_frame_template.dart';

class FrameTemplateListPage extends StatefulWidget {
  const FrameTemplateListPage({super.key});

  @override
  State<FrameTemplateListPage> createState() => _FrameTemplateListPageState();
}

class _FrameTemplateListPageState extends State<FrameTemplateListPage> {
  List<FrameTemplate> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
    });

    final templates = await FrameTemplateLocalDatasource().loadAllTemplates();

    setState(() {
      _templates = templates;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Frame Templates'), centerTitle: true),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _templates.isEmpty
          ? _buildEmptyState()
          : _buildTemplateList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateTemplate,
        icon: Icon(Icons.add),
        label: Text('Add Template'),
        backgroundColor: Color(0xFF00B8D4),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_album_outlined, size: 120, color: Colors.grey[300]),
          SpaceHeight(24),
          Text(
            'Belum Ada Template',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SpaceHeight(12),
          Text(
            'Tap tombol + untuk membuat template pertama',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateList() {
    return RefreshIndicator(
      onRefresh: _loadTemplates,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _templates.length,
        itemBuilder: (context, index) {
          final template = _templates[index];
          return _buildTemplateCard(template);
        },
      ),
    );
  }

  Widget _buildTemplateCard(FrameTemplate template) {
    final frameFile = File(template.framePath);
    final frameExists = frameFile.existsSync();

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToEditTemplate(template),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Preview Frame
              Container(
                width: 100,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: frameExists
                      ? Image.file(frameFile, fit: BoxFit.cover)
                      : Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey[400],
                            size: 40,
                          ),
                        ),
                ),
              ),
              SpaceWidth(16),
              // Info Template
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SpaceHeight(8),
                    Row(
                      children: [
                        Icon(
                          Icons.photo_library,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SpaceWidth(4),
                        Text(
                          '${template.numberOfPhotoStrips} Photo${template.numberOfPhotoStrips > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SpaceHeight(4),
                    Row(
                      children: [
                        Icon(Icons.grid_on, size: 16, color: Colors.grey[600]),
                        SpaceWidth(4),
                        Text(
                          '${template.photoAreas.length} Area${template.photoAreas.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                template.photoAreas.length ==
                                    template.numberOfPhotoStrips
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SpaceHeight(8),
                    Text(
                      'Updated: ${_formatDate(template.updatedAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              // Action Buttons
              Column(
                children: [
                  IconButton(
                    onPressed: () => _navigateToEditTemplate(template),
                    icon: Icon(Icons.edit, color: Color(0xFF00B8D4)),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(template),
                    icon: Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Baru saja';
        }
        return '${difference.inMinutes} menit lalu';
      }
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _navigateToCreateTemplate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateFrameTemplate()),
    );

    if (result == true) {
      _loadTemplates();
    }
  }

  Future<void> _navigateToEditTemplate(FrameTemplate template) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateFrameTemplate(editingTemplate: template),
      ),
    );

    if (result == true) {
      _loadTemplates();
    }
  }

  Future<void> _showDeleteConfirmation(FrameTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Template'),
        content: Text(
          'Apakah Anda yakin ingin menghapus template "${template.name}"?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteTemplate(template);
    }
  }

  Future<void> _deleteTemplate(FrameTemplate template) async {
    await FrameTemplateLocalDatasource().deleteTemplate(
      template.id,
      onSuccess: () {
        context.showAlertSuccess(
          message: 'Template "${template.name}" berhasil dihapus',
        );
        _loadTemplates();
      },
      onError: (error) {
        context.showAlertError(message: 'Gagal menghapus template: $error');
      },
    );
  }
}
