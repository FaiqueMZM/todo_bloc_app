import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/bloc/todo_bloc.dart';
import 'package:todo_app/bloc/todo_event.dart';
import 'package:todo_app/bloc/todo_state.dart';
import 'package:todo_app/tasks.dart';
import 'package:intl/intl.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final tabController = TabController(length: 4, vsync: this);

    void showAddTaskDialog() {
      final TextEditingController controller = TextEditingController();
      Category selectedCategory = Category.others;
      DateTime? selectedDate;

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Add Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButton<Category>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: Category.values
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category.toString().split('.').last),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setDialogState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Text(
                    selectedDate == null
                        ? 'Set Due Date'
                        : DateFormat('MMM d, yyyy').format(selectedDate!),
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    context.read<TodoBloc>().add(
                      AddTaskEvent(
                        controller.text,
                        category: selectedCategory,
                        dueDate: selectedDate,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      );
    }

    void showEditTaskDialog(Task task) {
      final editController = TextEditingController(text: task.title);
      Category editCategory = task.category;
      DateTime? editDueDate = task.dueDate;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editController,
                decoration: const InputDecoration(
                  labelText: 'Task title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButton<Category>(
                value: editCategory,
                isExpanded: true,
                items: Category.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.toString().split('.').last),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      editCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: editDueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      editDueDate = pickedDate;
                    });
                  }
                },
                child: Text(
                  editDueDate == null
                      ? 'Set Due Date'
                      : DateFormat('MMM d, yyyy').format(editDueDate!),
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  context.read<TodoBloc>().add(
                    EditTaskEvent(
                      id: task.id,
                      title: editController.text,
                      category: editCategory,
                      dueDate: editDueDate,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    void showDeleteConfirmationDialog(String taskId) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<TodoBloc>().add(DeleteTaskEvent(taskId));
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

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
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Work'),
            Tab(text: 'Personal'),
            Tab(text: 'Others'),
          ],
          onTap: (index) {
            Category? filterCategory;
            if (index > 0) {
              filterCategory = Category.values[index - 1];
            }
            context.read<TodoBloc>().add(
              FilterTasksByCategoryEvent(filterCategory),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoInitial) {
            return const Center(child: Text('No tasks yet.'));
          } else if (state is TodoLoaded) {
            if (state.tasks.isEmpty) {
              return const Center(child: Text('No tasks available.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
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
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category: ${task.category.toString().split('.').last}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        if (task.dueDate != null)
                          Text(
                            'Due: ${DateFormat('MMM d, yyyy').format(task.dueDate!)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: task.dueDate!.isBefore(DateTime.now())
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => showEditTaskDialog(task),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              showDeleteConfirmationDialog(task.id),
                        ),
                      ],
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
    );
  }
}
