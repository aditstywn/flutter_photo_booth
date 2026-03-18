import 'package:flutter/material.dart';
import 'package:flutter_photo_booth/core/component/custom_textformfield.dart';
import 'package:flutter_photo_booth/core/component/space.dart';
import 'package:flutter_photo_booth/core/extensions/build_context_ext.dart';

import '../../../../core/component/buttons.dart';
import '../../../../core/style/color/colors_app.dart';
import '../../data/datasource/description_wa_local_datasource.dart';

class DescriptionWaPage extends StatefulWidget {
  const DescriptionWaPage({super.key});

  @override
  State<DescriptionWaPage> createState() => _DescriptionWaPageState();
}

class _DescriptionWaPageState extends State<DescriptionWaPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final DescriptionWaLocalDatasource _datasource =
      DescriptionWaLocalDatasource();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final description = await _datasource.loadDescription();
      if (mounted) {
        setState(() {
          _descriptionController.text = description;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showAlertError(message: 'Error loading settings: $e');
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _datasource.saveDescription(_descriptionController.text);
      if (mounted) {
        context.showAlertSuccess(message: 'Description WA berhasil disimpan');
      }
    } catch (e) {
      if (mounted) {
        context.showAlertError(message: 'Error saving settings: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Description WA')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                CustomTextFormField(
                  controller: _descriptionController,
                  label: 'Description WA',
                  hintText: 'Masukkan description yang akan dikirim ke WA',
                  maxLines: 5,
                ),
                SpaceHeight(16),
                Button.filled(
                  onPressed: () {
                    _saveSettings();
                  },
                  label: 'Simpan',
                  color: ColorsApp.primary,
                ),
              ],
            ),
    );
  }
}
