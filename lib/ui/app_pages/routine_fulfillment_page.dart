import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routinepal/src/fulfillable_routines/bloc/fulfillable_routines_bloc.dart';
import 'package:routinepal/src/task_fulfillment/bloc/task_fulfillment_bloc.dart';
import 'package:routinepal/ui/app_pages/fulfillment_result_page.dart';
import 'package:routinepal/ui/widgets/timer_fulfillment_widget.dart';
import 'package:routinepal_api/routinepal_api.dart';
import 'package:routinepal_manager/routinepal_manager.dart' as mgr;

class RoutineFulfillmentPage extends StatefulWidget {
  final Routine routine;

  const RoutineFulfillmentPage({
    required this.routine,
    super.key,
  });

  @override
  State<RoutineFulfillmentPage> createState() => _RoutineFulfillmentPageState();
}

class _RoutineFulfillmentPageState extends State<RoutineFulfillmentPage> {
  int currentPage = -1;
  List<Task> tasksRemaining = [];
  Task get currentTask => tasksRemaining[currentPage];
  bool get isTimeBased =>
      currentTask.maxDuration != null || currentTask.minDuration != null;

  int unfulfilledTasks = 0;
  int totalTasks = 0;
  bool timerStarted = false;

  @override
  void initState() {
    super.initState();

    tasksRemaining = List.of(widget.routine.tasks, growable: true);
    totalTasks = tasksRemaining.length;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        } else {
          if (tasksRemaining.isNotEmpty &&
              await showCancelAlert(context) == true &&
              context.mounted) {
            BlocProvider.of<FulfillableRoutinesBloc>(context)
                .add(RoutineFulfillmentCancelled(tasksRemaining));
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return FulfillmentResultPage(
                isRoutine: true,
                name: widget.routine.title,
                status: false,
                itemID: widget.routine.id,
              );
            }));
          }
        }
      },
      child: Scaffold(
        appBar: currentPage != -1
            ? AppBar(
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: Text("${widget.routine.title} routine"),
              )
            : null,
        body: getPage(),
      ),
    );
  }

  Future<bool?> showCancelAlert(BuildContext context) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Give up fulfillment?"),
            content: const Text(
                "Quitting now means your routine will remain unfulfilled."),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text('Quit')),
            ],
          );
        });
  }

  Widget getPage() {
    if (currentPage == -1) {
      return Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    children: [
                      Hero(
                        tag: 'routine-${widget.routine.id}-icon',
                        child: Icon(
                          Icons.light_mode_outlined,
                          size: 128,
                        ),
                      ),
                      Text(
                        "Welcome to your ${widget.routine.title} routine!",
                        textScaler: TextScaler.linear(2),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        "In order to fulfill your routine, you will be presented with the following tasks:",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                      children: tasksRemaining.map((task) {
                    return ListTile(
                      leading: const Icon(Icons.check),
                      title: Text(task.title),
                      dense: true,
                    );
                  }).toList()),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                    child: FilledButton(
                        onPressed: nextPage, child: Text("Let's start!"))),
              ],
            ),
          )
        ],
      );
    } else if (tasksRemaining.isEmpty) {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Hero(
              tag: 'routine-${widget.routine.id}-icon',
              child: Icon(
                unfulfilledTasks == 0
                    ? Icons.check_circle
                    : Icons.error_outline,
                size: 128,
              ),
            ),
            Text(
              unfulfilledTasks == 0
                  ? "All tasks finished!"
                  : "$unfulfilledTasks of $totalTasks tasks not completed...",
              textScaler: TextScaler.linear(2),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                        onPressed: () {
                          BlocProvider.of<FulfillableRoutinesBloc>(context)
                              .add(RoutineListRequested());
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return FulfillmentResultPage(
                              isRoutine: true,
                              name: widget.routine.title,
                              status: unfulfilledTasks == 0,
                              itemID: widget.routine.id,
                            );
                          }));
                        },
                        child: Text("Finish routine")),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Text(
              "${tasksRemaining.length} task${tasksRemaining.length != 1 ? 's' : ''} remaining"),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card.outlined(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListTile(
                  leading: const Icon(
                    Icons.circle_outlined,
                    size: 64,
                  ),
                  title:
                      Text(currentTask.title, textScaler: TextScaler.linear(2)),
                  subtitle: Text(
                    currentTask.description,
                    textScaler: TextScaler.linear(1.2),
                  ),
                ),
              ),
            ),
          ),
          if (currentTask.maxDuration != null ||
              currentTask.minDuration != null)
            TimerFulfillmentWidget(
              minDurationMinutes: currentTask.minDuration,
              maxDurationMinutes: currentTask.maxDuration,
              onFulfillmentSuccessful: () {
                markTaskFulfillment(true);
                nextPage();
              },
              onFulfillmentFailed: () {
                markTaskFulfillment(false);
                nextPage();
              },
              onTimerStarted: () {
                setState(() {
                  timerStarted = true;
                });
              },
            ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              spacing: 8,
              children: [
                if (!timerStarted)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                            onPressed: () {
                              nextPage(true);
                            },
                            child: Text("Skip")),
                      ),
                    ],
                  ),
                if (!isTimeBased)
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                            onPressed: () {
                              markTaskFulfillment(true);
                              nextPage();
                            },
                            child: Text("Complete")),
                      ),
                    ],
                  ),
              ],
            ),
          )
        ],
      );
    }
  }

  void markTaskFulfillment(bool status) {
    if (!status) unfulfilledTasks++;
    BlocProvider.of<TaskFulfillmentBloc>(context)
        .add(TaskFulfillmentRequested(mgr.Task.mock(currentTask.id), status));
  }

  void nextPage([bool skipped = false]) {
    setState(() {
      timerStarted = false;
      if (skipped || currentPage == -1) {
        currentPage++;
      } else {
        tasksRemaining.removeAt(currentPage);
      }
      if (currentPage >= tasksRemaining.length) {
        currentPage = 0;
      }
    });
  }
}
