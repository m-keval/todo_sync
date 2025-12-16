part of 'todo_bloc.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object> get props => [];
}

class LoadTodos extends TodoEvent {}

class AddTodoEvent extends TodoEvent {
  final Todo todo;

  const AddTodoEvent(this.todo);

  @override
  List<Object> get props => [todo];
}

class UpdateTodoEvent extends TodoEvent {
  final Todo todo;

  const UpdateTodoEvent(this.todo);

  @override
  List<Object> get props => [todo];
}

class ToggleTodoStatus extends TodoEvent {
  final Todo todo;

  const ToggleTodoStatus(this.todo);

  @override
  List<Object> get props => [todo];
}

class DeleteTodoEvent extends TodoEvent {
  final Todo todo;

  const DeleteTodoEvent(this.todo);

  @override
  List<Object> get props => [todo];
}

class SyncOfflineTodos extends TodoEvent {}

class SearchTodos extends TodoEvent {
  final String query;

  const SearchTodos(this.query);

  @override
  List<Object> get props => [query];
}
