import 'package:hive/hive.dart';
import '../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getLastTodos();
  Future<void> cacheTodos(List<TodoModel> todos);
  Future<void> addTodo(TodoModel todo);
  Future<void> updateTodo(TodoModel todo);
  Future<void> deleteTodo(String localId);
  Future<List<TodoModel>> getUnsyncedTodos();
  Future<void> cacheTodo(TodoModel todo);

  Future<void> addDeletedTodoId(String localId);
  Future<List<String>> getDeletedTodoIds();
  Future<void> removeDeletedTodoId(String localId);
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final Box<TodoModel> todoBox;
  final String _deletedTodosBox = 'deleted_todos';

  TodoLocalDataSourceImpl(this.todoBox);

  @override
  Future<List<TodoModel>> getLastTodos() async {
    return todoBox.values.toList();
  }

  @override
  Future<void> cacheTodos(List<TodoModel> todos) async {
    await todoBox.clear();
    for (final todo in todos) {
      await todoBox.put(todo.localId, todo);
    }
  }

  @override
  Future<void> cacheTodo(TodoModel todo) async {
    await todoBox.put(todo.localId, todo);
  }

  @override
  Future<void> addTodo(TodoModel todo) async {
    await todoBox.put(todo.localId, todo);
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    await todoBox.put(todo.localId, todo);
  }

  @override
  Future<void> deleteTodo(String localId) async {
    await todoBox.delete(localId);
  }

  @override
  Future<List<TodoModel>> getUnsyncedTodos() async {
    return todoBox.values.where((todo) => !todo.isSynced).toList();
  }

  @override
  Future<void> addDeletedTodoId(String localId) async {
    final deletedBox = await Hive.openBox<String>(_deletedTodosBox);
    await deletedBox.add(localId);
  }

  @override
  Future<List<String>> getDeletedTodoIds() async {
    final deletedBox = await Hive.openBox<String>(_deletedTodosBox);
    return deletedBox.values.toList();
  }

  @override
  Future<void> removeDeletedTodoId(String localId) async {
    final deletedBox = await Hive.openBox<String>(_deletedTodosBox);
    final map = deletedBox.toMap();
    final keysToDelete = <dynamic>[];
    
    map.forEach((key, value) {
      if (value == localId) {
        keysToDelete.add(key);
      }
    });

    for (final key in keysToDelete) {
      await deletedBox.delete(key);
    }
  }
}
