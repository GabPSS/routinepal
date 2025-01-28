import 'package:equatable/equatable.dart';

/// A basic task model class
class Task extends Equatable {
  final int id;
  final String title;
  final String description;

  const Task({
    required this.id,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [id, title, description];
}
