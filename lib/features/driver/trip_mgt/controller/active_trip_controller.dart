import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/location/background_location_service.dart';
import '../../../../core/navigation/google_routes_service.dart';
import '../../../../core/network/api_client.dart';

enum DriverTripStatus { accepted, arrived, pickedUp, completed }

class ActiveTripController extends GetxController {
  ActiveTripController({GoogleRoutesService? routesService})
      : _routesService = routesService ?? const GoogleRoutesService();

  final BackgroundLocationService _locationService =
      Get.find<BackgroundLocationService>();
  final GoogleRoutesService _routesService;

  final Rx<DriverTripStatus> currentStatus = DriverTripStatus.accepted.obs;
  final RxMap<String, dynamic> tripData = <String, dynamic>{}.obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final RxBool isRouteLoading = false.obs;
  final RxInt routeDistanceMeters = 0.obs;
  final RxInt routeDurationSeconds = 0.obs;

  GoogleMapController? mapController;
  StreamSubscription<double>? _locationSubscription;
  var _routeRequestId = 0;
  bool _hasRequestedDriverRoute = false;

  LatLng get pickup => LatLng(
        _coordinate('pickup_latitude'),
        _coordinate('pickup_longitude'),
      );

  LatLng get destination => LatLng(
        _coordinate('dropoff_latitude'),
        _coordinate('dropoff_longitude'),
      );

  LatLng? get driverPosition {
    final latitude = _locationService.latitude.value;
    final longitude = _locationService.longitude.value;
    if (latitude == 0 && longitude == 0) return null;
    return LatLng(latitude, longitude);
  }

  String get routeSummary {
    if (isRouteLoading.value) return 'Calcul de l’itinéraire…';
    if (routeDistanceMeters.value <= 0) return '';
    final distance = routeDistanceMeters.value >= 1000
        ? '${(routeDistanceMeters.value / 1000).toStringAsFixed(1)} km'
        : '${routeDistanceMeters.value} m';
    final minutes = math.max(1, (routeDurationSeconds.value / 60).ceil());
    return '$distance • $minutes min';
  }

  String get targetAddress => currentStatus.value == DriverTripStatus.pickedUp
      ? '${tripData['dropoff_address'] ?? ''}'
      : '${tripData['pickup_address'] ?? ''}';

  bool get isDelivery => tripData['entity_type'] == 'delivery';

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map) {
      tripData.value = Map<String, dynamic>.from(arguments);
    }
    _initMarkers();
    _listenToLocation();
    _drawItinerary();
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    mapController?.dispose();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fitRoute();
  }

  void recenterOnDriver() {
    final position = driverPosition;
    if (position != null) {
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
    }
  }

  void _initMarkers() {
    if (tripData.isEmpty) return;
    markers.assignAll({
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Départ'),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Arrivée'),
      ),
    });
  }

  void _listenToLocation() {
    _locationSubscription = _locationService.latitude.listen((latitude) {
      final longitude = _locationService.longitude.value;
      if (latitude == 0 && longitude == 0) return;
      _updateDriverMarker(latitude, longitude);

      if (!_hasRequestedDriverRoute &&
          currentStatus.value == DriverTripStatus.accepted) {
        _hasRequestedDriverRoute = true;
        _drawItinerary();
      }
    });
  }

  void _updateDriverMarker(double latitude, double longitude) {
    const markerId = MarkerId('driver');
    markers.removeWhere((marker) => marker.markerId == markerId);
    markers.add(
      Marker(
        markerId: markerId,
        position: LatLng(latitude, longitude),
        anchor: const Offset(0.5, 0.5),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
  }

  Future<void> _drawItinerary() async {
    if (tripData.isEmpty) return;
    final origin = currentStatus.value == DriverTripStatus.accepted
        ? driverPosition
        : pickup;
    final target =
        currentStatus.value == DriverTripStatus.accepted ? pickup : destination;

    if (origin == null) {
      _showFallbackRoute(pickup, target);
      return;
    }

    final requestId = ++_routeRequestId;
    isRouteLoading.value = true;
    try {
      final route = await _routesService.route(
        origin: origin,
        destination: target,
      );
      if (requestId != _routeRequestId || isClosed) return;

      routeDistanceMeters.value = route.distanceMeters;
      routeDurationSeconds.value = route.durationSeconds;
      polylines.assignAll({
        Polyline(
          polylineId: const PolylineId('route'),
          points: route.points,
          color: const Color(0xFF2E7D32),
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      });
      await _fitRoute();
    } catch (error) {
      if (requestId == _routeRequestId && !isClosed) {
        routeDistanceMeters.value = 0;
        routeDurationSeconds.value = 0;
        _showFallbackRoute(origin, target);
        debugPrint('Google route unavailable: $error');
      }
    } finally {
      if (requestId == _routeRequestId && !isClosed) {
        isRouteLoading.value = false;
      }
    }
  }

  void _showFallbackRoute(LatLng origin, LatLng target) {
    polylines.assignAll({
      Polyline(
        polylineId: const PolylineId('route-fallback'),
        points: [origin, target],
        color: Colors.grey,
        width: 4,
        patterns: [PatternItem.dash(18), PatternItem.gap(10)],
      ),
    });
    _fitRoute();
  }

  Future<void> _fitRoute() async {
    final controller = mapController;
    final points = polylines.expand((polyline) => polyline.points).toList();
    if (controller == null || points.isEmpty) return;

    var minLatitude = points.first.latitude;
    var maxLatitude = points.first.latitude;
    var minLongitude = points.first.longitude;
    var maxLongitude = points.first.longitude;
    for (final point in points.skip(1)) {
      minLatitude = math.min(minLatitude, point.latitude);
      maxLatitude = math.max(maxLatitude, point.latitude);
      minLongitude = math.min(minLongitude, point.longitude);
      maxLongitude = math.max(maxLongitude, point.longitude);
    }

    if (minLatitude == maxLatitude && minLongitude == maxLongitude) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 16),
      );
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLatitude, minLongitude),
          northeast: LatLng(maxLatitude, maxLongitude),
        ),
        72,
      ),
    );
  }

  double _coordinate(String key) {
    final value = double.tryParse('${tripData[key] ?? ''}');
    if (value == null) throw FormatException('Coordonnée manquante: $key');
    return value;
  }

  Future<void> nextStep() async {
    final tripId = tripData['id'];
    if (currentStatus.value == DriverTripStatus.accepted) {
      _advanceStatus();
      return;
    }
    final apiStatus = switch (currentStatus.value) {
      DriverTripStatus.arrived => 'in_progress',
      DriverTripStatus.pickedUp => isDelivery ? 'delivered' : 'completed',
      DriverTripStatus.accepted || DriverTripStatus.completed => null,
    };
    if (apiStatus == null) return;

    try {
      await Get.showOverlay<void>(
        asyncFunction: () async {
          final resource = isDelivery ? 'deliveries' : 'trips';
          await ApiClient.instance.patch(
            '/$resource/$tripId/status',
            data: {'status': apiStatus},
          );
          _locationService.updateActiveTripState(
            '$tripId',
            apiStatus,
            trackingType: isDelivery ? 'delivery' : 'trip',
          );
          _advanceStatus();
        },
        loadingWidget: const Center(child: CircularProgressIndicator()),
      );
    } catch (_) {
      Get.snackbar('Erreur', 'Impossible de mettre à jour le statut.');
    }
  }

  void _advanceStatus() {
    if (currentStatus.value == DriverTripStatus.accepted) {
      currentStatus.value = DriverTripStatus.arrived;
    } else if (currentStatus.value == DriverTripStatus.arrived) {
      currentStatus.value = DriverTripStatus.pickedUp;
      _drawItinerary();
    } else if (currentStatus.value == DriverTripStatus.pickedUp) {
      currentStatus.value = DriverTripStatus.completed;
      Get.offAllNamed('/driver/dashboard');
      Get.snackbar('Félicitations', 'Course terminée avec succès !');
    }
  }

  String get actionButtonText => switch (currentStatus.value) {
        DriverTripStatus.accepted => 'JE SUIS ARRIVÉ',
        DriverTripStatus.arrived =>
          isDelivery ? 'COLIS RÉCUPÉRÉ' : 'CLIENT RÉCUPÉRÉ',
        DriverTripStatus.pickedUp =>
          isDelivery ? 'LIVRAISON EFFECTUÉE' : 'TERMINER LA COURSE',
        DriverTripStatus.completed => 'TERMINÉ',
      };

  String get instructionText => switch (currentStatus.value) {
        DriverTripStatus.accepted =>
          isDelivery ? 'Allez récupérer le colis' : 'Allez chercher le client',
        DriverTripStatus.arrived =>
          isDelivery ? 'Le colis vous attend' : 'Le client vous attend',
        DriverTripStatus.pickedUp => 'En route vers la destination',
        DriverTripStatus.completed => 'Course terminée',
      };
}
