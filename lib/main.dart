import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routinepal/src/fulfillable_routines/bloc/fulfillable_routines_bloc.dart';
import 'package:routinepal/src/task_overview/bloc/task_overview_bloc.dart';
import 'package:routinepal/ui/app_screen.dart';
import 'package:routinepal_api/routinepal_api.dart';
import 'package:routinepal_manager/routinepal_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  RoutinepalManager manager = RoutinepalManager(RoutinepalSqliteDb());
  await manager.init();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => FulfillableRoutinesBloc(manager),
      ),
      BlocProvider(
        create: (context) => TaskOverviewBloc(manager),
      ),
    ],
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
    BlocProvider.of<TaskOverviewBloc>(context).add(TaskOverviewRequested());
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: AppScreen());
  }
}
