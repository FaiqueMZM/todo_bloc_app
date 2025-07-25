import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/bloc/todo_event.dart';
import 'package:todo_app/bloc/todo_state.dart';
import 'package:todo_app/tasks.dart';
import 'package:intl/intl.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    Category selectedCategory = Category.others;
    DateTime? selectedDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () =>
                context.read<TodoBloc>().add(const ClearCompletedTasksEvent()),
            tooltip: 'Clear completed tasks',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'Enter a task',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          context.read<TodoBloc>().add(
                            AddTaskEvent(
                              controller.text,
                              category: selectedCategory,
                              dueDate: selectedDate,
                            ),
                          );
                          controller.clear();
                          selectedDate = null;
                        }
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<Category>(
                        value: selectedCategory,
                        isExpanded: true,
                        items: Category.values
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category.toString().split('.').last,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            selectedCategory = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          selectedDate = pickedDate;
                        }
                      },
                      child: Text(
                        selectedDate == null
                            ? 'Set Due Date'
                            : DateFormat('MMM d, yyyy').format(selectedDate!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                Category? filterCategory;
                if (state is TodoLoaded) {
                  filterCategory = state.filterCategory;
                }
                return DropdownButton<Category?>(
                  value: filterCategory,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...Category.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.toString().split('.').last),
                          ),
                        )
                        .toList(),
                  ],
                  onChanged: (value) {
                    context.read<TodoBloc>().add(
                      FilterTasksByCategoryEvent(value),
                    );
                  },
                  hint: const Text('Filter by category'),
                );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                if (state is TodoInitial) {
                  return const Center(child: Text('No tasks yet.'));
                } else if (state is TodoLoaded) {
                  return ListView.builder(
                    itemCount: state.tasks.length,
                    itemBuilder: (context, index) {
                      final task = state.tasks[index];
                      return ListTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) => context.read<TodoBloc>().add(
                            ToggleTaskEvent(task.id),
                          ),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category: ${task.category.toString().split('.').last}',
                            ),
                            if (task.dueDate != null)
                              Text(
                                'Due: ${DateFormat('MMM d, yyyy').format(task.dueDate!)}',
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => context.read<TodoBloc>().add(
                            DeleteTaskEvent(task.id),
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is TodoError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
