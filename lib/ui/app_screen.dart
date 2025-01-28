import 'package:flutter/material.dart';
import 'package:routinepal/ui/app_pages/history_page.dart';
import 'package:routinepal/ui/app_pages/home_page.dart';
import 'package:routinepal/ui/app_pages/routines_page.dart';
import 'package:routinepal/ui/app_pages/tasks_page.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  static const destinations = [
    NavigationDestination(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.checklist),
      label: 'Tasks',
    ),
    NavigationDestination(
      icon: Icon(Icons.brightness_7),
      label: 'Routines',
    ),
    NavigationDestination(
      icon: Icon(Icons.history),
      label: 'History',
    ),
  ];

  int selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(destinations[selectedPage].label),
      ),
      body: switch (selectedPage) {
        0 => const HomePage(),
        1 => const TasksPage(),
        2 => const RoutinesPage(),
        3 => const HistoryPage(),
        _ => throw Exception('Invalid page index: $selectedPage'),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedPage,
        onDestinationSelected: (value) => setState(() => selectedPage = value),
        destinations: destinations,
      ),
    );
  }
}
