part of 'app_bloc.dart';

@immutable
sealed class AppState {}

final class AppInitial extends AppState {}

final class AppLoading extends AppState {}

final class AppSetup extends AppState {}

final class AppReady extends AppState {}
