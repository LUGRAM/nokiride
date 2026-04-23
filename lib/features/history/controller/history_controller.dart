import 'package:get/get.dart';
import '../model/history_model.dart';

class HistoryController extends GetxController {
  final RxInt filterIndex = 0.obs; // 0=Tous 1=Courses 2=Livraisons
  final filters = ["Tous", "Courses", "Livraisons"];

  final _allHistory = [
    const HistoryModel(id:'1', title:'Akanda → Charbonnages', subtitle:'Moto-Taxi Standard', formattedPrice:'1 500 F CFA', formattedDate:"Aujourd'hui, 16:42", type: HistoryType.trip, status: HistoryStatus.completed),
    const HistoryModel(id:'2', title:'Batterie IV → Glass', subtitle:'Envoi colis · Petit', formattedPrice:'1 200 F CFA', formattedDate:'Hier, 09:15', type: HistoryType.delivery, status: HistoryStatus.completed),
    const HistoryModel(id:'3', title:'Nzeng-Ayong → Centre-Ville', subtitle:'Moto-Taxi Standard', formattedPrice:'2 000 F CFA', formattedDate:'22 avr.', type: HistoryType.trip, status: HistoryStatus.cancelled),
    const HistoryModel(id:'4', title:'Louis → Owendo', subtitle:'Envoi colis · Moyen', formattedPrice:'1 850 F CFA', formattedDate:'20 avr.', type: HistoryType.delivery, status: HistoryStatus.completed),
    const HistoryModel(id:'5', title:'Akanda → PK5', subtitle:'Moto-Taxi Standard', formattedPrice:'2 500 F CFA', formattedDate:'18 avr.', type: HistoryType.trip, status: HistoryStatus.completed),
    const HistoryModel(id:'6', title:'Angondjé → Marché Mont-Bouët', subtitle:'Envoi colis · Grand', formattedPrice:'2 300 F CFA', formattedDate:'15 avr.', type: HistoryType.delivery, status: HistoryStatus.completed),
  ];

  List<HistoryModel> get filtered {
    if (filterIndex.value == 0) return _allHistory;
    if (filterIndex.value == 1) return _allHistory.where((h) => h.type == HistoryType.trip).toList();
    return _allHistory.where((h) => h.type == HistoryType.delivery).toList();
  }

  void setFilter(int i) => filterIndex.value = i;
}
