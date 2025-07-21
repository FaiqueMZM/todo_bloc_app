import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/bloc/todo_event.dart';
import 'package:todo_app/bloc/todo_state.dart';
import 'package:todo_app/tasks.dart';
import 'package:uuid/uuid.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final List<Task> _tasks = [];

  TodoBloc() : super(TodoInitial()) {
    on<AddTaskEvent>((event, emit) {
      if (event.title.isNotEmpty) {
        final task = Task(
          id: const Uuid().v4(),
          title: event.title,
          isCompleted: false,
        );
        _tasks.add(task);
        emit(TodoLoaded(List.from(_tasks)));
      } else {
        emit(const TodoError('Task title cannot be empty'));
      }
    });

    on<ToggleTaskEvent>((event, emit) {
      final index = _tasks.indexWhere((task) => task.id == event.id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          isCompleted: !_tasks[index].isCompleted,
        );
        emit(TodoLoaded(List.from(_tasks)));
      }
    });

    on<DeleteTaskEvent>((event, emit) {
      _tasks.removeWhere((task) => task.id == event.id);
      emit(TodoLoaded(List.from(_tasks)));
    });
  }
}
