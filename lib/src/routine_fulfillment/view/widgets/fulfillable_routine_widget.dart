import 'package:flutter/material.dart';
import 'package:routinepal/src/routine_fulfillment/view/routine_fulfillment_page.dart';
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
          leading: Hero(
            tag: 'routine-${routine.id}-icon',
            child: const Icon(
              Icons.light_mode_outlined,
              size: 56,
            ),
          ),
          title: Text("Your ${routine.title} routine is ready!"),
          subtitle: Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Your routine is ready to be fulfilled. Start now!"),
              FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          RoutineFulfillmentPage(routine: routine),
                    ));
                  },
                  child: const Text("Start routine"))
            ],
          ),
        ),
      ),
    );
  }
}
