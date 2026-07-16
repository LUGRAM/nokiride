import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:nokiride/core/network/api_client.dart';
import 'package:nokiride/core/storage/app_storage.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../presentation/widgets/trip_proposal_bottom_sheet.dart';

/// Point d'entrée unique du dispatch chauffeur (Reverb, FCM et reprise d'app).
class DriverSocketService extends GetxService with WidgetsBindingObserver {
  final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  final Set<String> _terminalTripIds = <String>{};

  StreamSubscription<RemoteMessage>? _foregroundFcmSubscription;
  StreamSubscription<RemoteMessage>? _openedAppFcmSubscription;
  StreamSubscription<Map<String, dynamic>?>? _backgroundAckSubscription;
  String? _channelName;
  String? _activeTripId;
  String? _activeDeliveryId;
  bool _socketInitialized = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _listenToBackgroundService();
    initFcmListeners();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _foregroundFcmSubscription?.cancel();
    _openedAppFcmSubscription?.cancel();
    _backgroundAckSubscription?.cancel();
    final channel = _channelName;
    if (channel != null) {
      pusher.unsubscribe(channelName: channel);
    }
    pusher.disconnect();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _performSyncCheck();
    }
  }

  Future<void> _performSyncCheck() async {
    try {
      final response = await ApiClient.instance.get('/driver/current-offers');
      final offers = response['data'];
      if (response['status'] == 'success' &&
          offers is List &&
          offers.isNotEmpty) {
        _handleNewTrip(Map<String, dynamic>.from(offers.first as Map));
      }
    } catch (error) {
      debugPrint('Dispatch sync error: $error');
    }
    try {
      final response =
          await ApiClient.instance.get('/driver/current-deliveries');
      final deliveries = response['data'];
      if (deliveries is List && deliveries.isNotEmpty) {
        _handleDeliveryAssigned(
          Map<String, dynamic>.from(deliveries.first as Map),
        );
      } else {
        FlutterBackgroundService().invoke('dispatchCommand', {
          'tracking_type': 'delivery',
          'state': 'clear_tracking',
        });
      }
    } catch (error) {
      debugPrint('Delivery sync error: $error');
    }
  }

  void _listenToBackgroundService() {
    _backgroundAckSubscription = FlutterBackgroundService()
        .on('dispatchStateChanged')
        .listen((event) => debugPrint('Background dispatch ack: $event'));
  }

  void _notifyBackground(String tripId, String state) {
    FlutterBackgroundService().invoke('dispatchCommand', {
      'trip_id': tripId,
      'state': state,
    });
  }

  Future<void> initSocketConnection(String driverId) async {
    final token = await AppStorage.token;
    if (token == null || token.isEmpty) return;

    final wantedChannel = 'private-driver.status.$driverId';
    if (_socketInitialized && _channelName == wantedChannel) return;

    try {
      if (_channelName != null) {
        await pusher.unsubscribe(channelName: _channelName!);
        await pusher.disconnect();
      }

      await pusher.init(
        apiKey: 'nokiride-key',
        cluster: 'mt1',
        useTLS: false,
        onEvent: _onPusherEvent,
        onAuthorizer: (channelName, socketId, options) =>
            ApiClient.instance.post('/broadcasting/auth', data: {
          'socket_id': socketId,
          'channel_name': channelName,
        }),
      );
      await pusher.connect();
      await pusher.subscribe(channelName: wantedChannel);
      _channelName = wantedChannel;
      _socketInitialized = true;
      await _performSyncCheck();
    } catch (error) {
      _socketInitialized = false;
      debugPrint('Pusher initialization error: $error');
    }
  }

  Future<void> disconnectSocket() async {
    final channel = _channelName;
    if (channel != null) await pusher.unsubscribe(channelName: channel);
    await pusher.disconnect();
    _channelName = null;
    _socketInitialized = false;
  }

  void _onPusherEvent(PusherEvent event) {
    if (event.data == null) return;
    final decoded = jsonDecode(event.data.toString());
    if (decoded is! Map) return;
    final data = Map<String, dynamic>.from(decoded);

    if (event.eventName == 'TripRequested' ||
        event.eventName == '.TripRequested') {
      _handleNewTrip(data);
    } else if (event.eventName == 'TripCancelled' ||
        event.eventName == '.TripCancelled') {
      _handleTripCancelled(data);
    } else if (event.eventName == 'DeliveryAssigned' ||
        event.eventName == '.DeliveryAssigned') {
      _handleDeliveryAssigned(data);
    } else if (event.eventName == 'DeliveryTrackingStopped' ||
        event.eventName == '.DeliveryTrackingStopped') {
      FlutterBackgroundService().invoke('dispatchCommand', {
        'delivery_id': data['delivery_id']?.toString(),
        'tracking_type': 'delivery',
        'state': data['status']?.toString() ?? 'completed',
      });
    }
  }

  void _handleDeliveryAssigned(Map<String, dynamic> data) {
    final deliveryId = (data['delivery_id'] ?? data['id'])?.toString();
    if (deliveryId == null) return;
    FlutterBackgroundService().invoke('dispatchCommand', {
      'delivery_id': deliveryId,
      'tracking_type': 'delivery',
      'state': 'accepted',
    });
    Get.snackbar(
      'Nouvelle livraison',
      'Livraison assignée : ${data['pickup_address'] ?? ''}',
    );
    if (_activeDeliveryId == deliveryId) return;
    _activeDeliveryId = deliveryId;
    final delivery = <String, dynamic>{
      ...data,
      'id': deliveryId,
      'entity_type': 'delivery',
      'dropoff_address': data['dropoff_address'] ?? data['destination_address'],
    };
    Get.toNamed('/driver/active-trip', arguments: delivery)?.whenComplete(() {
      if (_activeDeliveryId == deliveryId) _activeDeliveryId = null;
    });
  }

  void _handleNewTrip(Map<String, dynamic> data) {
    final tripId = (data['trip_id'] ?? data['id'])?.toString();
    if (tripId == null || tripId.isEmpty) return;
    if (_terminalTripIds.contains(tripId) || _activeTripId == tripId) return;
    if (_activeTripId != null || (Get.isBottomSheetOpen ?? false)) return;

    _activeTripId = tripId;
    _notifyBackground(tripId, 'presented');
    Get.bottomSheet<void>(
      TripProposalBottomSheet(
        tripData: data,
        onAccepted: (trip) => _resolveOffer(tripId, 'accepted'),
        onRejected: () => _resolveOffer(tripId, 'rejected'),
        onExpired: () => _resolveOffer(tripId, 'expired'),
      ),
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
    ).whenComplete(() {
      if (_activeTripId == tripId) _activeTripId = null;
    });
  }

  void _resolveOffer(String tripId, String state) {
    _terminalTripIds.add(tripId);
    if (_activeTripId == tripId) _activeTripId = null;
    _notifyBackground(tripId, state);
  }

  void _handleTripCancelled(Map<String, dynamic> data) {
    final tripId = (data['trip_id'] ?? data['id'])?.toString();
    if (tripId == null) return;
    _resolveOffer(tripId, 'cancelled');
    if (_activeTripId == null && (Get.isBottomSheetOpen ?? false)) {
      Get.back<void>();
      Get.snackbar(
          'Course annulée', 'Cette proposition n’est plus disponible.');
    }
  }

  void initFcmListeners() {
    _foregroundFcmSubscription ??=
        FirebaseMessaging.onMessage.listen((message) {
      if (message.data['type'] == 'NEW_TRIP') _handleNewTrip(message.data);
    });
    _openedAppFcmSubscription ??=
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data['type'] == 'NEW_TRIP') _handleNewTrip(message.data);
    });
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['type'] == 'NEW_TRIP') {
    FlutterBackgroundService().invoke('dispatchCommand', {
      'trip_id': message.data['trip_id'],
      'state': 'received_in_background',
    });
  }
}
