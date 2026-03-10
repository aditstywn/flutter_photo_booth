import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDatasource {
  Future<void> saveExpiredAt(String expiredAt) async {
    final secureStorage = FlutterSecureStorage();
    await secureStorage.write(key: "expired_at", value: expiredAt);
  }

  Future<String?> getExpiredAt() async {
    final secureStorage = FlutterSecureStorage();
    return await secureStorage.read(key: "expired_at");
  }

  Future<void> deleteExpiredAt() async {
    final secureStorage = FlutterSecureStorage();
    await secureStorage.delete(key: "expired_at");
  }

  // returns true if the token is still valid, false otherwise
  Future<bool> hasValidToken() async {
    final expiredAt = await getExpiredAt();

    return expiredAt != null && expiredAt.isNotEmpty;
  }
}
