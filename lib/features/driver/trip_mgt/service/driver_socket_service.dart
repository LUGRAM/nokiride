import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:nokiride/core/network/api_client.dart';
import 'package:nokiride/core/storage/app_storage.dart';
import '../presentation/widgets/trip_proposal_bottom_sheet.dart';

/// Service de communication temps réel pour les chauffeurs.
/// Gère la réception des courses via Pusher Channels (Laravel Reverb) et FCM.
class DriverSocketService extends GetxService with WidgetsBindingObserver {
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _listenToServiceUpdates();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
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
      if (response['status'] == 'success' && response['data'] != null) {
        final List offers = response['data'];
        if (offers.isNotEmpty && !(Get.isBottomSheetOpen ?? false)) {
          _handleNewTrip(offers.first);
        }
      }
    } catch (e) {
      debugPrint("Sync Check Error: $e");
    }
  }

  void _listenToServiceUpdates() {
    // ... existant
  }

  /// Initialise la connexion Pusher pour Laravel Reverb
  Future<void> initSocketConnection(String driverId) async {
    final token = await AppStorage.token;
    if (token == null) return;

    try {
      await pusher.init(
        apiKey: "nokiride-key",
        cluster: "mt1",
        useTLS: false,
        onEvent: (PusherEvent event) {
          _onPusherEvent(event);
        },
        onAuthorizer: (channelName, socketId, options) async {
          final authResponse = await ApiClient.instance.post(
            "/broadcasting/auth",
            data: {
              "socket_id": socketId,
              "channel_name": channelName,
            },
          );
          return authResponse;
        },
      );

      // Si ton plugin ne permet pas de régler le host en Dart, 
      // il faudra peut-être repasser sur pusher_client ou configurer le native.

      await pusher.subscribe(channelName: "private-driver.status.$driverId");
      await pusher.connect();
      
      debugPrint('Pusher Connected: Subscribed to private-driver.status.$driverId');
    } catch (e) {
      debugPrint("Pusher Initialization Error: $e");
    }
  }

  void _onPusherEvent(PusherEvent event) {
    if (event.data == null) return;
    final Map<String, dynamic> data = jsonDecode(event.data.toString());

    if (event.eventName == 'TripRequested') {
      _handleNewTrip(data);
    } else if (event.eventName == 'TripCancelled') {
      _handleTripCancelled(data);
    }
  }

  void _handleNewTrip(Map<String, dynamic>? data) {
    if (data == null) return;
    Get.bottomSheet(
      TripProposalBottomSheet(tripData: data),
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  void _handleTripCancelled(Map<String, dynamic>? data) {
    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
      Get.snackbar(
        "Course annulée",
        "La demande a été annulée par le passager ou a expiré.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        icon: const Icon(Icons.info_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> initFcmListeners() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == 'NEW_TRIP') {}
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['type'] == 'NEW_TRIP') {}
    });
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['type'] == 'NEW_TRIP') {
    debugPrint("Background Trip Received: ${message.data['trip_id']}");
  }
}
