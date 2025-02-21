import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routinepal/src/routine_fulfillment/bloc/fulfillable_routines_bloc.dart';
import 'package:routinepal/src/task_fulfillment/bloc/task_fulfillment_bloc.dart';
import 'package:routinepal/src/task_overview/bloc/task_overview_bloc.dart';
import 'package:routinepal/src/app/view/app_screen.dart';

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
            seedColor: const Color.fromARGB(255, 32, 0, 212),
            brightness: Brightness.dark,
          ),
        ),
        //TODO: Add first time setup screen
        home: const AppScreen(),
      ),
    );
  }
}
