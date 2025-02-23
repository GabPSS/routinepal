import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routinepal/src/app/app.dart';
import 'package:routinepal/src/app/bloc/app_bloc.dart';
import 'package:routinepal/src/completion_history/bloc/completion_history_bloc.dart';
import 'package:routinepal/src/routine_fulfillment/bloc/fulfillable_routines_bloc.dart';
import 'package:routinepal/src/task_fulfillment/bloc/task_fulfillment_bloc.dart';
import 'package:routinepal/src/task_overview/bloc/task_overview_bloc.dart';
import 'package:routinepal_api/routinepal_api.dart';
import 'package:routinepal_manager/routinepal_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  RoutinepalManager manager = RoutinepalManager(RoutinepalSqliteDb());

  runApp(RepositoryProvider(
    create: (context) => manager,
    child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AppBloc(manager)),
          BlocProvider(create: (context) => FulfillableRoutinesBloc(manager)),
          BlocProvider(create: (context) => TaskOverviewBloc(manager)),
          BlocProvider(create: (context) => TaskFulfillmentBloc(manager)),
          BlocProvider(create: (context) => CompletionHistoryBloc(manager))
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<TaskFulfillmentBloc, TaskFulfillmentState>(
              listener: (context, state) {
                if (state is TaskFulfillmentRequestSuccessful) {
                  BlocProvider.of<TaskOverviewBloc>(context)
                      .add(TaskOverviewLoadRequested());
                }
              },
            ),
            BlocListener<AppBloc, AppState>(
              listener: (context, state) {
                if (state is AppReady) {
                  BlocProvider.of<FulfillableRoutinesBloc>(context)
                      .add(RoutineListRequested());
                  BlocProvider.of<TaskOverviewBloc>(context)
                      .add(TaskOverviewLoadRequested());
                  BlocProvider.of<CompletionHistoryBloc>(context)
                      .add(CompletionHistoryLoadRequested());
                }
              },
            ),
          ],
          child: const App(),
        )),
  ));
}
