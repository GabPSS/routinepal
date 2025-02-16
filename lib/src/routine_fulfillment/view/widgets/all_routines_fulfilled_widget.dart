import 'package:flutter/material.dart';

class AllRoutinesFulfilledWidget extends StatelessWidget {
  const AllRoutinesFulfilledWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: SizedBox(
        height: 120,
        child: Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            Icon(
              Icons.check_sharp,
              size: 48,
            ),
            Text(
              "Nothing for now!",
              textScaler: TextScaler.linear(1.2),
            ),
          ],
        )),
      ),
    );
  }
}
