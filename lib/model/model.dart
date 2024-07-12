import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String description;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final bool isCredit;

  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final String contact;

  Transaction({
    required this.description,
    required this.amount,
    required this.isCredit,
    required this.date,
    required this.contact,

  });
}
