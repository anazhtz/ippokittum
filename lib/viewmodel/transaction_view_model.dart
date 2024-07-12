import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:ippokittum/model/model.dart';

class TransactionViewModel extends ChangeNotifier {
  final Box<Transaction> transactionBox = Hive.box<Transaction>('transactionsBox');

  List<Transaction> get transactions => transactionBox.values.toList();

  void addTransaction(Transaction transaction) {
    transactionBox.add(transaction);
    notifyListeners();
  }

  double totalCreditsForContact(String contact) {
    return transactionBox.values
        .where((transaction) => transaction.contact == contact && transaction.isCredit)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double totalDebitsForContact(String contact) {
    return transactionBox.values
        .where((transaction) => transaction.contact == contact && !transaction.isCredit)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double netAmountForContact(String contact) {
    return totalCreditsForContact(contact) - totalDebitsForContact(contact);
  }
}
