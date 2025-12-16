import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class DeleteTodo implements UseCase<void, DeleteTodoParams> {
  final TodoRepository repository;

  DeleteTodo(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTodoParams params) async {
    return await repository.deleteTodo(params.todo);
  }
}

class DeleteTodoParams extends Equatable {
  final Todo todo;

  const DeleteTodoParams(this.todo);

  @override
  List<Object> get props => [todo];
}
