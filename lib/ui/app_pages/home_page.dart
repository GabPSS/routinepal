import 'package:flutter/material.dart';
import 'package:routinepal/src/fulfillable_routines/ui/fulfillable_routines_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        FulfillableRoutinesWidget(),
      ],
    );
  }
}
