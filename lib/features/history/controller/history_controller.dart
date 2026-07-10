import 'package:get/get.dart';
import '../../../core/network/services/auth_api_service.dart';
import '../model/history_model.dart';
import '../../wallet/controller/wallet_controller.dart';

class HistoryController extends GetxController {
  HistoryController(this._authService);

  final AuthApiService _authService;

  // Onglets du tab principal
  final RxInt mainTabIndex = 0.obs; // 0=En cours  1=Historique
  // Sous-onglets historique
  final RxInt histTabIndex = 0.obs; // 0=Courses   1=Livraisons  2=Transactions

  // Détail sélectionné
  final Rx<HistoryModel?> selected = Rx<HistoryModel?>(null);

  final RxList<HistoryModel> tripsList = <HistoryModel>[].obs;
  final RxList<HistoryModel> deliveriesList = <HistoryModel>[].obs;
  final RxBool isLoading = false.obs;

  void selectItem(HistoryModel h) => selected.value = h;
  void clearSelected() => selected.value = null;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    try {
      final data = await _authService.stats();
      final activities = data['data']['recent_activities'] as List;

      tripsList.assignAll(activities
          .where((a) => a['type'] == 'trip')
          .map((a) => _mapToHistory(a, HistoryType.trip)));

      deliveriesList.assignAll(activities
          .where((a) => a['type'] == 'delivery')
          .map((a) => _mapToHistory(a, HistoryType.delivery)));
    } catch (_) {
      // En cas d'erreur, on garde les listes vides ou les mocks précédents
    } finally {
      isLoading.value = false;
    }
  }

  HistoryModel _mapToHistory(dynamic a, HistoryType type) {
    return HistoryModel(
      id: a['reference'] ?? '',
      title: a['title'] ?? '',
      subtitle: type == HistoryType.trip ? 'Moto-Taxi' : 'Livraison',
      formattedPrice: '${a['amount_fcfa']} F CFA',
      formattedDate: a['created_at'].toString().substring(11, 16),
      groupDate: a['created_at'].toString().substring(0, 10),
      courierName: 'Coursier NokiRide',
      courierVehicle: '',
      courierRating: 5.0,
      type: type,
      status: _mapStatus(a['status']),
    );
  }

  HistoryStatus _mapStatus(String? s) {
    return switch (s) {
      'completed' || 'delivered' => HistoryStatus.completed,
      'cancelled' => HistoryStatus.cancelled,
      _ => HistoryStatus.pending,
    };
  }

  // ─── Données mock (Fallback) ───────────────────────────────
  final trips = const [
    HistoryModel(
      id: 'TRP-001',
      title: 'Akanda → Charbonnages',
      subtitle: 'Moto-Taxi Standard',
      formattedPrice: '1 500 F CFA',
      formattedDate: '16:42',
      groupDate: '24 avril 2026',
      courierName: 'Jean-Baptiste M.',
      courierVehicle: 'Honda CB125 · LBV-4821-A',
      courierRating: 4.8,
      type: HistoryType.trip,
      status: HistoryStatus.completed,
    ),
  ];

  final deliveries = const [
    HistoryModel(
      id: 'DLV-001',
      title: 'Glass → Owendo',
      subtitle: 'Envoi colis · Moyen',
      formattedPrice: '1 850 F CFA',
      formattedDate: '10:20',
      groupDate: '24 avril 2026',
      courierName: 'Franck A.',
      courierVehicle: 'Honda XR150 · LBV-5530-E',
      courierRating: 4.5,
      type: HistoryType.delivery,
      status: HistoryStatus.completed,
    ),
  ];

  // Groupés par date
  Map<String, List<HistoryModel>> get groupedTrips {
    final map = <String, List<HistoryModel>>{};
    final list = tripsList.isEmpty ? trips : tripsList;
    for (final t in list) {
      map.putIfAbsent(t.groupDate, () => []).add(t);
    }
    return map;
  }

  Map<String, List<HistoryModel>> get groupedDeliveries {
    final map = <String, List<HistoryModel>>{};
    final list = deliveriesList.isEmpty ? deliveries : deliveriesList;
    for (final d in list) {
      map.putIfAbsent(d.groupDate, () => []).add(d);
    }
    return map;
  }

  // Conversion des transactions du Wallet en HistoryModel pour l'affichage unifié
  Map<String, List<HistoryModel>> get groupedTransactions {
    final walletController = Get.find<WalletController>();
    final map = <String, List<HistoryModel>>{};

    for (final tx in walletController.transactions) {
      final h = HistoryModel(
        id: tx.id,
        title: tx.label,
        subtitle: 'Paiement NokiPay',
        formattedPrice: tx.formattedAmount,
        formattedDate: tx.formattedDate,
        groupDate: tx
            .formattedDate, // Utilisation de formattedDate pour le groupement simple
        courierName: tx.method.name,
        courierVehicle: '',
        courierRating: 5.0,
        type: HistoryType.trip, // Dummy type
        status: HistoryStatus.completed,
      );
      map.putIfAbsent(h.groupDate, () => []).add(h);
    }
    return map;
  }
}
