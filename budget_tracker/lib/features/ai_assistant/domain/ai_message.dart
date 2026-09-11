import "package:equatable/equatable.dart";

enum AIMessageRole { user, assistant, system }

class AIMessage extends Equatable {
  final int? id;
  final int conversationId;
  final AIMessageRole role;
  final String content;
  final List<String> toolCallNames;
  final DateTime createdAt;

  const AIMessage({
    this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.toolCallNames = const [],
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, conversationId, role, content, createdAt];
}
