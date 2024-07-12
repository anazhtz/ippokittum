import 'package:flutter/material.dart';
import 'package:ippokittum/model/model.dart';
import 'package:ippokittum/viewmodel/transaction_view_model.dart';
import 'package:provider/provider.dart';

class ContactDetailsView extends StatefulWidget {
  final String contactName;

  const ContactDetailsView({super.key, required this.contactName});

  @override
  _ContactDetailsViewState createState() => _ContactDetailsViewState();
}

class _ContactDetailsViewState extends State<ContactDetailsView> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  bool isCredit = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.contactName}\'s Transactions'),
        backgroundColor: Colors.teal,
      ),
      body: Consumer<TransactionViewModel>(
        builder: (context, viewModel, child) {
          final transactions = viewModel.transactions
              .where((transaction) => transaction.contact == widget.contactName)
              .toList();

          double totalCredit = viewModel.totalCreditsForContact(widget.contactName);
          double totalDebit = viewModel.totalDebitsForContact(widget.contactName);
          double netAmount = viewModel.netAmountForContact(widget.contactName);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.teal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Given',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\u20B9 ${totalDebit.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Total Received',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\u20B9 ${totalCredit.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Net Amount',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\u20B9 ${netAmount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Add New Transaction',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                          ),
                          const SizedBox(height: 16),
                          _buildCustomTextField(
                            controller: descriptionController,
                            labelText: 'Description',
                            icon: Icons.description,
                          ),
                          const SizedBox(height: 16),
                          _buildCustomTextField(
                            controller: amountController,
                            labelText: 'Amount',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          Row(
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
                                    DropdownMenuItem(value: true, child: Text('Credit')),
                                    DropdownMenuItem(value: false, child: Text('Debit')),
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
                                  final description = descriptionController.text.trim();
                                  final amountText = amountController.text.trim();
                                  final amount = double.tryParse(amountText);

                                  if (description.isNotEmpty && amount != null) {
                                    final newTransaction = Transaction(
                                      description: description,
                                      amount: amount,
                                      isCredit: isCredit,
                                      date: DateTime.now(),
                                      contact: widget.contactName,
                                    );

                                    Provider.of<TransactionViewModel>(context, listen: false)
                                        .addTransaction(newTransaction);

                                    descriptionController.clear();
                                    amountController.clear();
                                    setState(() {
                                      isCredit = true;
                                    });
                                  }
                                },
                                child: const Text('Add Transaction', style: TextStyle(fontSize: 16)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true, // Make the ListView take only as much space as it needs
                  physics: NeverScrollableScrollPhysics(), // Disable ListView scrolling
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          transaction.isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                          color: transaction.isCredit ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          transaction.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          '${transaction.amount.toStringAsFixed(2)} - ${transaction.isCredit ? 'Credit' : 'Debit'}',
                        ),
                        trailing: Column(
                          children: [
                            Text(
                              '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${transaction.date.hour}:${transaction.date.minute}:${transaction.date.second}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
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
}
