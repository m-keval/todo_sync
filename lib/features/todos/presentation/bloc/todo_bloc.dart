import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/todo.dart';
import '../../domain/usecases/add_todo.dart';
import '../../domain/usecases/delete_todo.dart';
import '../../domain/usecases/get_todos.dart';
import '../../domain/usecases/sync_todos.dart';
import '../../domain/usecases/update_todo.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodos getTodos;
  final AddTodo addTodo;
  final UpdateTodo updateTodo;
  final DeleteTodo deleteTodo;
  final SyncTodos syncTodos;

  TodoBloc({
    required this.getTodos,
    required this.addTodo,
    required this.updateTodo,
    required this.deleteTodo,
    required this.syncTodos,
  }) : super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<UpdateTodoEvent>(_onUpdateTodo);
    on<ToggleTodoStatus>(_onToggleTodoStatus);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<SyncOfflineTodos>(_onSyncOfflineTodos);
    on<SearchTodos>(_onSearchTodos);
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    final result = await getTodos(NoParams());
    result.fold(
      (failure) => emit(const TodoError('Failed to load todos')),
      (todos) => emit(TodoLoaded(todos: todos, allTodos: todos)),
    );
  }

  Future<void> _onAddTodo(AddTodoEvent event, Emitter<TodoState> emit) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      final currentTodos = currentState.todos;
      final currentAllTodos = currentState.allTodos;

      final result = await addTodo(AddTodoParams(event.todo));
      result.fold((failure) => emit(const TodoError('Failed to add todo')), (
        newTodo,
      ) {
        final newAllTodos = List<Todo>.from(currentAllTodos)..add(newTodo);
        final newTodos = List<Todo>.from(currentTodos)..add(newTodo);
        emit(TodoLoaded(
          todos: newTodos,
          allTodos: newAllTodos,
          lastSyncedAt: currentState.lastSyncedAt,
        ));
      });
    }
  }

  Future<void> _onUpdateTodo(
    UpdateTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      final currentTodos = currentState.todos;
      final currentAllTodos = currentState.allTodos;

      final updatedList =
          currentTodos
              .map(
                (t) => t.localId == event.todo.localId ? event.todo : t,
              )
              .toList();
      final updatedAllList =
          currentAllTodos
              .map(
                (t) => t.localId == event.todo.localId ? event.todo : t,
              )
              .toList();

      emit(
        TodoLoaded(
          todos: updatedList,
          allTodos: updatedAllList,
          lastSyncedAt: currentState.lastSyncedAt,
        ),
      );

      final result = await updateTodo(UpdateTodoParams(event.todo));
      result.fold(
        (failure) {
          emit(const TodoError('Failed to update todo'));
          add(LoadTodos());
        },
        (syncedTodo) {
          final finalizedList =
              updatedList
                  .map(
                    (t) =>
                        t.localId == syncedTodo.localId ? syncedTodo : t,
                  )
                  .toList();
          final finalizedAllList =
              updatedAllList
                  .map(
                    (t) =>
                        t.localId == syncedTodo.localId ? syncedTodo : t,
                  )
                  .toList();
          emit(
            TodoLoaded(
              todos: finalizedList,
              allTodos: finalizedAllList,
              lastSyncedAt: currentState.lastSyncedAt,
            ),
          );
        },
      );
    }
  }

  Future<void> _onToggleTodoStatus(
    ToggleTodoStatus event,
    Emitter<TodoState> emit,
  ) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      final currentTodos = currentState.todos;
      final currentAllTodos = currentState.allTodos;

      final updatedTodo = Todo(
        localId: event.todo.localId,
        serverId: event.todo.serverId,
        title: event.todo.title,
        completed: !event.todo.completed,
        isSynced: false,
        updatedAt: DateTime.now(),
      );

      final updatedList = currentTodos
          .map((t) => t.localId == event.todo.localId ? updatedTodo : t)
          .toList();
      final updatedAllList = currentAllTodos
          .map((t) => t.localId == event.todo.localId ? updatedTodo : t)
          .toList();
      
      emit(TodoLoaded(
        todos: updatedList,
        allTodos: updatedAllList,
        lastSyncedAt: currentState.lastSyncedAt,
      ));

      final result = await updateTodo(UpdateTodoParams(updatedTodo));
      result.fold(
        (failure) {
          emit(const TodoError('Failed to update todo'));
          add(LoadTodos());
        },
        (syncedTodo) {
          final finalizedList = updatedList
              .map((t) => t.localId == syncedTodo.localId ? syncedTodo : t)
              .toList();
          final finalizedAllList = updatedAllList
              .map((t) => t.localId == syncedTodo.localId ? syncedTodo : t)
              .toList();
          emit(TodoLoaded(
            todos: finalizedList,
            allTodos: finalizedAllList,
            lastSyncedAt: currentState.lastSyncedAt,
          ));
        },
      );
    }
  }

  Future<void> _onDeleteTodo(
    DeleteTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      final currentTodos = currentState.todos;
      final currentAllTodos = currentState.allTodos;

      final updatedList = currentTodos
          .where((t) => t.localId != event.todo.localId)
          .toList();
      final updatedAllList = currentAllTodos
          .where((t) => t.localId != event.todo.localId)
          .toList();
      emit(TodoLoaded(
        todos: updatedList,
        allTodos: updatedAllList,
        lastSyncedAt: currentState.lastSyncedAt,
      ));

      final result = await deleteTodo(DeleteTodoParams(event.todo));
      result.fold((failure) {
        emit(const TodoError('Failed to delete todo'));
        add(LoadTodos());
      }, (_) {});
    }
  }

  Future<void> _onSyncOfflineTodos(
    SyncOfflineTodos event,
    Emitter<TodoState> emit,
  ) async {
    await syncTodos(NoParams());
    
    final result = await getTodos(NoParams());
    result.fold(
      (failure) => emit(const TodoError('Failed to load todos')),
      (todos) => emit(TodoLoaded(
        todos: todos, 
        allTodos: todos,
        lastSyncedAt: DateTime.now(),
      )),
    );
  }

  void _onSearchTodos(SearchTodos event, Emitter<TodoState> emit) {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        emit(TodoLoaded(
          todos: currentState.allTodos,
          allTodos: currentState.allTodos,
          lastSyncedAt: currentState.lastSyncedAt,
        ));
      } else {
        final filtered = currentState.allTodos.where((todo) {
          return todo.title.toLowerCase().contains(query);
        }).toList();
        emit(TodoLoaded(
          todos: filtered,
          allTodos: currentState.allTodos,
          lastSyncedAt: currentState.lastSyncedAt,
        ));
      }
    }
  }
}
