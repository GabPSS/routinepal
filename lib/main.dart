import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routinepal/src/fulfillable_routines/bloc/fulfillable_routines_bloc.dart';
import 'package:routinepal/ui/app_screen.dart';
import 'package:routinepal_api/routinepal_api.dart';
import 'package:routinepal_manager/routinepal_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  RoutinepalManager manager = RoutinepalManager(RoutinepalSqliteDb());
  await manager.init();

  runApp(BlocProvider(
    create: (context) => FulfillableRoutinesBloc(manager),
    child: const MainApp(),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<FulfillableRoutinesBloc>(context)
        .add(RoutineListRequested());
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: AppScreen());
  }
}
