import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppStorage {
  static final GetStorage _box = GetStorage();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<String?> get token => _secureStorage.read(key: 'auth_token');
  static int? get userId => _box.read('user_id');
  static Map<String, dynamic>? get user {
    final value = _box.read('user');
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  static Future<void> saveAuth({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    await _secureStorage.write(key: 'auth_token', value: token);
    await _box.remove('auth_token');
    await _box.remove('token');
    await _box.write('user', user);
    await _box.write('user_id', user['id']);
    await _box.write('user_name', user['name']);
    await _box.write('user_phone', user['phone']);
    await _box.write('user_email', user['email']);
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _box.write('user', user);
    await _box.write('user_id', user['id']);
    await _box.write('user_name', user['name']);
    await _box.write('user_phone', user['phone']);
    await _box.write('user_email', user['email']);
  }

  static Future<void> clearAuth() async {
    await _secureStorage.delete(key: 'auth_token');
    await _box.remove('user');
    await _box.remove('user_id');
    await _box.remove('user_name');
    await _box.remove('user_phone');
    await _box.remove('user_email');
  }
}
