import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:routinepal_api/routinepal_api.dart' as api;
import 'package:routinepal_manager/routinepal_manager.dart' as mgr;

part 'fulfillable_routines_event.dart';
part 'fulfillable_routines_state.dart';

class FulfillableRoutinesBloc
    extends Bloc<FulfillableRoutinesEvent, FulfillableRoutinesState> {
  final mgr.RoutinepalManager repository;

  FulfillableRoutinesBloc(this.repository)
      : super(FulfillableRoutinesInitial()) {
    on<FulfillableRoutinesEvent>((event, emit) async {
      try {
        if (event is RoutineFulfillmentCancelled) {
          log("INFO: Current routine fulfillment cancelled. Unfulfilling tasks.");
          for (var task in event.tasksRemaining) {
            await repository.attemptTaskUnfulfillment(
                mgr.Task.mock(task.id, task.title, event.routineTaskGroupId));
          }
        }

        var list = await repository.getFulfillableRoutines();

        if (list.isEmpty) {
          emit(FulfillableRoutinesEmpty());
        } else {
          emit(FulfillableRoutinesLoaded(list));
        }
      } catch (e) {
        emit(FulfillableRoutinesLoaded(const []));
      }
    });
  }
}
