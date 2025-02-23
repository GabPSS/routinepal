import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  final void Function() onNext;

  const NextButton({
    required this.onNext,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: onNext,
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }
}
