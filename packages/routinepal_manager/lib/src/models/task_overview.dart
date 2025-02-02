import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int id;
  final String title;
  final String description;
  final int? minDuration;
  final int? maxDuration;
  final int totalTasks;
  final int completedTasks;
  final bool? isFulfilled;

  const Task({
    required this.id,
    required this.title,
    String? description,
    this.minDuration,
    this.maxDuration,
    required this.totalTasks,
    required this.isFulfilled,
    required this.completedTasks,
  }) : description = description ?? "$completedTasks of $totalTasks completed";

  bool get isGroup => totalTasks > 1;

  @override
  List<Object?> get props =>
      [id, title, description, totalTasks, completedTasks];
}
