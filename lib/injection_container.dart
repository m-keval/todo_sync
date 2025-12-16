import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'core/network/network_info.dart';
import 'features/todos/data/datasources/todo_local_data_source.dart';
import 'features/todos/data/datasources/todo_remote_data_source.dart';
import 'features/todos/data/models/todo_model.dart';
import 'features/todos/data/repositories/todo_repository_impl.dart';
import 'features/todos/domain/repositories/todo_repository.dart';
import 'features/todos/domain/usecases/add_todo.dart';
import 'features/todos/domain/usecases/delete_todo.dart';
import 'features/todos/domain/usecases/get_todos.dart';
import 'features/todos/domain/usecases/sync_todos.dart';
import 'features/todos/domain/usecases/update_todo.dart';
import 'features/todos/presentation/bloc/todo_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(
    () => TodoBloc(
      getTodos: sl(),
      addTodo: sl(),
      updateTodo: sl(),
      deleteTodo: sl(),
      syncTodos: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetTodos(sl()));
  sl.registerLazySingleton(() => AddTodo(sl()));
  sl.registerLazySingleton(() => UpdateTodo(sl()));
  sl.registerLazySingleton(() => DeleteTodo(sl()));
  sl.registerLazySingleton(() => SyncTodos(sl()));

  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TodoRemoteDataSource>(
    () => TodoRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  final todoBox = Hive.box<TodoModel>('todos');
  sl.registerLazySingleton(() => todoBox);

  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => InternetConnectionChecker());
}
