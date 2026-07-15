import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/services/trip_api_service.dart';
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

  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    refreshWeeklyRevenue();
  }

  Future<void> refreshWeeklyRevenue() async {
    weeklyRevenue.value = await _historyService.weeklyRevenue();
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
    _countdownTimer?.cancel();
    activeRequest.value = null;
    if (stage.value == DriverTripStage.requestReceived) {
      stage.value = DriverTripStage.idle;
    }
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }
}
