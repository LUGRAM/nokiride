import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../model/wallet_model.dart';
import '../../home/controller/home_controller.dart';
import '../../history/controller/history_controller.dart';

class WalletController extends GetxController {
  final RxInt balance = 5000.obs;
  final RxBool balanceVisible = true.obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Données initiales
    transactions.assignAll([
      TransactionModel(
        id: '1',
        label: 'Course Akanda → Charbonnages',
        amount: 1500,
        date: DateTime.now(),
        type: TransactionType.debit,
      ),
      TransactionModel(
        id: '2',
        label: 'Recharge Mobile Money',
        amount: 10000,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.credit,
        method: PaymentMethod.airtelMoney,
      ),
      TransactionModel(
        id: '3',
        label: 'Envoi colis Batterie IV',
        amount: 1200,
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: TransactionType.debit,
      ),
    ]);
  }

  void toggleVisibility() => balanceVisible.toggle();

  void recharge(int amount) {
    balance.value += amount;
    final newTx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: 'Recharge Portefeuille',
      amount: amount,
      date: DateTime.now(),
      type: TransactionType.credit,
      method: PaymentMethod.airtelMoney,
    );
    transactions.insert(0, newTx);
    Get.snackbar(
      'Recharge réussie',
      '+${NumberFormat('#,###').format(amount).replaceAll(',', ' ')} F CFA ajoutés',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void sendCredit(int amount, String recipient) {
    if (balance.value < amount) {
      Get.snackbar('Erreur', 'Solde insuffisant', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    balance.value -= amount;
    final newTx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: 'Envoi à $recipient',
      amount: amount,
      date: DateTime.now(),
      type: TransactionType.debit,
    );
    transactions.insert(0, newTx);
    Get.snackbar('Succès', 'Envoi de $amount F effectué', snackPosition: SnackPosition.BOTTOM);
  }

  String get formattedBalance {
    final s = NumberFormat('#,###').format(balance.value).replaceAll(',', ' ');
    return '$s F CFA';
  }

  // Calcul des statistiques mensuelles
  int get receivedThisMonth {
    final now = DateTime.now();
    return transactions
        .where((t) => t.type == TransactionType.credit && t.date.month == now.month && t.date.year == now.year)
        .fold(0, (sum, t) => sum + t.amount);
  }

  int get spentThisMonth {
    final now = DateTime.now();
    return transactions
        .where((t) => t.type == TransactionType.debit && t.date.month == now.month && t.date.year == now.year)
        .fold(0, (sum, t) => sum + t.amount);
  }

  String formatCurrency(int value) {
    return NumberFormat('#,###').format(value).replaceAll(',', ' ');
  }

  void goToHistory() {
    final historyController = Get.find<HistoryController>();
    historyController.mainTabIndex.value = 1; // Onglet Historique
    historyController.histTabIndex.value = 2; // Sous-onglet Transactions
    Get.find<HomeController>().changeTabIndex(1); // Page Activités
  }
}
