import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:routinepal_api/routinepal_api.dart';
import 'package:routinepal_api/src/models/task_completion.dart';
import 'package:routinepal_manager/routinepal_manager.dart';

part 'completion_history_event.dart';
part 'completion_history_state.dart';

class CompletionHistoryBloc
    extends Bloc<CompletionHistoryEvent, CompletionHistoryState> {
  final RoutinepalManager repository;

  CompletionHistoryBloc(this.repository) : super(CompletionHistoryInitial()) {
    on<CompletionHistoryLoadRequested>((event, emit) async {
      log("Completion history load requested");
      emit(CompletionHistoryLoading());
      var taskNames = await repository.getAllTaskNames();
      var completions = await repository.getCompletionHistory(event.length);
      emit(CompletionHistoryLoaded(completions, taskNames));
    });
  }
}
