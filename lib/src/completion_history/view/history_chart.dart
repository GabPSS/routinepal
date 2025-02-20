import 'package:flutter/material.dart';
import 'package:routinepal_api/routinepal_api.dart';

class HistoryChart extends StatelessWidget {
  final Map<DateTime, Map<TaskBase, TaskCompletion?>> taskCompletionsByDate;
  final List<String> tasks;

  int get length => taskCompletionsByDate.length;

  const HistoryChart(
      {required this.taskCompletionsByDate, required this.tasks, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        spacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              const SizedBox(height: 24),
              for (var task in tasks)
                SizedBox(
                    height: 24,
                    child:
                        Center(child: Text(task, textAlign: TextAlign.center)))
            ],
          ),
          for (var taskCompletionsSet in taskCompletionsByDate.entries) ...[
            Column(
              spacing: 16,
              children: [
                SizedBox(
                  height: 24,
                  child: Center(
                    child: Text(
                        "${taskCompletionsSet.key.day}/${taskCompletionsSet.key.month}",
                        textAlign: TextAlign.center),
                  ),
                ),
                for (var taskCompletion in taskCompletionsSet.value.values)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Center(
                      child: getIconForTaskCompletion(taskCompletion),
                    ),
                  )
              ],
            )
          ]
        ],
      ),
    );
  }

  Icon getIconForTaskCompletion(TaskCompletion? taskCompletion) {
    if (taskCompletion != null) {
      if (taskCompletion.isFulfilled) {
        return Icon(Icons.check_circle, color: Colors.green);
      } else {
        return Icon(Icons.error, color: Colors.red);
      }
    } else {
      return Icon(Icons.circle_outlined, color: Colors.grey);
    }
  }
}
