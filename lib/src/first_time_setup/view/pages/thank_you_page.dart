import 'package:flutter/material.dart';

class ThankYouPage extends StatelessWidget {
  final void Function() onNext;

  const ThankYouPage({required this.onNext, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        const Spacer(),
        const Icon(Icons.check, size: 72),
        Text(
          "Thank you!",
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        Text(
          "You're all set up! Enjoy using RoutinePal!",
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: onNext,
                child: const Text('Finish'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
