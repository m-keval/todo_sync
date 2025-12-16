import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';

class AddTodoSheet extends StatefulWidget {
  final Todo? todo;

  const AddTodoSheet({super.key, this.todo});

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.todo?.title ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.todo != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                isEditing ? 'Edit Task' : 'New Task',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              labelText: 'What needs to be done?',
              hintText: 'e.g., Buy groceries',
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            child: Text(
              isEditing ? 'Save Changes' : 'Add Task',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_controller.text.isEmpty) return;

    if (widget.todo != null) {
      final updatedTodo = widget.todo!.copyWith(
        title: _controller.text,
        isSynced: false,
        updatedAt: DateTime.now(),
      );
      context.read<TodoBloc>().add(UpdateTodoEvent(updatedTodo));
    } else {
      final newTodo = Todo(
        localId: const Uuid().v4(),
        title: _controller.text,
        completed: false,
        isSynced: false,
        updatedAt: DateTime.now(),
      );
      context.read<TodoBloc>().add(AddTodoEvent(newTodo));
    }
    Navigator.of(context).pop();
  }
}
