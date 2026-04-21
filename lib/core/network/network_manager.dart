// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Observe l'état de la connexion réseau et expose
/// un [RxBool] isConnected accessible globalement via GetX.
/*
class NetworkManager extends GetxService {
  final _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  final Rx<ConnectivityResult> connectionType = ConnectivityResult.none.obs;

  @override
  void onInit() {
    super.onInit();
    _checkCurrent();
    _connectivity.onConnectivityChanged.listen(_onChanged);
  }

  Future<void> _checkCurrent() async {
    final result = await _connectivity.checkConnectivity();
    _onChanged(result);
  }

  void _onChanged(ConnectivityResult result) {
    connectionType.value = result;
    isConnected.value = result != ConnectivityResult.none;

    if (!isConnected.value) {
      Get.snackbar(
        'Hors ligne',
        'Vérifiez votre connexion internet',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
  }

  bool get hasConnection => isConnected.value;
}
*/