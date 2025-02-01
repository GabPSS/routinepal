part of 'task_overview_bloc.dart';

sealed class TaskOverviewState {}

final class TaskOverviewInitial extends TaskOverviewState {}

final class TaskOverviewEmpty extends TaskOverviewState {}

final class TaskOverviewLoaded extends TaskOverviewState {
  final List<Task> tasks;

  TaskOverviewLoaded(this.tasks);
}
