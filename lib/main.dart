import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routinepal/src/app/main_app.dart';
import 'package:routinepal/src/routine_fulfillment/bloc/fulfillable_routines_bloc.dart';
import 'package:routinepal/src/task_fulfillment/bloc/task_fulfillment_bloc.dart';
import 'package:routinepal/src/task_overview/bloc/task_overview_bloc.dart';
import 'package:routinepal_api/routinepal_api.dart';
import 'package:routinepal_manager/routinepal_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  RoutinepalManager manager = RoutinepalManager(RoutinepalSqliteDb());
  await manager.init();

  runApp(RepositoryProvider(
    create: (context) => manager,
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => FulfillableRoutinesBloc(manager)),
        BlocProvider(create: (context) => TaskOverviewBloc(manager)),
        BlocProvider(create: (context) => TaskFulfillmentBloc(manager)),
      ],
      child: const MainApp(),
    ),
  ));
}
