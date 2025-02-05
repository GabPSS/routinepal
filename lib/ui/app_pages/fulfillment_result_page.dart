import 'dart:math';

import 'package:flutter/material.dart';

class FulfillmentResultPage extends StatelessWidget {
  final String name;
  final int itemID;
  final bool status;
  final bool isRoutine;

  FulfillmentResultPage({
    required this.name,
    required this.status,
    required this.itemID,
    super.key,
    this.isRoutine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              status ? Colors.green : Colors.red,
              status ? Colors.greenAccent : Colors.redAccent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.from(
                          alpha: 0.4, red: 0, green: 0, blue: 0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 16,
                        children: <Widget>[
                          Hero(
                            tag:
                                '${isRoutine ? 'routine' : 'task'}-$itemID-icon',
                            child: Icon(
                              status ? Icons.check_circle : Icons.error,
                              size: 128,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${isRoutine ? 'Routine' : 'Task'} ${status ? '' : 'Not '}Fulfilled!',
                            textScaler: const TextScaler.linear(2.5),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${isRoutine ? 'Routine' : 'Task'} '$name' was ${status ? '' : 'not '}fulfilled.",
                            textScaler: const TextScaler.linear(1.5),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Text(
                              status
                                  ? affirmingMessages[Random()
                                      .nextInt(affirmingMessages.length)]
                                  : encouragingMessages[Random()
                                      .nextInt(encouragingMessages.length)],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: FilledButton.icon(
                        icon: const Icon(Icons.close),
                        style: ButtonStyle(
                          iconColor: WidgetStatePropertyAll(
                              status ? Colors.green : Colors.red),
                          backgroundColor: WidgetStatePropertyAll(Colors.white),
                          foregroundColor: WidgetStatePropertyAll(
                              status ? Colors.green : Colors.red),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        label: const Text('Close')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<String> affirmingMessages = [
    "Keep it up! Not a cent of it goes to waste!",
    "Every time you choose to do what is right, you grow in virtue, sincerity, honesty and strength."
        "A small victory, but a blessing nonetheless!",
    "Good job! It might be simple, but keeping your word is even more important!",
    "Keep it up! Consistency is key! Small steps means your journey lasts longer!"
  ];

  final List<String> encouragingMessages = [
    "It's okay to slip up sometimes, no one is perfect, do it only with the will to learn!",
    "Don't be discouraged, it's okay, pick it back up the next time, and you're set off again",
    "Although it hurts, we're not perfect! Use this to become stronger, and you'll get better!"
  ];
}
