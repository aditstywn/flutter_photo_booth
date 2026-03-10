import 'package:flutter/material.dart';

import '../../../../core/component/buttons.dart';
import '../../../../core/component/space.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../data/datasource/voucher_local_datasource.dart';
import 'generate_voucher_page.dart';

class VoucherSettingsPage extends StatefulWidget {
  const VoucherSettingsPage({super.key});

  @override
  State<VoucherSettingsPage> createState() => _VoucherSettingsPageState();
}

class _VoucherSettingsPageState extends State<VoucherSettingsPage> {
  final _datasource = VoucherLocalDatasource();
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _datasource.getVoucherStats();
    setState(() {
      _stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Voucher')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Voucher Required Toggle
                const SpaceHeight(24),

                // Statistics
                if (_stats.isNotEmpty) ...[
                  const Text(
                    'Statistik Voucher',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SpaceHeight(16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total',
                          _stats['total'] ?? 0,
                          Icons.confirmation_number,
                          Colors.blue,
                        ),
                      ),
                      const SpaceWidth(12),
                      Expanded(
                        child: _buildStatCard(
                          'Valid',
                          _stats['valid'] ?? 0,
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SpaceHeight(12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Terpakai',
                          _stats['used'] ?? 0,
                          Icons.check_circle_outline,
                          Colors.orange,
                        ),
                      ),
                      const SpaceWidth(12),
                      Expanded(
                        child: _buildStatCard(
                          'Expired',
                          _stats['expired'] ?? 0,
                          Icons.cancel,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SpaceHeight(24),
                ],

                // Action Buttons
                const Text(
                  'Kelola Voucher',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SpaceHeight(16),
                Button.filled(
                  onPressed: () {
                    context.push(const GenerateVoucherPage()).then((_) {
                      _loadStats();
                    });
                  },
                  label: 'Generate & Kelola Voucher',
                  color: Colors.blue,
                  icon: const Icon(Icons.add_circle_outline),
                ),
                const SpaceHeight(24),

                // Information Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SpaceWidth(8),
                          Text(
                            'Informasi Voucher',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SpaceHeight(12),
                      const Text(
                        '• Voucher dapat di-generate hingga 50 sekaligus\n'
                        '• Setiap voucher hanya dapat digunakan sekali\n'
                        '• Voucher memiliki tanggal kadaluarsa yang dapat diatur\n'
                        '• Saat voucher wajib diaktifkan, user harus memasukkan voucher valid sebelum dapat mengakses Camera\n'
                        '• Voucher yang sudah expired atau terpakai tidak dapat digunakan lagi',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SpaceHeight(8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
