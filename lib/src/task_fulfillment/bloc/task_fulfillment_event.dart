part of 'task_fulfillment_bloc.dart';

@immutable
sealed class TaskFulfillmentEvent {}

class TaskFulfillmentRequested extends TaskFulfillmentEvent {
  final Task task;
  final bool success;

  TaskFulfillmentRequested(this.task, this.success);
}
