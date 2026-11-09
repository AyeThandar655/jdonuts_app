import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists who is signed in, so a relaunch can restore the session.
abstract interface class SessionStorage {
  Future<String?> readPhone();
  Future<void> writePhone(String phone);
  Future<void> clear();
}

/// Keychain (iOS) / Keystore-backed (Android) session.
final class SecureSessionStorage implements SessionStorage {
  const SecureSessionStorage(this._storage);
  final FlutterSecureStorage _storage;

  static const String _phoneKey = 'session.phone';

  @override
  Future<String?> readPhone() => _storage.read(key: _phoneKey);

  @override
  Future<void> writePhone(String phone) =>
      _storage.write(key: _phoneKey, value: phone);

  @override
  Future<void> clear() => _storage.delete(key: _phoneKey);
}

/// Volatile session for tests.
final class InMemorySessionStorage implements SessionStorage {
  String? _phone;

  @override
  Future<String?> readPhone() async => _phone;

  @override
  Future<void> writePhone(String phone) async => _phone = phone;

  @override
  Future<void> clear() async => _phone = null;
}
