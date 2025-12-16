import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';
import '../pages/add_todo_sheet.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({super.key, required this.todo});

  void _onEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTodoSheet(todo: todo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor, 
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onEdit(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    context.read<TodoBloc>().add(ToggleTodoStatus(todo));
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: todo.completed ? colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: todo.completed 
                            ? colorScheme.primary 
                            : colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: todo.completed
                        ? Icon(Icons.check, size: 16, color: colorScheme.onPrimary)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    todo.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      decoration: todo.completed ? TextDecoration.lineThrough : null,
                      color: todo.completed 
                          ? colorScheme.onSurface.withOpacity(0.5) 
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                if (!todo.isSynced)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(
                      Icons.cloud_off, 
                      color: colorScheme.secondary,
                      size: 16,
                    ),
                  ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    context.read<TodoBloc>().add(DeleteTodoEvent(todo));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
