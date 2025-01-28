import 'package:flutter/material.dart';
import 'package:routinepal_api/routinepal_api.dart';

class FulfillableRoutineWidget extends StatelessWidget {
  final Routine routine;

  const FulfillableRoutineWidget(
    this.routine, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: const Icon(
            Icons.light_mode_outlined,
            size: 56,
          ),
          title: Text("Your ${routine.title} routine is ready!"),
          subtitle: Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Your routine is ready to be fulfilled. Start now!"),
              FilledButton(
                  onPressed: () {
                    //TODO: Implement action
                  },
                  child: const Text("Start routine"))
            ],
          ),
        ),
      ),
    );
  }
}
