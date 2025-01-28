import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routinepal/src/fulfillable_routines/bloc/fulfillable_routines_bloc.dart';
import 'package:routinepal/src/fulfillable_routines/ui/all_routines_fulfilled_widget.dart';
import 'package:routinepal/src/fulfillable_routines/ui/fulfillable_routine_widget.dart';

class FulfillableRoutinesWidget extends StatelessWidget {
  const FulfillableRoutinesWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your routines",
            textScaler: TextScaler.linear(1.8),
          ),
          BlocBuilder<FulfillableRoutinesBloc, FulfillableRoutinesState>(
            builder: (context, state) {
              if (state is FulfillableRoutinesInitial) {
                return Container();
              } else if (state is FulfillableRoutinesLoaded) {
                return Column(
                  children: state.routines
                      .map((routine) => FulfillableRoutineWidget(routine))
                      .toList(),
                );
              } else {
                return const AllRoutinesFulfilledWidget();
              }
            },
          )
        ],
      ),
    );
  }
}
