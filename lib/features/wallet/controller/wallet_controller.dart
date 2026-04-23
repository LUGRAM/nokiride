import 'package:get/get.dart';
import '../model/wallet_model.dart';

class WalletController extends GetxController {
  final RxInt balance = 5000.obs;
  final RxBool balanceVisible = true.obs;

  final transactions = [
    const TransactionModel(id:'1', label:'Course Akanda → Charbonnages', formattedAmount:'-1 500 F', formattedDate:"Aujourd'hui", type: TransactionType.debit),
    const TransactionModel(id:'2', label:'Recharge Mobile Money', formattedAmount:'+10 000 F', formattedDate:'Hier', type: TransactionType.credit),
    const TransactionModel(id:'3', label:'Envoi colis Batterie IV', formattedAmount:'-1 200 F', formattedDate:'22 avr.', type: TransactionType.debit),
    const TransactionModel(id:'4', label:'Recharge Airtel Money', formattedAmount:'+5 000 F', formattedDate:'20 avr.', type: TransactionType.credit),
    const TransactionModel(id:'5', label:'Course Nzeng-Ayong', formattedAmount:'-2 000 F', formattedDate:'18 avr.', type: TransactionType.debit),
  ];

  void toggleVisibility() => balanceVisible.toggle();

  void recharge(int amount) {
    balance.value += amount;
    Get.snackbar('Recharge réussie', '+$amount F CFA ajoutés à votre wallet', snackPosition: SnackPosition.BOTTOM);
  }

  String get formattedBalance {
    final s = balance.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
    return '$s F CFA';
  }
}
