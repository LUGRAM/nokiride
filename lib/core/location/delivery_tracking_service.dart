import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../features/client/trip/model/place_model.dart';
import '../network/api_client.dart';
import '../storage/app_storage.dart';

class DeliveryTrackingUpdate {
  const DeliveryTrackingUpdate({
    required this.position,
    required this.deliveryStatus,
  });

  final PlaceModel position;
  final String deliveryStatus;
}

class DeliveryTrackingService {
  DeliveryTrackingService({PusherChannelsFlutter? pusher})
      : _pusher = pusher ?? PusherChannelsFlutter.getInstance();

  final PusherChannelsFlutter _pusher;
  final StreamController<DeliveryTrackingUpdate> _updates =
      StreamController<DeliveryTrackingUpdate>.broadcast();
  String? _channelName;
  bool _initialized = false;

  Stream<DeliveryTrackingUpdate> get updates => _updates.stream;

  Future<void> subscribe(String deliveryId) async {
    final channel = 'private-delivery.$deliveryId';
    if (_channelName == channel) return;
    await unsubscribe();
    if ((await AppStorage.token)?.isEmpty ?? true) {
      throw StateError('Authentification requise pour suivre la livraison.');
    }
    if (!_initialized) {
      await _pusher.init(
        apiKey: 'nokiride-key',
        cluster: 'mt1',
        useTLS: false,
        onEvent: _onEvent,
        onAuthorizer: (channelName, socketId, options) =>
            ApiClient.instance.post('/broadcasting/auth', data: {
          'socket_id': socketId,
          'channel_name': channelName,
        }),
      );
      _initialized = true;
    }
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await _pusher.connect();
        await _pusher.subscribe(channelName: channel);
        _channelName = channel;
        return;
      } catch (error) {
        lastError = error;
        if (attempt < 2) {
          await Future<void>.delayed(Duration(milliseconds: 500 << attempt));
        }
      }
    }
    throw StateError('Connexion au suivi impossible: $lastError');
  }

  void _onEvent(PusherEvent event) {
    if (event.eventName != 'DeliveryLocationUpdated' &&
        event.eventName != '.DeliveryLocationUpdated') {
      return;
    }
    try {
      final decoded =
          event.data is String ? jsonDecode(event.data as String) : event.data;
      if (decoded is! Map) return;
      final data = Map<String, dynamic>.from(decoded);
      final latitude = double.tryParse('${data['latitude']}');
      final longitude = double.tryParse('${data['longitude']}');
      if (latitude == null || longitude == null) return;
      _updates.add(DeliveryTrackingUpdate(
        deliveryStatus: data['delivery_status']?.toString() ?? 'assigned',
        position: PlaceModel(
          name: 'Coursier',
          address: 'Position GPS en temps réel',
          lat: latitude,
          lng: longitude,
        ),
      ));
    } catch (error) {
      debugPrint('Invalid delivery location event: $error');
    }
  }

  Future<void> unsubscribe() async {
    final channel = _channelName;
    if (channel != null) {
      await _pusher.unsubscribe(channelName: channel);
      _channelName = null;
    }
  }

  Future<void> dispose() async {
    await unsubscribe();
    await _updates.close();
  }
}
