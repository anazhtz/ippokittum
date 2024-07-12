import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:ippokittum/model/model.dart';

class TransactionViewModel extends ChangeNotifier {
  final Box<Transaction> transactionBox = Hive.box<Transaction>('transactionsBox');

  /// Retrieves all transactions from the Hive box.
  List<Transaction> get transactions => transactionBox.values.toList();

  /// Adds a new transaction to the Hive box and notifies listeners.
  void addTransaction(Transaction transaction) {
    transactionBox.add(transaction);
    notifyListeners();
  }

  /// Updates an existing transaction in the Hive box and notifies listeners.
  void updateTransaction(int index, Transaction updatedTransaction) {
    transactionBox.putAt(index, updatedTransaction);
    notifyListeners();
  }

  /// Deletes a transaction from the Hive box and notifies listeners.
  void deleteTransaction(int index) {
    transactionBox.deleteAt(index);
    notifyListeners();
  }

  /// Calculates the total credits for a given contact.
  double totalCreditsForContact(String contact) {
    return transactionBox.values
        .where((transaction) => transaction.contact == contact && transaction.isCredit)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Calculates the total debits for a given contact.
  double totalDebitsForContact(String contact) {
    return transactionBox.values
        .where((transaction) => transaction.contact == contact && !transaction.isCredit)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  /// Calculates the net amount (credits minus debits) for a given contact.
  double netAmountForContact(String contact) {
    return totalCreditsForContact(contact) - totalDebitsForContact(contact);
  }

  /// Retrieves a transaction by index.
  Transaction getTransaction(int index) {
    return transactionBox.getAt(index) as Transaction;
  }
}
