part of 'task_fulfillment_bloc.dart';

@immutable
sealed class TaskFulfillmentState {}

final class TaskFulfillmentInitial extends TaskFulfillmentState {}

final class TaskFulfillmentRequestInProgress extends TaskFulfillmentState {}

final class TaskFulfillmentRequestFailed extends TaskFulfillmentState {
  final Task task;

  TaskFulfillmentRequestFailed(this.task);
}

final class TaskFulfillmentRequestSuccessful extends TaskFulfillmentState {
  final Task task;

  TaskFulfillmentRequestSuccessful(this.task);
}
