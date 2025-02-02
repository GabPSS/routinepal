import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:routinepal_manager/routinepal_manager.dart';

part 'task_fulfillment_event.dart';
part 'task_fulfillment_state.dart';

class TaskFulfillmentBloc
    extends Bloc<TaskFulfillmentEvent, TaskFulfillmentState> {
  final RoutinepalManager repository;

  TaskFulfillmentBloc(this.repository) : super(TaskFulfillmentInitial()) {
    on<TaskFulfillmentRequested>((event, emit) async {
      log("Task fulfillment requested for task: ${event.task.title}");
      try {
        emit(TaskFulfillmentRequestInProgress());
        bool success = await repository.attemptTaskFulfillment(event.task);
        if (success) {
          emit(TaskFulfillmentRequestSuccessful(event.task));
        } else {
          emit(TaskFulfillmentRequestFailed(event.task));
        }
      } catch (e) {
        log("Error when requesting task fulfillment: $e");
        emit(TaskFulfillmentRequestFailed(event.task));
      }
    });
  }
}
