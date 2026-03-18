import 'package:flutter/material.dart';
import 'package:flutter_photo_booth/core/extensions/build_context_ext.dart';

import '../../../../core/component/buttons.dart';
import '../../../../core/component/space.dart';
import '../../../../core/style/color/colors_app.dart';
import '../../data/datasource/countdown_settings_datasource.dart';

class CountdownSettingPage extends StatefulWidget {
  const CountdownSettingPage({super.key});

  @override
  State<CountdownSettingPage> createState() => _CountdownSettingPageState();
}

class _CountdownSettingPageState extends State<CountdownSettingPage> {
  final CountdownSettingsDatasource _datasource = CountdownSettingsDatasource();
  int _countdownDuration = 3;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final duration = await _datasource.loadCountdownDuration();
      if (mounted) {
        setState(() {
          _countdownDuration = duration;
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
      await _datasource.saveCountdownDuration(_countdownDuration);
      if (mounted) {
        context.showAlertSuccess(
          message: 'Pengaturan countdown berhasil disimpan',
        );
      }
    } catch (e) {
      if (mounted) {
        context.showAlertError(message: 'Error saving settings: $e');
      }
    }
  }

  Future<void> _resetToDefault() async {
    try {
      await _datasource.resetToDefault();
      await _loadSettings();
      if (mounted) {
        context.showAlertSuccess(
          message: 'Pengaturan countdown berhasil direset ke default',
        );
      }
    } catch (e) {
      if (mounted) {
        context.showAlertError(message: 'Error reset pengaturan: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atur Countdown'),
        actions: [
          TextButton.icon(
            onPressed: _resetToDefault,
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color: Theme.of(context).primaryColor,
                                ),
                                SpaceWidth(12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Durasi Countdown',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SpaceHeight(4),
                                      Text(
                                        'Atur berapa detik countdown sebelum foto diambil',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SpaceHeight(24),
                            Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  '$_countdownDuration detik',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            SpaceHeight(24),
                            Slider(
                              value: _countdownDuration.toDouble(),
                              min: 0,
                              max: 10,
                              divisions: 10,
                              label: '$_countdownDuration detik',
                              onChanged: (value) {
                                setState(() {
                                  _countdownDuration = value.toInt();
                                });
                              },
                            ),
                            SpaceHeight(8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '0 detik\n(Tanpa countdown)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '10 detik',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SpaceHeight(16),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.info_outline, color: Colors.blue),
                        title: Text(
                          'Tips',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Countdown 0 detik akan mengambil foto langsung tanpa hitung mundur. Countdown 3-5 detik direkomendasikan untuk hasil terbaik.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    SpaceHeight(24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Button.filled(
                        label: 'Simpan Pengaturan',
                        onPressed: _saveSettings,
                        color: ColorsApp.primary,
                      ),
                    ),
                    SpaceHeight(16),
                    // Preview presets
                    Text(
                      'Preset Cepat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SpaceHeight(12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PresetChip(
                          label: 'Instan (0 detik)',
                          value: 0,
                          currentValue: _countdownDuration,
                          onTap: () {
                            setState(() => _countdownDuration = 0);
                          },
                        ),
                        _PresetChip(
                          label: 'Cepat (1 detik)',
                          value: 1,
                          currentValue: _countdownDuration,
                          onTap: () {
                            setState(() => _countdownDuration = 1);
                          },
                        ),
                        _PresetChip(
                          label: 'Normal (3 detik)',
                          value: 3,
                          currentValue: _countdownDuration,
                          onTap: () {
                            setState(() => _countdownDuration = 3);
                          },
                        ),
                        _PresetChip(
                          label: 'Lambat (5 detik)',
                          value: 5,
                          currentValue: _countdownDuration,
                          onTap: () {
                            setState(() => _countdownDuration = 5);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final int value;
  final int currentValue;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.value,
    required this.currentValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == currentValue;
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: isSelected
          ? Theme.of(context).primaryColor
          : Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[400]!,
      ),
    );
  }
}
