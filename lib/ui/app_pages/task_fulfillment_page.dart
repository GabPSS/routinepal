import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routinepal/src/task_fulfillment/bloc/task_fulfillment_bloc.dart';
import 'package:routinepal/src/task_overview/ui/task_widget.dart';
import 'package:routinepal_manager/routinepal_manager.dart';

class TaskFulfillmentPage extends StatelessWidget {
  final Task task;

  const TaskFulfillmentPage(this.task, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TaskWidget(task, color: Colors.white, fontSize: 2),
          ),
        ),
        backgroundColor: task.isFulfilled == true
            ? Colors.green
            : task.isFulfilled == false
                ? Colors.red
                : Colors.blue,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text("Name of the goal:"),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              task.title,
              textScaler: const TextScaler.linear(1.5),
            ),
          ),
          if (!task.isGroup) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text("Description:"),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                task.description,
                textScaler: const TextScaler.linear(1.5),
              ),
            ),
          ],
          if (task.minDuration != null) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text("Minimum duration:"),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "${task.minDuration} minutes",
                textScaler: const TextScaler.linear(1.5),
              ),
            ),
          ],
          if (task.maxDuration != null) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text("Maximum duration:"),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "${task.maxDuration} minutes",
                textScaler: const TextScaler.linear(1.5),
              ),
            ),
          ],
          if (task.isFulfilled == fulfillable &&
              (task.minDuration != null || task.maxDuration != null))
            TimerFulfillmentWidget(task)
          else if (task.isFulfilled == fulfillable && !task.isGroup)
            buildDefaultFulfillmentButton(context),
        ],
      ),
    );
  }

  Padding buildDefaultFulfillmentButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FilledButton(
        onPressed: () async {
          var confirmed = await showFulfillmentAlertDialog(context);
          if (confirmed == true && context.mounted) {
            BlocProvider.of<TaskFulfillmentBloc>(context)
                .add(TaskFulfillmentRequested(task));
          }
        },
        child: const Text('Fulfill Task', textScaler: TextScaler.linear(1.5)),
      ),
    );
  }

  Future<bool?> showFulfillmentAlertDialog(BuildContext context) {
    return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Fulfill Task?'),
              content: Text(
                  'Are you sure you want to mark this task as completed? Make sure you have met all conditions for fulfillment before proceeding. This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child:
                      const Text('Cancel', textScaler: TextScaler.linear(1.5)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Fulfill Task',
                      textScaler: TextScaler.linear(1.5)),
                ),
              ],
            ));
  }
}

class TimerFulfillmentWidget extends StatefulWidget {
  final Task task;

  const TimerFulfillmentWidget(this.task, {super.key});

  @override
  State<TimerFulfillmentWidget> createState() => _TimerFulfillmentWidgetState();
}

class _TimerFulfillmentWidgetState extends State<TimerFulfillmentWidget> {
  int totalSecondsElapsed = 0;
  int maxSeconds = 0;
  int minSeconds = 0;
  String get timeText =>
      "${totalSecondsElapsed ~/ 60}:${(totalSecondsElapsed % 60).toString().padLeft(2, '0')}";
  late double Function(int) getProgress;

  Timer? timer;
  bool get isRunning => timer != null;

  @override
  void initState() {
    super.initState();
    if (widget.task.minDuration != null) {
      minSeconds = widget.task.minDuration! * 60;
      getProgress = (totalSeconds) => totalSeconds / minSeconds;
    }
    if (widget.task.maxDuration != null) {
      maxSeconds = widget.task.maxDuration! * 60;
      getProgress = (totalSeconds) => totalSeconds / maxSeconds;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text("Timer:"),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 128,
                height: MediaQuery.of(context).size.width - 128,
                child: CircularProgressIndicator(
                  value: isRunning ? getProgress(totalSecondsElapsed) : 1,
                  color: isRunning ? Colors.green : Colors.grey,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              Text(
                timeText,
                textScaler: TextScaler.linear(3),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (!isRunning)
                FilledButton(
                  onPressed: startTimer,
                  child:
                      const Text('Start', textScaler: TextScaler.linear(1.5)),
                ),
              if (isRunning)
                FilledButton(
                  onPressed: cancelTimer,
                  child: Text("Cancel"),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (totalSecondsElapsed >= maxSeconds) {
        timer.cancel();
        this.timer = null;
      } else {
        totalSecondsElapsed++;
      }
      setState(() {});
    });
  }

  void cancelTimer() {
    timer?.cancel();
    timer = null;
    totalSecondsElapsed = 0;
    setState(() {});
  }
}
