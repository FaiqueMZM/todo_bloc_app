import 'package:equatable/equatable.dart';

enum Category { work, personal, others }

class Task extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;
  final Category category;
  final DateTime? dueDate;

  const Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.category = Category.others,
    this.dueDate,
  });

  Task copyWith({
    String? title,
    bool? isCompleted,
    Category? category,
    DateTime? dueDate,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted, category, dueDate];
}
