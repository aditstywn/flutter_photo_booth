import 'package:flutter/material.dart';
import 'package:flutter_photo_booth/core/component/custom_textformfield.dart';

import '../../../../core/component/buttons.dart';
import '../../../../core/component/space.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/style/color/colors_app.dart';
import '../../data/datasource/voucher_local_datasource.dart';

class VoucherInputPage extends StatefulWidget {
  const VoucherInputPage({super.key});

  @override
  State<VoucherInputPage> createState() => _VoucherInputPageState();
}

class _VoucherInputPageState extends State<VoucherInputPage> {
  final _datasource = VoucherLocalDatasource();
  final _voucherController = TextEditingController();
  bool _isValidating = false;

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  Future<void> _validateVoucher() async {
    final code = _voucherController.text.trim();

    if (code.isEmpty) {
      context.showAlertError(message: 'Masukkan kode voucher');
      return;
    }

    setState(() {
      _isValidating = true;
    });

    try {
      final result = await _datasource.validateAndUseVoucher(code);

      if (mounted) {
        if (result['isValid'] == true) {
          // Voucher valid, return true to caller
          context.showAlertSuccess(message: result['message']);
          Navigator.pop(context, true);
        } else {
          // Voucher invalid
          context.showAlertError(message: result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        context.showAlertError(message: 'Terjadi kesalahan: $e');
      }
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Voucher'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                size: 80,
                color: ColorsApp.primary,
              ),
              const SpaceHeight(24),
              const Text(
                'Masukkan Kode Voucher',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SpaceHeight(8),
              const Text(
                'Anda memerlukan voucher yang valid untuk mengakses aplikasi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: ColorsApp.textSecondary),
              ),
              const SpaceHeight(32),
              CustomTextFormField(
                controller: _voucherController,
                label: 'Kode Voucher',
                hintText: 'XXXX-XXXX-XXXX',
                focusedBorderColor: ColorsApp.primary,
                prefixIcon: const Icon(Icons.vpn_key, color: ColorsApp.primary),
              ),

              const SpaceHeight(16),
              Button.filled(
                onPressed: () => _validateVoucher(),
                label: _isValidating ? 'Memvalidasi...' : 'Validasi Voucher',
                color: ColorsApp.primary,
                disabled: _isValidating,
                loading: _isValidating,
              ),
              const SpaceHeight(8),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Kembali'),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorsApp.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Informasi:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: ColorsApp.textPrimary,
                      ),
                    ),
                    SpaceHeight(8),
                    Text(
                      '• Setiap voucher hanya dapat digunakan sekali\n'
                      '• Voucher memiliki tanggal kadaluarsa\n'
                      '• Hubungi administrator untuk mendapatkan voucher',
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorsApp.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
