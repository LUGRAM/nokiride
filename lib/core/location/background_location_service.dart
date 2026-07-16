import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../network/api_client.dart';
import '../storage/app_storage.dart';

class BackgroundLocationService extends GetxService {
  static const String notificationChannelId = 'nokiride_foreground';
  static const int notificationId = 888;

  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxBool isServiceRunning = false.obs;
  StreamSubscription<Map<String, dynamic>?>? _serviceUpdateSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToServiceUpdates();
  }

  Future<void> initService() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      'NokiRide Location Service',
      description: 'Suivi GPS pour le dispatch des courses.',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'NokiRide Chauffeur',
        initialNotificationContent: 'Suivi de position actif',
        foregroundServiceNotificationId: notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  Future<void> startLocationTracking({required bool dataSaverEnabled}) async {
    final service = FlutterBackgroundService();
    if (!(await service.isRunning())) {
      await service.startService();
    }
    service.invoke("setSettings", {"dataSaverEnabled": dataSaverEnabled});
    isServiceRunning.value = true;
  }

  void stopLocationTracking() {
    final service = FlutterBackgroundService();
    service.invoke("stopService");
    isServiceRunning.value = false;
  }

  void updateActiveTripState(
    String entityId,
    String state, {
    String trackingType = 'trip',
  }) {
    FlutterBackgroundService().invoke('dispatchCommand', {
      trackingType == 'delivery' ? 'delivery_id' : 'trip_id': entityId,
      'tracking_type': trackingType,
      'state': state,
    });
  }

  void _listenToServiceUpdates() {
    _serviceUpdateSubscription?.cancel();
    _serviceUpdateSubscription =
        FlutterBackgroundService().on('update').listen((event) {
      if (event != null) {
        latitude.value = event['latitude'];
        longitude.value = event['longitude'];
      }
    });
  }

  @override
  void onClose() {
    _serviceUpdateSubscription?.cancel();
    super.onClose();
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  await GetStorage.init();
  final storage = GetStorage();

  bool dataSaver = false;
  StreamSubscription<Position>? positionStream;
  final storedBuffer = storage.read<List<dynamic>>('gps_location_buffer');
  List<Map<String, dynamic>> locationBuffer = storedBuffer
          ?.whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList() ??
      <Map<String, dynamic>>[];
  String? activeEntityId = storage.read('gps_active_entity_id')?.toString();
  String activeTrackingType =
      storage.read('gps_tracking_type')?.toString() ?? 'trip';

  if (service is AndroidServiceInstance) {
    service
        .on('setAsForeground')
        .listen((event) => service.setAsForegroundService());
    service
        .on('setAsBackground')
        .listen((event) => service.setAsBackgroundService());
  }

  late final StreamSubscription<Map<String, dynamic>?> dispatchSubscription;
  dispatchSubscription = service.on('dispatchCommand').listen((event) async {
    final tripId = event?['trip_id']?.toString();
    final deliveryId = event?['delivery_id']?.toString();
    final entityId = deliveryId ?? tripId;
    final trackingType = deliveryId != null
        ? 'delivery'
        : event?['tracking_type']?.toString() ?? 'trip';
    final state = event?['state']?.toString();
    if (state == 'clear_tracking' && activeTrackingType == trackingType) {
      activeEntityId = null;
      locationBuffer.clear();
      await storage.remove('gps_active_entity_id');
      await storage.remove('gps_tracking_type');
      await storage.remove('gps_location_buffer');
      return;
    }
    if (entityId == null || state == null) return;

    if (state == 'accepted' || state == 'in_progress') {
      if (activeEntityId != entityId || activeTrackingType != trackingType) {
        locationBuffer.clear();
        await storage.remove('gps_location_buffer');
      }
      activeEntityId = entityId;
      activeTrackingType = trackingType;
      await storage.write('gps_active_entity_id', entityId);
      await storage.write('gps_tracking_type', trackingType);
    } else if (state == 'rejected' ||
        state == 'expired' ||
        state == 'cancelled' ||
        state == 'completed') {
      if (activeEntityId == entityId && activeTrackingType == trackingType) {
        activeEntityId = null;
        locationBuffer.clear();
        await storage.remove('gps_active_entity_id');
        await storage.remove('gps_tracking_type');
        await storage.remove('gps_location_buffer');
      }
    }
    service.invoke('dispatchStateChanged', {
      'trip_id': tripId,
      'delivery_id': deliveryId,
      'state': state,
      'active_entity_id': activeEntityId,
      'tracking_type': activeTrackingType,
    });
  });

  service.on('stopService').listen((event) async {
    await positionStream?.cancel();
    await dispatchSubscription.cancel();
    service.stopSelf();
  });

  service.on('setSettings').listen((event) async {
    dataSaver = event?['dataSaverEnabled'] ?? false;
    await positionStream?.cancel();
    _setupLocationStream(
      service,
      dataSaver,
      (stream) => positionStream = stream,
      locationBuffer,
      () => activeEntityId,
      () => activeTrackingType,
      storage,
    );
  });

  _setupLocationStream(
    service,
    dataSaver,
    (stream) => positionStream = stream,
    locationBuffer,
    () => activeEntityId,
    () => activeTrackingType,
    storage,
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

void _setupLocationStream(
    ServiceInstance service,
    bool dataSaver,
    Function(StreamSubscription<Position>) onStreamCreated,
    List<Map<String, dynamic>> buffer,
    String? Function() activeEntityId,
    String Function() activeTrackingType,
    GetStorage storage) async {
  final LocationSettings locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: dataSaver ? 15 : 5,
    intervalDuration: Duration(seconds: dataSaver ? 30 : 10),
    foregroundNotificationConfig: const ForegroundNotificationConfig(
      notificationText: "NokiRide est prêt pour vos prochaines courses",
      notificationTitle: "Mode Chauffeur Actif",
      enableWakeLock: true,
    ),
  );

  final stream =
      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) async {
    final locationData = {
      "position_id":
          '${position.timestamp.microsecondsSinceEpoch}_${position.latitude}_${position.longitude}',
      "latitude": position.latitude,
      "longitude": position.longitude,
      "heading": position.heading,
      "speed": position.speed,
      "accuracy": position.accuracy,
      "recorded_at": position.timestamp.toUtc().toIso8601String(),
    };

    // 1. Update UI
    service.invoke('update', {
      "latitude": position.latitude,
      "longitude": position.longitude,
    });

    final entityId = activeEntityId();
    if (entityId == null) return;

    // 2. Add to the active trip buffer.
    buffer.add(locationData);
    if (buffer.length > 50) buffer.removeAt(0);
    await storage.write('gps_location_buffer', buffer);

    // 3. Try sending buffer
    try {
      final token = await AppStorage.token;
      if (token != null) {
        final response = await ApiClient.instance.post(
          '/driver/update-location',
          retryable: true,
          data: {
            activeTrackingType() == 'delivery' ? 'delivery_id' : 'trip_id':
                int.tryParse(entityId) ?? entityId,
            "locations": List<Map<String, dynamic>>.from(buffer),
          },
        );

        if (response['status'] == 'success') {
          buffer.clear();
          await storage.remove('gps_location_buffer');
        }
      }
    } catch (e) {
      debugPrint(
          "Sync Error: Background location buffered (${buffer.length} items)");
    }
  });

  onStreamCreated(stream);
}
