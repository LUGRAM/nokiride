import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppStorage {
  static final GetStorage _box = GetStorage();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<String?> get token => _secureStorage.read(key: 'auth_token');
  static int? get userId => _box.read('user_id');
  static String? get userRole => user?['role']?.toString();
  static String? get lastActiveRole => _box.read('last_active_role');
  static String? get vehicleId =>
      user?['vehicle_id']?.toString() ?? user?['vehicleId']?.toString();
  static Map<String, dynamic>? get activeTrip {
    final value = _box.read('active_trip');
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  static Map<String, dynamic>? get activeDelivery {
    final value = _box.read('active_delivery');
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

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
    await _box.write('user_role', user['role']);
    await _box.write('vehicle_id', user['vehicle_id'] ?? user['vehicleId']);
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _box.write('user', user);
    await _box.write('user_id', user['id']);
    await _box.write('user_name', user['name']);
    await _box.write('user_phone', user['phone']);
    await _box.write('user_email', user['email']);
    await _box.write('user_role', user['role']);
    await _box.write('vehicle_id', user['vehicle_id'] ?? user['vehicleId']);
  }

  static Future<void> updateUser(Map<String, dynamic> fields) async {
    final current = user ?? <String, dynamic>{};
    final updated = {...current, ...fields};
    await saveUser(updated);
  }

  static Future<void> saveLastActiveRole(String role) async {
    await _box.write('last_active_role', role);
  }

  static Future<void> saveActiveTrip(Map<String, dynamic> trip) async {
    await _box.remove('active_delivery');
    await _box.write('active_trip', trip);
  }

  static Future<void> mergeActiveTrip(Map<String, dynamic> fields) async {
    await saveActiveTrip({...?activeTrip, ...fields});
  }

  static Future<void> clearActiveTrip() => _box.remove('active_trip');

  static Future<void> saveActiveDelivery(Map<String, dynamic> delivery) async {
    await _box.remove('active_trip');
    await _box.write('active_delivery', delivery);
  }

  static Future<void> mergeActiveDelivery(Map<String, dynamic> fields) async {
    await saveActiveDelivery({...?activeDelivery, ...fields});
  }

  static Future<void> clearActiveDelivery() => _box.remove('active_delivery');

  static Future<void> clearAuth() async {
    await _secureStorage.delete(key: 'auth_token');
    await _box.remove('user');
    await _box.remove('user_id');
    await _box.remove('user_name');
    await _box.remove('user_phone');
    await _box.remove('user_email');
    await _box.remove('user_role');
    await _box.remove('vehicle_id');
    await _box.remove('last_active_role');
    await clearActiveTrip();
    await clearActiveDelivery();
  }
}
