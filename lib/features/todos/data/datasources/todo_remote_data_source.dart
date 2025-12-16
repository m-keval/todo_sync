import 'package:dio/dio.dart';
import '../../../../core/common/constants.dart';
import '../../../../core/error/failures.dart';
import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos();
  Future<TodoModel> addTodo(TodoModel todo);
  Future<TodoModel> updateTodo(TodoModel todo);
  Future<void> deleteTodo(int id);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final Dio dio;

  TodoRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TodoModel>> getTodos() async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.todosEndpoint}',
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => TodoModel.fromJson(e))
            .take(20)
            .toList();
      } else {
        throw ServerFailure('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Network error occurred');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<TodoModel> addTodo(TodoModel todo) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.todosEndpoint}',
        data: todo.toJson(),
      );
      if (response.statusCode == 201) {
        final newId = response.data['id'];
        return TodoModel(
          localId: todo.localId,
          serverId: newId,
          title: todo.title,
          completed: todo.completed,
          isSynced: true,
          updatedAt: DateTime.now(),
        );
      } else {
        throw ServerFailure('Failed to add todo: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Network error occurred');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.baseUrl}${ApiConstants.todosEndpoint}/${todo.serverId}',
        data: todo.toJson(),
      );
      if (response.statusCode == 200) {
        return todo;
      } else {
        throw ServerFailure('Failed to update todo: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Network error occurred');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    try {
      final response = await dio.delete(
        '${ApiConstants.baseUrl}${ApiConstants.todosEndpoint}/$id',
      );
      if (response.statusCode != 200) {
        throw ServerFailure('Failed to delete todo: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Network error occurred');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
