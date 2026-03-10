import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/voucher_model.dart';

class VoucherLocalDatasource {
  static const String _vouchersKey = 'vouchers_list';
  static const String _voucherRequiredKey = 'voucher_required';

  // Generate random voucher code
  String _generateVoucherCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    // Generate random string
    final randomString = List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();

    // Combine with timestamp and hash
    final combined = '$randomString-$timestamp';
    final bytes = utf8.encode(combined);
    final hash = sha256
        .convert(bytes)
        .toString()
        .substring(0, 12)
        .toUpperCase();

    // Format: XXXX-XXXX-XXXX
    return '${hash.substring(0, 4)}-${hash.substring(4, 8)}-${hash.substring(8, 12)}';
  }

  // Generate multiple vouchers
  Future<List<VoucherModel>> generateVouchers({
    required int count,
    required DateTime expiryDate,
  }) async {
    if (count <= 0 || count > 50) {
      throw Exception('Voucher count must be between 1 and 50');
    }

    final vouchers = <VoucherModel>[];
    final existingVouchers = await getVouchers();
    final existingCodes = existingVouchers.map((v) => v.code).toSet();

    for (int i = 0; i < count; i++) {
      String code;
      do {
        code = _generateVoucherCode();
      } while (existingCodes.contains(code));

      existingCodes.add(code);
      vouchers.add(VoucherModel(code: code, expiryDate: expiryDate));
    }

    await saveVouchers([...existingVouchers, ...vouchers]);
    return vouchers;
  }

  // Save vouchers to storage
  Future<void> saveVouchers(List<VoucherModel> vouchers) async {
    final prefs = await SharedPreferences.getInstance();
    final vouchersJson = vouchers.map((v) => v.toJson()).toList();
    await prefs.setStringList(_vouchersKey, vouchersJson);
  }

  // Get all vouchers
  Future<List<VoucherModel>> getVouchers() async {
    final prefs = await SharedPreferences.getInstance();
    final vouchersJson = prefs.getStringList(_vouchersKey) ?? [];
    return vouchersJson.map((json) => VoucherModel.fromJson(json)).toList();
  }

  // Find voucher by code
  Future<VoucherModel?> findVoucherByCode(String code) async {
    final vouchers = await getVouchers();
    try {
      return vouchers.firstWhere(
        (v) => v.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Validate and use voucher
  Future<Map<String, dynamic>> validateAndUseVoucher(String code) async {
    final voucher = await findVoucherByCode(code);

    if (voucher == null) {
      return {'isValid': false, 'message': 'Voucher tidak ditemukan'};
    }

    if (voucher.isUsed) {
      return {
        'isValid': false,
        'message':
            'Voucher sudah pernah digunakan pada ${_formatDateTime(voucher.usedAt!)}',
      };
    }

    if (voucher.isExpired()) {
      return {
        'isValid': false,
        'message':
            'Voucher sudah expired pada ${_formatDateTime(voucher.expiryDate)}',
      };
    }

    // Mark voucher as used
    final vouchers = await getVouchers();
    final index = vouchers.indexWhere((v) => v.code == voucher.code);
    if (index != -1) {
      vouchers[index] = voucher.copyWith(isUsed: true, usedAt: DateTime.now());
      await saveVouchers(vouchers);
    }

    return {
      'isValid': true,
      'message': 'Voucher berhasil divalidasi',
      'voucher': vouchers[index],
    };
  }

  // Delete voucher
  Future<void> deleteVoucher(String code) async {
    final vouchers = await getVouchers();
    vouchers.removeWhere((v) => v.code == code);
    await saveVouchers(vouchers);
  }

  // Delete all vouchers
  Future<void> deleteAllVouchers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vouchersKey);
  }

  // Get voucher statistics
  Future<Map<String, int>> getVoucherStats() async {
    final vouchers = await getVouchers();

    return {
      'total': vouchers.length,
      'used': vouchers.where((v) => v.isUsed).length,
      'expired': vouchers.where((v) => v.isExpired() && !v.isUsed).length,
      'valid': vouchers.where((v) => v.isValid()).length,
    };
  }

  // Set voucher required status
  Future<void> setVoucherRequired(bool required) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_voucherRequiredKey, required);
  }

  // Get voucher required status
  Future<bool> isVoucherRequired() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_voucherRequiredKey) ?? false;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
