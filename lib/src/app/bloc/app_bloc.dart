import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:routinepal/src/first_time_setup/model/first_time_setup_info.dart';
import 'package:routinepal_manager/routinepal_manager.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final RoutinepalManager manager;

  AppBloc(this.manager) : super(AppInitial()) {
    on<AppSetupFinished>((event, emit) async {
      log("APP: Setup finished");
      emit(AppLoading());
      //TODO: Save setup info
      await manager.reload();
      emit(AppReady(manager.userName));
    });

    on<AppLoadRequested>((event, emit) async {
      log("APP: Initial load requested");
      emit(AppLoading());
      await manager.init();
      if (manager.isFirstSetup) {
        emit(AppSetup());
      } else {
        emit(AppReady(manager.userName));
      }
    });

    on<AppReloadRequested>((event, emit) async {
      log("APP: Reload requested");
      await manager.reload();
      emit(AppReady(manager.userName));
    });
  }
}
