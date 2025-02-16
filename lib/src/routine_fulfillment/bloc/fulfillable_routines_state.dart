part of 'fulfillable_routines_bloc.dart';

sealed class FulfillableRoutinesState {}

final class FulfillableRoutinesInitial extends FulfillableRoutinesState {}

final class FulfillableRoutinesEmpty extends FulfillableRoutinesState {}

final class FulfillableRoutinesLoaded extends FulfillableRoutinesState {
  final List<api.Routine> routines;

  FulfillableRoutinesLoaded(this.routines);
}
