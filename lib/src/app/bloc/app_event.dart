part of 'app_bloc.dart';

@immutable
sealed class AppEvent {}

class AppLoadRequested extends AppEvent {}

class AppReloadRequested extends AppEvent {}

class AppSetupFinished extends AppEvent {
  final FirstTimeSetupInfo setupInfo;

  AppSetupFinished(this.setupInfo);
}
