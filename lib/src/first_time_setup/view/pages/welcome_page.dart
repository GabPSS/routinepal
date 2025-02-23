import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  final void Function() onNext;

  const WelcomePage({required this.onNext, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 16,
      children: [
        const Spacer(),
        const Icon(Icons.light_mode_outlined, size: 72),
        Text(
          'Welcome!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Text(
          "Thanks for choosing RoutinePal!",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          "We will now ask you a few questions about you, and the app will be ready in no time!",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          "Tap the button to get started",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const Spacer(),
        const Text(
          "NOTE: All data is stored on your device only.",
          textAlign: TextAlign.center,
        ),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                  onPressed: onNext, child: const Text('Get Started')),
            ),
          ],
        ),
      ],
    );
  }
}
