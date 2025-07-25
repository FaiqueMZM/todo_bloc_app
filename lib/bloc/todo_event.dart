import 'package:equatable/equatable.dart';
import 'package:todo_app/tasks.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

class AddTaskEvent extends TodoEvent {
  final String title;
  final Category category;
  final DateTime? dueDate;

  const AddTaskEvent(this.title, {required this.category, this.dueDate});

  @override
  List<Object> get props => [title, category, dueDate ?? Object()];
}

class ToggleTaskEvent extends TodoEvent {
  final String id;

  const ToggleTaskEvent(this.id);

  @override
  List<Object> get props => [id];
}

class DeleteTaskEvent extends TodoEvent {
  final String id;

  const DeleteTaskEvent(this.id);

  @override
  List<Object> get props => [id];
}

class ClearCompletedTasksEvent extends TodoEvent {
  const ClearCompletedTasksEvent();

  @override
  List<Object> get props => [];
}

class FilterTasksByCategoryEvent extends TodoEvent {
  final Category? category;

  const FilterTasksByCategoryEvent(this.category);

  @override
  List<Object> get props => [category ?? Object()];
}

class EditTaskEvent extends TodoEvent {
  final String id;
  final String title;
  final Category category;
  final DateTime? dueDate;

  const EditTaskEvent({
    required this.id,
    required this.title,
    required this.category,
    this.dueDate,
  });

  @override
  List<Object> get props => [id, title, category, dueDate ?? Object()];
}