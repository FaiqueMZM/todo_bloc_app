import 'package:equatable/equatable.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

class AddTaskEvent extends TodoEvent {
  final String title;

  const AddTaskEvent(this.title);

  @override
  List<Object> get props => [title];
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
