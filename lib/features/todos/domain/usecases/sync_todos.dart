import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/todo_repository.dart';

class SyncTodos implements UseCase<void, NoParams> {
  final TodoRepository repository;

  SyncTodos(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.syncTodos();
  }
}
