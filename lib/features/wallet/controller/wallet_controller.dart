import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/services/wallet_api_service.dart';
import '../model/wallet_model.dart';
import '../../home/controller/home_controller.dart';
import '../../history/controller/history_controller.dart';

class WalletController extends GetxController {
  WalletController(this._walletService);

  final WalletApiService _walletService;
  final RxInt balance = 5000.obs;
  final RxBool balanceVisible = true.obs;
  final RxBool isLoading = false.obs;
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
    loadWallet();
  }

  void toggleVisibility() => balanceVisible.toggle();

  Future<void> loadWallet() async {
    isLoading.value = true;
    try {
      final data = await _walletService.show();
      balance.value = int.tryParse('${data['balance_fcfa'] ?? 0}') ?? 0;
      transactions.assignAll(
        (data['transactions'] as List).map(
          (item) =>
              _transactionFromJson(Map<String, dynamic>.from(item as Map)),
        ),
      );
    } catch (_) {
      // Les données locales restent affichées en mode hors ligne.
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> recharge(int amount) async {
    isLoading.value = true;
    try {
      final data = await _walletService.requestRecharge(amount, 'airtel_money');
      balance.value =
          int.tryParse('${data['balance_fcfa'] ?? balance.value}') ??
              balance.value;
      transactions.insert(
        0,
        _transactionFromJson(
            Map<String, dynamic>.from(data['transaction'] as Map)),
      );
      Get.snackbar(
        'Recharge réussie',
        '+${NumberFormat('#,###').format(amount).replaceAll(',', ' ')} F CFA ajoutés',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ApiException catch (error) {
      Get.snackbar('Erreur', error.message,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void sendCredit(int amount, String recipient) {
    if (balance.value < amount) {
      Get.snackbar('Erreur', 'Solde insuffisant',
          snackPosition: SnackPosition.BOTTOM);
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
    Get.snackbar('Succès', 'Envoi de $amount F effectué',
        snackPosition: SnackPosition.BOTTOM);
  }

  String get formattedBalance {
    final s = NumberFormat('#,###').format(balance.value).replaceAll(',', ' ');
    return '$s F CFA';
  }

  // Calcul des statistiques mensuelles
  int get receivedThisMonth {
    final now = DateTime.now();
    return transactions
        .where((t) =>
            t.type == TransactionType.credit &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0, (sum, t) => sum + t.amount);
  }

  int get spentThisMonth {
    final now = DateTime.now();
    return transactions
        .where((t) =>
            t.type == TransactionType.debit &&
            t.date.month == now.month &&
            t.date.year == now.year)
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

  TransactionModel _transactionFromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: '${json['id']}',
      label: json['label'] ?? '',
      amount:
          int.tryParse('${json['amount_fcfa'] ?? json['amount'] ?? 0}') ?? 0,
      date: DateTime.tryParse('${json['created_at'] ?? ''}') ?? DateTime.now(),
      type: json['type'] == 'credit'
          ? TransactionType.credit
          : TransactionType.debit,
      method: _methodFromApi(json['method'] ?? 'noki_pay'),
    );
  }

  PaymentMethod _methodFromApi(dynamic value) {
    return switch ('$value') {
      'airtel_money' => PaymentMethod.airtelMoney,
      'moov_money' => PaymentMethod.moovMoney,
      'card' => PaymentMethod.card,
      _ => PaymentMethod.nokiPay,
    };
  }
}
