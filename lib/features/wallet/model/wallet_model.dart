import 'package:intl/intl.dart';

enum TransactionType { credit, debit }
enum PaymentMethod { nokiPay, airtelMoney, moovMoney, card }

class TransactionModel {
  final String id;
  final String label;
  final int amount;
  final DateTime date;
  final TransactionType type;
  final PaymentMethod method;

  const TransactionModel({
    required this.id,
    required this.label,
    required this.amount,
    required this.date,
    required this.type,
    this.method = PaymentMethod.nokiPay,
  });

  String get formattedAmount => "${type == TransactionType.credit ? '+' : '-'}${NumberFormat('#,###').format(amount).replaceAll(',', ' ')} F";
  
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDate = DateTime(date.year, date.month, date.day);
    final diff = today.difference(txDate).inDays;

    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return "Hier";
    
    try {
      return DateFormat('dd MMM', 'fr_FR').format(date);
    } catch (e) {
      return DateFormat('dd MMM').format(date);
    }
  }
}
