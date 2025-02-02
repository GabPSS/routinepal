import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:routinepal/utils.dart';
import 'package:routinepal_manager/routinepal_manager.dart';

part 'task_overview_event.dart';
part 'task_overview_state.dart';

class TaskOverviewBloc extends Bloc<TaskOverviewEvent, TaskOverviewState> {
  final RoutinepalManager repository;

  TaskOverviewBloc(this.repository) : super(TaskOverviewInitial()) {
    on<TaskOverviewLoadRequested>((event, emit) async {
      log("Task overview load requested");
      try {
        var tasks = await repository.getTasksFor(Utils.today());
        emit(
          tasks.isNotEmpty ? TaskOverviewLoaded(tasks) : TaskOverviewEmpty(),
        );
      } catch (e) {
        log("Error when loading Task Overview: $e");
        emit(TaskOverviewEmpty());
      }
    });
  }
}
