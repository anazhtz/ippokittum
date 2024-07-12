import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ippokittum/model/model.dart';
import 'package:ippokittum/view/home_view.dart';
import 'package:ippokittum/viewmodel/transaction_view_model.dart';
import 'package:provider/provider.dart';


Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  await Hive.openBox<Transaction>('transactionsBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Money Control App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeView(),
      ),
    );
  }
}