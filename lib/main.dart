import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:routinepal_api/routinepal_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  RoutinepalSqliteDb db = RoutinepalSqliteDb();

  await db.init();
  log(db.getFulfillableRoutines().toString());

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
