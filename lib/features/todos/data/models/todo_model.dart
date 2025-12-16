import 'package:hive/hive.dart';
import '../../domain/entities/todo.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends Todo {
  @HiveField(0)
  final String localId;
  @HiveField(1)
  final int? serverId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final bool completed;
  @HiveField(4)
  final bool isSynced;
  @HiveField(5)
  final DateTime updatedAt;

  const TodoModel({
    required this.localId,
    this.serverId,
    required this.title,
    required this.completed,
    required this.isSynced,
    required this.updatedAt,
  }) : super(
          localId: localId,
          serverId: serverId,
          title: title,
          completed: completed,
          isSynced: isSynced,
          updatedAt: updatedAt,
        );

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      localId: json['localId'] as String? ?? '',
      serverId: json['id'] as int?,
      title: json['title'] as String,
      completed: json['completed'] as bool,
      isSynced: true,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'completed': completed,
    };
  }

  factory TodoModel.fromEntity(Todo todo) {
    return TodoModel(
      localId: todo.localId,
      serverId: todo.serverId,
      title: todo.title,
      completed: todo.completed,
      isSynced: todo.isSynced,
      updatedAt: todo.updatedAt,
    );
  }
}
