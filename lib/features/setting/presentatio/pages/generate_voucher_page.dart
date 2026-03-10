import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_photo_booth/core/component/custom_textformfield.dart';

import '../../../../core/component/buttons.dart';
import '../../../../core/component/space.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/style/color/colors_app.dart';
import '../../data/datasource/voucher_local_datasource.dart';
import '../../data/models/voucher_model.dart';

class GenerateVoucherPage extends StatefulWidget {
  const GenerateVoucherPage({super.key});

  @override
  State<GenerateVoucherPage> createState() => _GenerateVoucherPageState();
}

class _GenerateVoucherPageState extends State<GenerateVoucherPage> {
  final _datasource = VoucherLocalDatasource();
  final _countController = TextEditingController(text: '10');
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  List<VoucherModel> _vouchers = [];
  Map<String, int> _stats = {};
  bool _isLoading = false;

  bool _isVoucherRequired = false;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
    _loadStats();
    _loadSettings();
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final required = await _datasource.isVoucherRequired();
    setState(() {
      _isVoucherRequired = required;
      _isLoading = false;
    });
  }

  Future<void> _loadVouchers() async {
    final vouchers = await _datasource.getVouchers();
    setState(() {
      _vouchers = vouchers;
    });
  }

  Future<void> _loadStats() async {
    final stats = await _datasource.getVoucherStats();
    setState(() {
      _stats = stats;
    });
  }

  Future<void> _generateVouchers() async {
    final count = int.tryParse(_countController.text) ?? 0;

    if (count <= 0 || count > 50) {
      context.showAlertError(
        message: 'Jumlah voucher harus antara 1 sampai 50',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newVouchers = await _datasource.generateVouchers(
        count: count,
        expiryDate: _selectedDate,
      );

      await _loadVouchers();
      await _loadStats();

      if (mounted) {
        context.showAlertSuccess(
          message: 'Berhasil generate ${newVouchers.length} voucher',
        );
      }
    } catch (e) {
      if (mounted) {
        context.showAlertError(message: e.toString());
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _deleteVoucher(String code) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorsApp.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Hapus voucher $code?',
          style: TextStyle(color: ColorsApp.textPrimary, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _datasource.deleteVoucher(code);
      await _loadVouchers();
      await _loadStats();
      if (mounted) {
        context.showAlertSuccess(message: 'Voucher berhasil dihapus');
      }
    }
  }

  Future<void> _deleteAllVouchers() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorsApp.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Hapus semua voucher?',
          style: TextStyle(fontSize: 14, color: ColorsApp.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus Semua',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _datasource.deleteAllVouchers();
      await _loadVouchers();
      await _loadStats();
      if (mounted) {
        context.showAlertSuccess(message: 'Semua voucher berhasil dihapus');
      }
    }
  }

  void _copyVoucherCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    context.showAlertSuccess(message: 'Kode voucher disalin');
  }

  Future<void> _toggleVoucherRequired(bool value) async {
    setState(() {
      _isVoucherRequired = value;
    });

    await _datasource.setVoucherRequired(value);

    if (mounted) {
      if (value) {
        context.showAlertSuccess(
          message:
              'Voucher wajib diaktifkan. User harus input voucher untuk akses aplikasi.',
        );
      } else {
        context.showAlertSuccess(
          message:
              'Voucher wajib dinonaktifkan. User dapat langsung akses aplikasi.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Voucher'),
        actions: [
          if (_vouchers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _deleteAllVouchers,
              tooltip: 'Hapus Semua',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),

        children: [
          Card(
            color: ColorsApp.white,
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isVoucherRequired ? Icons.lock : Icons.lock_open,
                        color: _isVoucherRequired
                            ? ColorsApp.accentGreen
                            : ColorsApp.grey,
                        size: 32,
                      ),
                      const SpaceWidth(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Aktifkan Voucher Wajib',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SpaceHeight(4),
                            Text(
                              _isVoucherRequired
                                  ? 'User harus memasukkan voucher untuk akses Camera'
                                  : 'User dapat langsung akses Camera tanpa voucher',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isVoucherRequired,
                        onChanged: _toggleVoucherRequired,
                        activeThumbColor: ColorsApp.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SpaceHeight(16),
          // Statistics Card
          if (_stats.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Total', _stats['total'] ?? 0, Colors.blue),
                  _buildStatItem('Valid', _stats['valid'] ?? 0, Colors.green),
                  _buildStatItem(
                    'Terpakai',
                    _stats['used'] ?? 0,
                    Colors.orange,
                  ),
                  _buildStatItem('Expired', _stats['expired'] ?? 0, Colors.red),
                ],
              ),
            ),
          SpaceHeight(16),
          // Generate Form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Generate Voucher Baru',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SpaceHeight(16),
                CustomTextFormField(
                  controller: _countController,
                  label: 'Jumlah Voucher (1-50)',
                  hintText: 'Masukkan jumlah voucher (1-50)',
                  keyboardType: TextInputType.number,
                  focusedBorderColor: ColorsApp.primary,
                ),

                const SpaceHeight(16),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFE0E0E0), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SpaceWidth(12),
                        Text(
                          'Expired: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SpaceHeight(16),
                Button.filled(
                  onPressed: () => _generateVouchers(),
                  label: _isLoading ? 'Generating...' : 'Generate Voucher',
                  color: ColorsApp.primary,
                  disabled: _isLoading,
                  loading: _isLoading,
                ),
              ],
            ),
          ),

          const SpaceHeight(16),

          // Vouchers List
          if (_vouchers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'Belum ada voucher\nGenerate voucher untuk memulai',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

          // Display vouchers
          ..._vouchers.map((voucher) {
            final isExpired = voucher.isExpired();
            final isUsed = voucher.isUsed;

            Color statusColor = Colors.green;
            String statusText = 'Valid';
            IconData statusIcon = Icons.check_circle;

            if (isUsed) {
              statusColor = Colors.orange;
              statusText = 'Terpakai';
              statusIcon = Icons.check_circle_outline;
            } else if (isExpired) {
              statusColor = Colors.red;
              statusText = 'Expired';
              statusIcon = Icons.cancel;
            }

            return Card(
              color: ColorsApp.white,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(statusIcon, color: statusColor),
                title: Text(
                  voucher.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exp: ${voucher.expiryDate.day}/${voucher.expiryDate.month}/${voucher.expiryDate.year}',
                    ),
                    if (isUsed && voucher.usedAt != null)
                      Text(
                        'Digunakan: ${voucher.usedAt!.day}/${voucher.usedAt!.month}/${voucher.usedAt!.year}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SpaceWidth(8),
                    InkWell(
                      child: Icon(Icons.copy, size: 20),
                      onTap: () => _copyVoucherCode(voucher.code),
                    ),
                    SpaceWidth(8),
                    InkWell(
                      child: Icon(Icons.delete, size: 20),
                      onTap: () => _deleteVoucher(voucher.code),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
