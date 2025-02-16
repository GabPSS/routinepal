import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routinepal/src/task_overview/bloc/task_overview_bloc.dart';
import 'package:routinepal/ui/widgets/task_widget.dart';
import 'package:routinepal/src/task_fulfillment/view/task_fulfillment_page.dart';

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
                  children: state.tasks
                      .map((task) => TaskWidget(
                            task,
                            onTaskTapped: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TaskFulfillmentPage(task)));
                            },
                          ))
                      .toList(),
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
