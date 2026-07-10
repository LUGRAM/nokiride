import 'package:get/get.dart';
import '../../../../core/location/place_provider.dart';
import '../../../../core/network/services/delivery_api_service.dart';
import '../../trip/model/place_model.dart';
import '../controller/delivery_controller.dart';

class DeliveryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryApiService>(() => DeliveryApiService(), fenix: true);
    Get.lazyPut<PlaceProvider>(
      () => FallbackPlaceProvider(
        primary: BackendPlaceProvider(),
        fallback: const MockPlaceProvider(_fallbackPlaces),
      ),
      fenix: true,
    );
    Get.lazyPut<DeliveryController>(
      () => DeliveryController(Get.find(), Get.find()),
      fenix: true,
    );
  }
}

const _fallbackPlaces = [
  PlaceModel(
      name: 'Akanda',
      address: 'Quartier Akanda, Libreville',
      lat: 0.4477,
      lng: 9.4321),
  PlaceModel(
      name: 'Charbonnages',
      address: 'Quartier Charbonnages, Libreville',
      lat: 0.3875,
      lng: 9.4523),
  PlaceModel(
      name: 'Batterie IV',
      address: 'Batterie IV, Libreville',
      lat: 0.3812,
      lng: 9.4502),
  PlaceModel(
      name: 'Nzeng-Ayong',
      address: 'Nzeng-Ayong, Libreville',
      lat: 0.3761,
      lng: 9.4689),
  PlaceModel(
      name: 'Glass',
      address: 'Quartier Glass, Libreville',
      lat: 0.3906,
      lng: 9.4441),
  PlaceModel(
      name: 'Louis',
      address: 'Quartier Louis, Libreville',
      lat: 0.3847,
      lng: 9.4378),
  PlaceModel(
      name: 'Owendo', address: 'Owendo, Libreville', lat: 0.3021, lng: 9.5012),
  PlaceModel(
      name: 'Centre-Ville',
      address: 'Centre-Ville, Libreville',
      lat: 0.3934,
      lng: 9.4567),
];
