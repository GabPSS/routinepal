import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routinepal/src/task_overview/bloc/task_overview_bloc.dart';
import 'package:routinepal_manager/routinepal_manager.dart';

class TaskOverviewWidget extends StatelessWidget {
  const TaskOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Overview',
            textScaler: TextScaler.linear(1.8),
          ),
          BlocBuilder<TaskOverviewBloc, TaskOverviewState>(
            builder: (context, state) {
              if (state is TaskOverviewEmpty) {
                return const SizedBox(
                    height: 120,
                    child: Center(child: Text('No tasks available')));
              } else if (state is TaskOverviewLoaded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      state.tasks.map((task) => TaskWidget(task)).toList(),
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}

class TaskWidget extends StatelessWidget {
  final Task task;
  final Function()? onTaskTapped;

  const TaskWidget(
    this.task, {
    this.onTaskTapped,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTaskTapped,
      title: Text(task.title),
      subtitle: Text(task.description),
      leading: Icon(
        task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
        size: 48,
      ),
    );
  }
}
