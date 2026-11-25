import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pmobile_harianku/component/navigation/navigation.dart';
import 'package:pmobile_harianku/pages/add_transaction_page.dart';
import 'package:pmobile_harianku/pages/budget_page.dart';
import 'package:pmobile_harianku/providers/finance_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const _primary = Color(0xFF253B80);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FinanceProvider()..loadInitialData(),
      child: MaterialApp(
        title: 'Harianku',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: _primary),
          scaffoldBackgroundColor: const Color(0xFFF8F9FC),
          useMaterial3: true,
        ),
        home: const _NavigationHost(),
      ),
    );
  }
}

class _NavigationHost extends StatefulWidget {
  const _NavigationHost();

  @override
  State<_NavigationHost> createState() => _NavigationHostState();
}

class _NavigationHostState extends State<_NavigationHost> {
  HariankuDestination _selectedDestination = HariankuDestination.beranda;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedDestination == HariankuDestination.budget
          ? const BudgetPage()
          : const SizedBox.expand(),
      bottomNavigationBar: HariankuBottomNavigationBar(
        selectedDestination: _selectedDestination,
        onDestinationSelected: (destination) {
          setState(() {
            _selectedDestination = destination;
          });
        },
        onAddTransaction: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddTransactionPage(),
            ),
          );
        },
      ),
    );
  }
}
