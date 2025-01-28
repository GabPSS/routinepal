import 'package:bloc/bloc.dart';
import 'package:routinepal_api/routinepal_api.dart';
import 'package:routinepal_manager/routinepal_manager.dart';

part 'fulfillable_routines_event.dart';
part 'fulfillable_routines_state.dart';

class FulfillableRoutinesBloc
    extends Bloc<FulfillableRoutinesEvent, FulfillableRoutinesState> {
  final RoutinepalManager repository;

  FulfillableRoutinesBloc(this.repository)
      : super(FulfillableRoutinesInitial()) {
    on<RoutineListRequested>((event, emit) async {
      try {
        var list = await repository.getFulfillableRoutines();

        if (list.isEmpty) {
          emit(FulfillableRoutinesEmpty());
        } else {
          emit(FulfillableRoutinesLoaded(list));
        }
      } catch (e) {
        emit(FulfillableRoutinesLoaded(const []));
      }
    });
  }
}
