import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/services/trip_api_service.dart';
import '../../../client/trip/model/place_model.dart';
import '../../dashboard/controller/driver_dashboard_controller.dart';
import '../../earnings/model/driver_earning_model.dart';
import '../../earnings/service/driver_history_service.dart';
import '../model/driver_trip_request.dart';

class DriverTripController extends GetxController {
  DriverTripController(
    this._tripService,
    this._historyService,
    this._dashboardController,
  );

  final TripApiService _tripService;
  final DriverHistoryService _historyService;
  final DriverDashboardController _dashboardController;

  final Rx<DriverTripRequest?> activeRequest = Rx<DriverTripRequest?>(null);
  final Rx<DriverTripRequest?> currentTrip = Rx<DriverTripRequest?>(null);
  final Rx<DriverTripStage> stage = DriverTripStage.idle.obs;
  final RxInt requestCountdown = 15.obs;
  final RxInt weeklyRevenue = 0.obs;

  Timer? _requestTimer;
  Timer? _countdownTimer;
  Worker? _onlineWorker;

  @override
  void onInit() {
    super.onInit();
    refreshWeeklyRevenue();
    _onlineWorker = ever<bool>(_dashboardController.isOnline, (isOnline) {
      if (isOnline) {
        _scheduleMockRequest();
      } else {
        _clearPendingRequest();
      }
    });
    if (_dashboardController.isOnline.value) {
      _scheduleMockRequest();
    }
  }

  Future<void> refreshWeeklyRevenue() async {
    weeklyRevenue.value = await _historyService.weeklyRevenue();
  }

  void _scheduleMockRequest() {
    _requestTimer?.cancel();
    if (activeRequest.value != null || currentTrip.value != null) return;
    _requestTimer = Timer(const Duration(seconds: 5), _emitMockRequest);
  }

  void _emitMockRequest() {
    if (!_dashboardController.isOnline.value || currentTrip.value != null) {
      return;
    }

    final pickup = _dashboardController.currentLocation.value ??
        const PlaceModel(
          name: 'Akanda',
          address: 'Quartier Akanda, Libreville',
          lat: 0.4477,
          lng: 9.4321,
        );
    final dropoff = const PlaceModel(
      name: 'Batterie IV',
      address: 'Batterie IV, Libreville',
      lat: 0.3812,
      lng: 9.4502,
    );
    final distance = max(2.5, pickup.distanceTo(dropoff));
    activeRequest.value = DriverTripRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      passengerName: 'Enzo Mezui',
      pickup: pickup,
      dropoff: dropoff,
      distanceKm: distance,
      priceFCFA: ((900 + distance * 260) / 50).round() * 50,
    );
    stage.value = DriverTripStage.requestReceived;
    _startCountdown();
  }

  void _startCountdown() {
    requestCountdown.value = 15;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (requestCountdown.value <= 1) {
        rejectRequest();
      } else {
        requestCountdown.value--;
      }
    });
  }

  void acceptRequest() {
    final request = activeRequest.value;
    if (request == null) return;
    _countdownTimer?.cancel();
    activeRequest.value = null;
    currentTrip.value = request;
    stage.value = DriverTripStage.goingToPickup;
    _syncTripStatus('assigned');
  }

  void rejectRequest() {
    _clearPendingRequest();
    if (_dashboardController.isOnline.value) {
      _scheduleMockRequest();
    }
  }

  void markArrivedAtPickup() {
    if (currentTrip.value == null) return;
    stage.value = DriverTripStage.arrivedAtPickup;
  }

  void startTrip() {
    if (currentTrip.value == null) return;
    stage.value = DriverTripStage.inProgress;
    _syncTripStatus('in_progress');
  }

  Future<void> completeTrip() async {
    final trip = currentTrip.value;
    if (trip == null) return;
    stage.value = DriverTripStage.completed;
    await _syncTripStatus('completed');
    await _historyService.addCompletedTrip(
      DriverEarningModel(
        tripId: trip.id,
        date: DateTime.now(),
        amountFCFA: trip.priceFCFA,
        distanceKm: trip.distanceKm,
      ),
    );
    _dashboardController.todayRevenue.value += (trip.priceFCFA * 0.85).round();
    _dashboardController.completedTrips.value++;
    await refreshWeeklyRevenue();
    currentTrip.value = null;
    stage.value = DriverTripStage.idle;
    if (_dashboardController.isOnline.value) {
      _scheduleMockRequest();
    }
  }

  Future<void> _syncTripStatus(String status) async {
    final id = int.tryParse(currentTrip.value?.id ?? '');
    if (id == null) return;
    try {
      await _tripService.updateStatus(id, status);
    } on ApiException catch (error) {
      Get.snackbar('Synchronisation course', error.message,
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      // Le flux mock reste utilisable hors ligne.
    }
  }

  void _clearPendingRequest() {
    _requestTimer?.cancel();
    _countdownTimer?.cancel();
    activeRequest.value = null;
    if (stage.value == DriverTripStage.requestReceived) {
      stage.value = DriverTripStage.idle;
    }
  }

  @override
  void onClose() {
    _requestTimer?.cancel();
    _countdownTimer?.cancel();
    _onlineWorker?.dispose();
    super.onClose();
  }
}
