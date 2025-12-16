import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_data_source.dart';
import '../datasources/todo_remote_data_source.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource;
  final TodoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TodoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Todo>>> getTodos() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.getTodos().then((remoteTodos) async {
          final currentLocalTodos = await localDataSource.getLastTodos();

          TodoModel? findLocalByServerId(int serverId) {
            try {
              return currentLocalTodos.firstWhere(
                (t) => t.serverId == serverId,
              );
            } catch (_) {
              return null;
            }
          }

          for (var remoteTodo in remoteTodos) {
            final localMatch = findLocalByServerId(remoteTodo.serverId!);

            if (localMatch == null) {
              final newLocalTodo = TodoModel(
                localId: const Uuid().v4(),
                serverId: remoteTodo.serverId,
                title: remoteTodo.title,
                completed: remoteTodo.completed,
                isSynced: true,
                updatedAt: DateTime.now(),
              );
              await localDataSource.cacheTodo(newLocalTodo);
            }
          }
        }).catchError((_) {});
      }

      final localTodos = await localDataSource.getLastTodos();
      return Right(localTodos);
    } catch (e) {
      return const Left(CacheFailure('Unable to load tasks'));
    }
  }

  @override
  Future<Either<Failure, Todo>> addTodo(Todo todo) async {
    final todoModel = TodoModel.fromEntity(todo);

    try {
      await localDataSource.addTodo(todoModel);

      if (await networkInfo.isConnected) {
        try {
          final result = await remoteDataSource.addTodo(todoModel);
          await localDataSource.updateTodo(result);
          return Right(result);
        } catch (e) {
          return Right(todoModel);
        }
      } else {
        return Right(todoModel);
      }
    } catch (e) {
      return const Left(CacheFailure('Unable to add task'));
    }
  }

  @override
  Future<Either<Failure, Todo>> updateTodo(Todo todo) async {
    final todoModel = TodoModel(
      localId: todo.localId,
      serverId: todo.serverId,
      title: todo.title,
      completed: todo.completed,
      isSynced: false,
      updatedAt: DateTime.now(),
    );

    try {
      await localDataSource.updateTodo(todoModel);

      if (await networkInfo.isConnected) {
        try {
          if (todoModel.serverId != null) {
            final result = await remoteDataSource.updateTodo(todoModel);
            final syncedTodo = TodoModel(
              localId: result.localId,
              serverId: result.serverId,
              title: result.title,
              completed: result.completed,
              isSynced: true,
              updatedAt: result.updatedAt,
            );
            await localDataSource.updateTodo(syncedTodo);
            return Right(syncedTodo);
          } else {
            final result = await remoteDataSource.addTodo(todoModel);
            await localDataSource.updateTodo(result);
            return Right(result);
          }
        } catch (e) {
          return Right(todoModel);
        }
      } else {
        return Right(todoModel);
      }
    } catch (e) {
      return const Left(CacheFailure('Unable to update task'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTodo(Todo todo) async {
    try {
      await localDataSource.deleteTodo(todo.localId);
      await localDataSource.addDeletedTodoId(todo.localId);

      if (await networkInfo.isConnected) {
        if (todo.serverId != null) {
          await remoteDataSource
              .deleteTodo(todo.serverId!)
              .then((_) => localDataSource.removeDeletedTodoId(todo.localId))
              .catchError((_) {});
        } else {
          await localDataSource.removeDeletedTodoId(todo.localId);
        }
      }
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Unable to delete task'));
    }
  }

  @override
  Future<Either<Failure, void>> syncTodos() async {
    if (await networkInfo.isConnected) {
      try {
        final unsynced = await localDataSource.getUnsyncedTodos();
        for (var todo in unsynced) {
          try {
            if (todo.serverId == null) {
              final result = await remoteDataSource.addTodo(todo);
              await localDataSource.updateTodo(result);
            } else {
              final result = await remoteDataSource.updateTodo(todo);
              final synced = TodoModel(
                localId: result.localId,
                serverId: result.serverId,
                title: result.title,
                completed: result.completed,
                isSynced: true,
                updatedAt: result.updatedAt,
              );
              await localDataSource.updateTodo(synced);
            }
          } catch (_) {
            continue;
          }
        }
        return const Right(null);
      } catch (e) {
        return const Left(ServerFailure('Unable to sync tasks'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
