import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String localId;
  final int? serverId;
  final String title;
  final bool completed;
  final bool isSynced;
  final DateTime updatedAt;

  const Todo({
    required this.localId,
    this.serverId,
    required this.title,
    required this.completed,
    required this.isSynced,
    required this.updatedAt,
  });

  Todo copyWith({
    String? localId,
    int? serverId,
    String? title,
    bool? completed,
    bool? isSynced,
    DateTime? updatedAt,
  }) {
    return Todo(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      isSynced: isSynced ?? this.isSynced,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        localId,
        serverId,
        title,
        completed,
        isSynced,
        updatedAt,
      ];
}
