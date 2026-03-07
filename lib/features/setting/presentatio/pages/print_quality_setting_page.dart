import 'package:flutter/material.dart';
import '../../../../core/component/buttons.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/style/color/colors_app.dart';
import '../../../../core/style/thypograpy/photo_booth_text_style.dart';
import '../../data/datasource/print_settings_datasource.dart';
import '../../data/models/request/print_settings.dart';

class PrintQualitySettingPage extends StatefulWidget {
  const PrintQualitySettingPage({super.key});

  @override
  State<PrintQualitySettingPage> createState() =>
      _PrintQualitySettingPageState();
}

class _PrintQualitySettingPageState extends State<PrintQualitySettingPage> {
  final PrintSettingsDatasource _datasource = PrintSettingsDatasource();

  // Current settings values
  double _brightness = 1.4;
  double _contrast = 1.05;
  int _threshold = 170;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _datasource.loadSettings();
      if (mounted) {
        setState(() {
          _brightness = settings.brightness;
          _contrast = settings.contrast;
          _threshold = settings.threshold;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showAlertError(message: 'Gagal load settings: $e');
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      final settings = PrintSettings(
        brightness: _brightness,
        contrast: _contrast,
        threshold: _threshold,
      );
      await _datasource.saveSettings(settings);
      if (mounted) {
        context.showAlertSuccess(message: 'Pengaturan berhasil disimpan!');
      }
    } catch (e) {
      if (mounted) {
        context.showAlertError(message: 'Gagal menyimpan: $e');
      }
    }
  }

  Future<void> _applyPreset(PrintSettings preset, String presetName) async {
    setState(() {
      _brightness = preset.brightness;
      _contrast = preset.contrast;
      _threshold = preset.threshold;
    });
    await _datasource.saveSettings(preset);
    if (mounted) {
      context.showAlertSuccess(message: 'Preset "$presetName" diterapkan!');
    }
  }

  Future<void> _resetToDefault() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset ke Default?'),
        content: const Text(
          'Semua pengaturan akan kembali ke nilai default (Sangat Cerah).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _datasource.resetToDefault();
      await _loadSettings();
      if (mounted) {
        context.showAlertSuccess(message: 'Berhasil reset ke default!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kualitas Cetak'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset ke Default',
            onPressed: _resetToDefault,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  _buildInfoCard(),
                  const SizedBox(height: 24),

                  // Brightness slider
                  _buildSliderSection(
                    title: 'Brightness (Kecerahan)',
                    subtitle: 'Seberapa terang foto akan dicetak',
                    icon: Icons.brightness_6,
                    value: _brightness,
                    min: 1.0,
                    max: 1.5,
                    divisions: 50,
                    displayValue: '${(_brightness * 100 - 100).toInt()}%',
                    onChanged: (value) => setState(() => _brightness = value),
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 24),

                  // Contrast slider
                  _buildSliderSection(
                    title: 'Contrast (Kontras)',
                    subtitle: 'Perbedaan antara area gelap dan terang',
                    icon: Icons.contrast,
                    value: _contrast,
                    min: 1.0,
                    max: 1.5,
                    divisions: 50,
                    displayValue: '${(_contrast * 100 - 100).toInt()}%',
                    onChanged: (value) => setState(() => _contrast = value),
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),

                  // Threshold slider
                  _buildSliderSection(
                    title: 'Threshold (Ambang Batas)',
                    subtitle: 'Menentukan pixel mana yang jadi hitam/putih',
                    icon: Icons.filter_b_and_w,
                    value: _threshold.toDouble(),
                    min: 100,
                    max: 200,
                    divisions: 100,
                    displayValue: _threshold.toString(),
                    onChanged: (value) =>
                        setState(() => _threshold = value.toInt()),
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 32),

                  // Presets
                  Text(
                    'Preset Cepat',
                    style: PhotoBoothTextStyle.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPresetButtons(),
                  const SizedBox(height: 32),

                  // Save button
                  Button.filled(
                    onPressed: _saveSettings,
                    label: 'Simpan Pengaturan',
                    color: ColorsApp.primary,
                    icon: Icon(Icons.save, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Pengaturan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Untuk foto wajah yang cerah: Brightness tinggi, Contrast rendah, Threshold tinggi',
                  style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: PhotoBoothTextStyle.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayValue,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              thumbColor: color,
              inactiveTrackColor: color.withOpacity(0.3),
              overlayColor: color.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPresetButton(
                'Sangat Cerah',
                '💡',
                PrintSettings.defaultSettings(),
                Colors.yellow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPresetButton(
                'Cerah',
                '☀️',
                PrintSettings.bright(),
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPresetButton(
                'Normal',
                '🌤️',
                PrintSettings.normal(),
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPresetButton(
                'Gelap',
                '🌑',
                PrintSettings.dark(),
                Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetButton(
    String name,
    String emoji,
    PrintSettings preset,
    Color color,
  ) {
    return InkWell(
      onTap: () => _applyPreset(preset, name),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'B:${(preset.brightness * 100 - 100).toInt()}% C:${(preset.contrast * 100 - 100).toInt()}% T:${preset.threshold}',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
