import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/storage/app_storage.dart';
import '../../../client/trip/model/place_model.dart';

class DriverDashboardController extends GetxController {
  final RxInt tabIndex = 0.obs;
  final RxBool isOnline = false.obs;
  final Rx<PlaceModel?> currentLocation = Rx<PlaceModel?>(null);
  final RxDouble todayRevenue = 0.0.obs;
  final RxInt completedTrips = 0.obs;
  final Rx<Duration> onlineDuration = Duration.zero.obs;

  StreamSubscription<Position>? _positionSub;
  Timer? _onlineTimer;
  DateTime? _onlineStartedAt;

  UserModel get user => UserModel.fromJson(AppStorage.user ?? {});
  bool get hasVehicle => user.vehicleId != null && user.vehicleId!.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentLocation();
    _positionSub = LocationService.positionStream.listen((position) {
      currentLocation.value = PlaceModel(
        name: 'Position chauffeur',
        address: 'Position GPS actuelle',
        lat: position.latitude,
        lng: position.longitude,
      );
    });

    Future<void>.delayed(Duration.zero, _requireVehicleIfMissing);
  }

  Future<void> _loadCurrentLocation() async {
    final position = await LocationService.currentPosition();
    if (position == null) return;
    currentLocation.value = PlaceModel(
      name: 'Position chauffeur',
      address: 'Position GPS actuelle',
      lat: position.latitude,
      lng: position.longitude,
    );
  }

  void _requireVehicleIfMissing() {
    // Désactivé pour le moment
    // if (hasVehicle) return;
    // Get.offNamed(Routes.driverVehicleRegistration);
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  Future<void> toggleOnline(bool value) async {
    // Check véhicule désactivé temporairement
    /*
    if (value && !hasVehicle) {
       Get.snackbar('Véhicule requis', ...);
       return;
    }
    */

    isOnline.value = value;
    await AppStorage.updateUser({'is_online': value});

    if (value) {
      _onlineStartedAt = DateTime.now();
      _onlineTimer?.cancel();
      _onlineTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final start = _onlineStartedAt;
        if (start != null) {
          onlineDuration.value = DateTime.now().difference(start);
        }
      });
    } else {
      _onlineTimer?.cancel();
      _onlineStartedAt = null;
    }
  }

  String get formattedOnlineDuration {
    final duration = onlineDuration.value;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}min';
  }

  @override
  void onClose() {
    _positionSub?.cancel();
    _onlineTimer?.cancel();
    super.onClose();
  }
}
