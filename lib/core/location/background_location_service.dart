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

  bool dataSaver = false;
  StreamSubscription<Position>? positionStream;
  List<Map<String, dynamic>> locationBuffer = [];
  String? activeDispatchId;

  if (service is AndroidServiceInstance) {
    service
        .on('setAsForeground')
        .listen((event) => service.setAsForegroundService());
    service
        .on('setAsBackground')
        .listen((event) => service.setAsBackgroundService());
  }

  late final StreamSubscription<Map<String, dynamic>?> dispatchSubscription;
  dispatchSubscription = service.on('dispatchCommand').listen((event) {
    final tripId = event?['trip_id']?.toString();
    final state = event?['state']?.toString();
    if (tripId == null || state == null) return;

    activeDispatchId = state == 'presented' || state == 'received_in_background'
        ? tripId
        : activeDispatchId == tripId
            ? null
            : activeDispatchId;
    service.invoke('dispatchStateChanged', {
      'trip_id': tripId,
      'state': state,
      'active_trip_id': activeDispatchId,
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
    );
  });

  _setupLocationStream(
      service, dataSaver, (stream) => positionStream = stream, locationBuffer);
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

void _setupLocationStream(
    ServiceInstance service,
    bool dataSaver,
    Function(StreamSubscription<Position>) onStreamCreated,
    List<Map<String, dynamic>> buffer) async {
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
      "latitude": position.latitude,
      "longitude": position.longitude,
      "heading": position.heading,
      "speed": position.speed,
      "timestamp": DateTime.now().toIso8601String(),
    };

    // 1. Update UI
    service.invoke('update', {
      "latitude": position.latitude,
      "longitude": position.longitude,
    });

    // 2. Add to buffer
    buffer.add(locationData);
    if (buffer.length > 10) buffer.removeAt(0); // Keep memory safe

    // 3. Try sending buffer
    try {
      final token = await AppStorage.token;
      if (token != null) {
        final response =
            await ApiClient.instance.post('/driver/update-location', data: {
          "locations": buffer, // We send the whole buffer
        });

        if (response['status'] == 'success') {
          buffer.clear(); // Success!
        }
      }
    } catch (e) {
      debugPrint(
          "Sync Error: Background location buffered (${buffer.length} items)");
    }
  });

  onStreamCreated(stream);
}
