enum TransactionType { credit, debit }
enum PaymentMethod { mobileMoney, card, cash }

class TransactionModel {
  final String id, label, formattedAmount, formattedDate;
  final TransactionType type;
  const TransactionModel({required this.id, required this.label, required this.formattedAmount,
    required this.formattedDate, required this.type});
}
