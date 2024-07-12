import 'package:flutter/material.dart';
import 'package:ippokittum/model/model.dart';
import 'package:ippokittum/view/contactscreen.dart';

class CreditTransactionsView extends StatelessWidget {
  final List<Transaction> creditTransactions;

  const CreditTransactionsView({super.key, required this.creditTransactions});

  @override
  Widget build(BuildContext context) {
    // Group transactions by contact and sum their amounts
    final Map<String, double> groupedTransactions = {};
    for (var transaction in creditTransactions) {
      if (groupedTransactions.containsKey(transaction.contact)) {
        groupedTransactions[transaction.contact] =
            groupedTransactions[transaction.contact]! + transaction.amount;
      } else {
        groupedTransactions[transaction.contact] = transaction.amount;
      }
    }

    final groupedList = groupedTransactions.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Transactions'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: groupedList.length,
          itemBuilder: (context, index) {
            final entry = groupedList[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactDetailsView(contactName: entry.key),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Text(
                      entry.key[0],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    entry.key,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  trailing: Text(
                    entry.value.toStringAsFixed(2),
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
