part of 'completion_history_bloc.dart';

@immutable
sealed class CompletionHistoryEvent {}

class CompletionHistoryLoadRequested extends CompletionHistoryEvent {
  final int length;

  CompletionHistoryLoadRequested([this.length = 7]);
}
