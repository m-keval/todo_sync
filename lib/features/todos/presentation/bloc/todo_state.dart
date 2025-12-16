part of 'todo_bloc.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;
  final List<Todo> allTodos;
  final DateTime? lastSyncedAt;

  const TodoLoaded({
    required this.todos,
    required this.allTodos,
    this.lastSyncedAt,
  });

  @override
  List<Object?> get props => [todos, allTodos, lastSyncedAt];
}

class TodoError extends TodoState {
  final String message;

  const TodoError(this.message);

  @override
  List<Object> get props => [message];
}
