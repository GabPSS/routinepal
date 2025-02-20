part of 'completion_history_bloc.dart';

@immutable
sealed class CompletionHistoryState {}

final class CompletionHistoryInitial extends CompletionHistoryState {}

final class CompletionHistoryLoading extends CompletionHistoryState {}

final class CompletionHistoryLoaded extends CompletionHistoryState {
  final Map<DateTime, Map<TaskBase, TaskCompletion?>> completions;
  final List<String> allTaskNames;

  CompletionHistoryLoaded(this.completions, this.allTaskNames);
}
