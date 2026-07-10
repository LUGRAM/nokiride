import 'package:get_storage/get_storage.dart';

import '../model/driver_earning_model.dart';

class DriverHistoryService {
  DriverHistoryService({GetStorage? storage})
      : _storage = storage ?? GetStorage();

  static const _key = 'driver_completed_trips';
  final GetStorage _storage;

  Future<List<DriverEarningModel>> completedTrips() async {
    final raw = _storage.read(_key);
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => DriverEarningModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addCompletedTrip(DriverEarningModel earning) async {
    final current = await completedTrips();
    final updated =
        [earning, ...current].fold<List<DriverEarningModel>>([], (items, item) {
      if (items.any((existing) => existing.tripId == item.tripId)) {
        return items;
      }
      return [...items, item];
    });
    await _storage.write(
      _key,
      updated.map((item) => item.toJson()).toList(),
    );
  }

  Future<int> weeklyRevenue() async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final trips = await completedTrips();
    return trips
        .where((trip) => !trip.date.isBefore(
              DateTime(start.year, start.month, start.day),
            ))
        .fold<int>(0, (sum, trip) => sum + trip.netAmountFCFA);
  }
}
