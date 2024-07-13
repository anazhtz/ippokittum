import 'package:flutter/material.dart';
import 'package:ippokittum/model/model.dart';
import 'package:ippokittum/view/contactscreen.dart';
import 'package:ippokittum/view/creditcontact.dart';
import 'package:ippokittum/view/debicontact.dart';
import 'package:provider/provider.dart';
import '../viewmodel/transaction_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  bool isCredit = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'IppoKittum!',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Colors.teal.shade700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Consumer<TransactionViewModel>(
              builder: (context, viewModel, child) {
                // Calculate the net amount for each contact
                final contactNetAmounts = <String, double>{};

                for (var transaction in viewModel.transactions) {
                  final netAmount =
                      contactNetAmounts[transaction.contact] ?? 0.0;
                  contactNetAmounts[transaction.contact] = netAmount +
                      (transaction.isCredit
                          ? transaction.amount
                          : -transaction.amount);
                }

                double totalCredit = 0.0;
                double totalDebit = 0.0;

                // Sum the positive and negative net amounts
                contactNetAmounts.forEach((contact, netAmount) {
                  if (netAmount > 0) {
                    totalCredit += netAmount;
                  } else if (netAmount < 0) {
                    totalDebit +=
                        netAmount.abs(); // Convert to positive for display
                  }
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.arrow_downward,
                            color: Colors.green, size: 32),
                        SizedBox(width: 8),
                        Text(
                          'Cash In',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        List<Transaction> creditTransactions = viewModel
                            .transactions
                            .where((transaction) => transaction.isCredit)
                            .toList();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreditTransactionsView(
                                creditTransactions: creditTransactions),
                          ),
                        );
                      },
                      child: Text(
                        '\u20B9 ${totalCredit.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(Icons.arrow_upward, color: Colors.red, size: 32),
                        SizedBox(width: 8),
                        Text(
                          'Cash Out',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DebitTransactionsView(
                              debitTransactions: viewModel.transactions
                                  .where((transaction) => !transaction.isCredit)
                                  .toList(),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        '\u20B9 ${totalDebit.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Add New Transaction',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildContactAutocomplete(),
                            const SizedBox(height: 16),
                            _buildCustomTextField(
                              controller: amountController,
                              labelText: 'Amount',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            _buildCustomTextField(
                              controller: descriptionController,
                              labelText: 'Description',
                              icon: Icons.description,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: DropdownButton<bool>(
                                    value: isCredit,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        isCredit = newValue ?? true;
                                      });
                                    },
                                    items: const [
                                      DropdownMenuItem(
                                          value: true, child: Text('Credit')),
                                      DropdownMenuItem(
                                          value: false, child: Text('Debit')),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    final description =
                                        descriptionController.text.trim();
                                    final amountText =
                                        amountController.text.trim();
                                    final contact =
                                        contactController.text.trim();
                                    final amount = double.tryParse(amountText);

                                    if (description.isEmpty ||
                                        amount == null ||
                                        contact.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Please fill all fields.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return; // Exit onPressed if any field is empty
                                    }

                                    final newTransaction = Transaction(
                                      description: description,
                                      amount: amount,
                                      isCredit: isCredit,
                                      date: DateTime.now(),
                                      contact: contact,
                                    );

                                    Provider.of<TransactionViewModel>(context,
                                            listen: false)
                                        .addTransaction(newTransaction);

                                    descriptionController.clear();
                                    amountController.clear();
                                    contactController.clear();
                                    setState(() {
                                      isCredit = true;
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Transaction added successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                  child: const Text('Add Transaction',
                                      style: TextStyle(fontSize: 16,color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Consumer<TransactionViewModel>(
                        builder: (context, viewModel, child) {
                          final transactions = viewModel.transactions;
                          if (transactions.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                  child: Text('No transactions yet',
                                      style: TextStyle(fontSize: 16))),
                            );
                          }
                          transactions.sort((a, b) => b.date.compareTo(a.date));
                          final lastTenTransactions =
                              transactions.take(10).toList();
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: lastTenTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = lastTenTransactions[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: transaction.isCredit
                                        ? Colors.green
                                        : Colors.red,
                                    child: Icon(
                                      transaction.isCredit
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    transaction.description,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '\u20B9 ${transaction.amount.toStringAsFixed(2)} - ${transaction.isCredit ? 'Credit' : 'Debit'}',
                                        style: TextStyle(
                                          color: transaction.isCredit
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        transaction.contact,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${transaction.date.day}/${transaction.date.month}/${transaction.date.year} ${transaction.date.hour}:${transaction.date.minute}',
                                        style: const TextStyle(
                                            color: Colors.black38),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ContactDetailsView(
                                                contactName:
                                                    transaction.contact),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.teal, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

Widget _buildContactAutocomplete() {
  return Consumer<TransactionViewModel>(
    builder: (context, viewModel, child) {
      final contacts = viewModel.transactions.map((t) => t.contact).toSet().toList();

      return Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          return contacts.where((contact) {
            return contact.toLowerCase().contains(textEditingValue.text.toLowerCase());
          });
        },
        onSelected: (String selection) {
          contactController.text = selection;
        },
        fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode fieldFocusNode, VoidCallback onFieldSubmitted) {
          contactController = fieldTextEditingController;
          return TextField(
            controller: fieldTextEditingController,
            focusNode: fieldFocusNode,
            decoration: InputDecoration(
              labelText: 'Contact',
              prefixIcon: const Icon(Icons.contact_phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.teal),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.teal, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.822, // Adjust width as needed
                constraints: BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: options.map((String contact) {
                    return ListTile(
                      title: Text(contact),
                      onTap: () {
                        onSelected(contact);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}


}
