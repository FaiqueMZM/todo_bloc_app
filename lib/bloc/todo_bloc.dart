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
          category: event.category,
          dueDate: event.dueDate,
        );
        _tasks.add(task);
        emit(TodoLoaded(List.from(_tasks), filterCategory: state is TodoLoaded ? (state as TodoLoaded).filterCategory : null));
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
        emit(TodoLoaded(List.from(_tasks), filterCategory: state is TodoLoaded ? (state as TodoLoaded).filterCategory : null));
      }
    });

    on<DeleteTaskEvent>((event, emit) {
      _tasks.removeWhere((task) => task.id == event.id);
      emit(TodoLoaded(List.from(_tasks), filterCategory: state is TodoLoaded ? (state as TodoLoaded).filterCategory : null));
    });

    on<ClearCompletedTasksEvent>((event, emit) {
      _tasks.removeWhere((task) => task.isCompleted);
      emit(TodoLoaded(List.from(_tasks), filterCategory: state is TodoLoaded ? (state as TodoLoaded).filterCategory : null));
    });

    on<FilterTasksByCategoryEvent>((event, emit) {
      if (event.category == null) {
        emit(TodoLoaded(List.from(_tasks)));
      } else {
        final filteredTasks = _tasks.where((task) => task.category == event.category).toList();
        emit(TodoLoaded(filteredTasks, filterCategory: event.category));
      }
    });
  }
}