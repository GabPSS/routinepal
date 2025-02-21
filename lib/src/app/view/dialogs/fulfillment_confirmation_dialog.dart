import 'package:flutter/material.dart';

Future<bool?> showFulfillmentAlertDialog(BuildContext context,
    {bool isFulfillmentAttempted = true}) {
  return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(
                isFulfillmentAttempted ? 'Fulfill task?' : 'Give up on task?'),
            content: Text(isFulfillmentAttempted
                ? 'Are you sure you want to mark this task as completed? Make sure you have met all conditions for fulfillment before proceeding. This action cannot be undone.'
                : 'Are you sure you want to give up on this task? Giving up means you will not have another chance to fulfill it for today. This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child:
                    Text(isFulfillmentAttempted ? 'Fulfill Task' : 'Give Up'),
              ),
            ],
          ));
}
