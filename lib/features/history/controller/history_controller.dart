import 'package:get/get.dart';
import '../model/history_model.dart';

class HistoryController extends GetxController {

  // Onglets du tab principal
  final RxInt mainTabIndex = 0.obs; // 0=En cours  1=Historique
  // Sous-onglets historique
  final RxInt histTabIndex = 0.obs; // 0=Courses   1=Livraisons

  // Détail sélectionné
  final Rx<HistoryModel?> selected = Rx<HistoryModel?>(null);

  void selectItem(HistoryModel h) => selected.value = h;
  void clearSelected() => selected.value = null;

  // ─── Données mock ──────────────────────────────────────────
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
    HistoryModel(
      id: 'TRP-002',
      title: 'Batterie IV → Louis',
      subtitle: 'Moto-Taxi Standard',
      formattedPrice: '1 200 F CFA',
      formattedDate: '09:15',
      groupDate: '23 avril 2026',
      courierName: 'Marc-Aurèle N.',
      courierVehicle: 'Yamaha XR125 · LBV-3315-B',
      courierRating: 4.9,
      type: HistoryType.trip,
      status: HistoryStatus.cancelled,
    ),
    HistoryModel(
      id: 'TRP-003',
      title: 'Nzeng-Ayong → Centre-Ville',
      subtitle: 'Moto-Taxi Standard',
      formattedPrice: '2 000 F CFA',
      formattedDate: '14:30',
      groupDate: '22 avril 2026',
      courierName: 'Rodrigue K.',
      courierVehicle: 'Suzuki GN125 · LBV-1120-C',
      courierRating: 4.6,
      type: HistoryType.trip,
      status: HistoryStatus.completed,
    ),
    HistoryModel(
      id: 'TRP-004',
      title: 'Angondjé → Marché Mont-Bouët',
      subtitle: 'Moto-Taxi Standard',
      formattedPrice: '2 500 F CFA',
      formattedDate: '11:05',
      groupDate: '20 avril 2026',
      courierName: 'Patrick O.',
      courierVehicle: 'Honda CG150 · LBV-9902-D',
      courierRating: 4.7,
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
    HistoryModel(
      id: 'DLV-002',
      title: 'Akanda → PK5',
      subtitle: 'Envoi colis · Petit',
      formattedPrice: '1 000 F CFA',
      formattedDate: '17:55',
      groupDate: '21 avril 2026',
      courierName: 'Guy-Noël B.',
      courierVehicle: 'Yamaha R125 · LBV-7741-F',
      courierRating: 4.3,
      type: HistoryType.delivery,
      status: HistoryStatus.cancelled,
    ),
  ];

  // Groupés par date
  Map<String, List<HistoryModel>> get groupedTrips {
    final map = <String, List<HistoryModel>>{};
    for (final t in trips) {
      map.putIfAbsent(t.groupDate, () => []).add(t);
    }
    return map;
  }

  Map<String, List<HistoryModel>> get groupedDeliveries {
    final map = <String, List<HistoryModel>>{};
    for (final d in deliveries) {
      map.putIfAbsent(d.groupDate, () => []).add(d);
    }
    return map;
  }
}