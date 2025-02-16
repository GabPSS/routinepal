part of 'fulfillable_routines_bloc.dart';

sealed class FulfillableRoutinesEvent {}

final class RoutineListRequested extends FulfillableRoutinesEvent {}

final class RoutineFulfillmentCancelled extends FulfillableRoutinesEvent {
  List<api.Task> tasksRemaining;

  RoutineFulfillmentCancelled(this.tasksRemaining);
}
