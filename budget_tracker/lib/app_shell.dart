import 'package:flutter/material.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/transactions/presentation/screens/transaction_list_screen.dart';
import '../../features/budgets/presentation/screens/budget_overview_screen.dart';
import '../../features/goals/presentation/screens/goals_list_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

/// Root navigation shell (PRD 10.1): Home / Transactions / Budget / Goals /
/// AI, all reachable from a persistent bottom bar. Uses IndexedStack so
/// each tab keeps its scroll position and provider state when switching.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _goToAssistant() => setState(() => _index = 4);

  void _goToSettings() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onOpenAssistant: _goToAssistant, onOpenSettings: _goToSettings),
      const TransactionListScreen(),
      const BudgetOverviewScreen(),
      const GoalsListScreen(),
      const AIAssistantScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Budget',
          ),
          NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'Goals'),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI',
          ),
        ],
      ),
    );
  }
}
