// lib/model/transaction.dart

class Transaction {
  final String description;
  final double amount;
  final bool isCredit;
  final DateTime date;
  final String contact;

  Transaction({
    required this.description,
    required this.amount,
    required this.isCredit,
    required this.date,
    required this.contact,
  });
}
