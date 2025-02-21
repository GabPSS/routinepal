import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routinepal/src/task_fulfillment/bloc/task_fulfillment_bloc.dart';
import 'package:routinepal/src/app/view/dialogs/fulfillment_confirmation_dialog.dart';
import 'package:routinepal/src/task_fulfillment/view/task_widget.dart';
import 'package:routinepal/src/app/view/navigation/fulfillment_result_page.dart';
import 'package:routinepal/src/task_fulfillment/view/timer_fulfillment_widget.dart';
import 'package:routinepal_manager/routinepal_manager.dart';

class TaskFulfillmentPage extends StatefulWidget {
  final Task task;
  final Task? parent;

  const TaskFulfillmentPage(this.task, {this.parent, super.key});

  @override
  State<TaskFulfillmentPage> createState() => _TaskFulfillmentPageState();
}

class _TaskFulfillmentPageState extends State<TaskFulfillmentPage> {
  late Task task;
  bool timerRunning = false;

  bool get isSubtask => widget.parent != null;

  @override
  void initState() {
    super.initState();
    task = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !timerRunning,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !timerRunning,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TaskWidget(
                task,
                color: Colors.white,
                fontSize: 2,
                showSubtitle: false,
                isSubtask: isSubtask,
              ),
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
            if (!task.isGroup)
              ...buildGoalDescription()
            else
              ...buildSubtaskList(context),
            buildTimeLimitIndicators(),
            if (task.isFulfilled == fulfillable &&
                (task.minDuration != null || task.maxDuration != null))
              TimerFulfillmentWidget(
                  minDurationMinutes: task.minDuration,
                  maxDurationMinutes: task.maxDuration,
                  onTimerStarted: () => setState(() => timerRunning = true),
                  onFulfillmentSuccessful: fulfillTask,
                  onFulfillmentFailed: unfulfillTask)
            else if (task.isFulfilled == fulfillable && !task.isGroup)
              buildDefaultFulfillmentButton(context),
          ],
        ),
      ),
    );
  }

  List<Widget> buildSubtaskList(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text("Tasks:"),
      ),
      FutureBuilder<List<Task>>(
        future: RepositoryProvider.of<RoutinepalManager>(context)
            .getTasksPartOfGroup(task.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data != null) {
              return Column(
                children: snapshot.data!
                    .map((subTask) => TaskWidget(
                          subTask,
                          isSubtask: true,
                          fontSize: 1.4,
                          showSubtitle: true,
                          onTaskTapped: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => TaskFulfillmentPage(
                                      subTask,
                                      parent: task))),
                        ))
                    .toList(),
              );
            } else {
              return const Center(child: Text("No tasks found"));
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text("No tasks found"));
          }
        },
      ),
      //TODO: Add list of tasks. Maybe building from a future will be required in order to fetch the tasks, or at least a bloc.
    ];
  }

  Row buildTimeLimitIndicators() {
    return Row(
      children: [
        if (task.minDuration != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
          ),
        if (task.maxDuration != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
          ),
      ],
    );
  }

  List<Widget> buildGoalDescription() {
    return [
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text("The goal:"),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          task.description,
          textScaler: const TextScaler.linear(1.5),
        ),
      ),
    ];
  }

  void fulfillTask() {
    BlocProvider.of<TaskFulfillmentBloc>(context)
        .add(TaskFulfillmentRequested(task, true));
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => FulfillmentResultPage(
              itemID: task.id,
              name: task.title,
              status: true,
            )));
  }

  void unfulfillTask() {
    BlocProvider.of<TaskFulfillmentBloc>(context)
        .add(TaskFulfillmentRequested(task, false));

    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => FulfillmentResultPage(
              itemID: task.id,
              name: task.title,
              status: false,
            )));
  }

  Padding buildDefaultFulfillmentButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FilledButton(
        onPressed: () async {
          var confirmed = await showFulfillmentAlertDialog(context);
          if (confirmed == true && context.mounted) {
            fulfillTask();
          }
        },
        child: const Text('Fulfill Task', textScaler: TextScaler.linear(1.5)),
      ),
    );
  }
}
