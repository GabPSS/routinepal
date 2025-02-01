import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int id;
  final String title;
  final String description;
  final int totalTasks;
  final int completedTasks;

  const Task({
    required this.id,
    required this.title,
    String? description,
    required this.totalTasks,
    required this.completedTasks,
  }) : description = description ?? "$completedTasks of $totalTasks completed";

  bool get isGroup => totalTasks > 1;
  bool get isCompleted => completedTasks == totalTasks;

  @override
  List<Object?> get props =>
      [id, title, description, totalTasks, completedTasks];
}
