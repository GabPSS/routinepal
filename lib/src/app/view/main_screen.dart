import 'package:flutter/material.dart';
import 'package:routinepal/src/app/view/navigation/history_page.dart';
import 'package:routinepal/src/app/view/navigation/home_page.dart';
import 'package:routinepal/src/app/view/navigation/routines_page.dart';
import 'package:routinepal/src/app/view/navigation/task_creation_page.dart';
import 'package:routinepal/src/app/view/navigation/tasks_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
      floatingActionButton: selectedPage == 1
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TaskCreationPage())),
              child: const Icon(Icons.add),
            )
          : null,
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
