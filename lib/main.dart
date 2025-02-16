import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routinepal/src/routine_fulfillment/bloc/fulfillable_routines_bloc.dart';
import 'package:routinepal/src/task_fulfillment/bloc/task_fulfillment_bloc.dart';
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
      BlocProvider(create: (context) => FulfillableRoutinesBloc(manager)),
      BlocProvider(create: (context) => TaskOverviewBloc(manager)),
      BlocProvider(create: (context) => TaskFulfillmentBloc(manager)),
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
    BlocProvider.of<TaskOverviewBloc>(context).add(TaskOverviewLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskFulfillmentBloc, TaskFulfillmentState>(
      listener: (context, state) {
        if (state is TaskFulfillmentRequestSuccessful) {
          BlocProvider.of<TaskOverviewBloc>(context)
              .add(TaskOverviewLoadRequested());
        }
      },
      child: MaterialApp(
        theme: ThemeData(
            colorSchemeSeed: Colors.cyan,
            textTheme: const TextTheme(
              bodyMedium: TextStyle(fontSize: 16.0),
            )),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.cyan,
            brightness: Brightness.dark,
          ),
        ),
        home: const AppScreen(),
      ),
    );
  }
}
