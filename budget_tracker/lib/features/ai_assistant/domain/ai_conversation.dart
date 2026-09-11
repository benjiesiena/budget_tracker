import "package:equatable/equatable.dart";
import "ai_message.dart";

class AIConversation extends Equatable {
  final int? id;
  final int userId;
  final String? title;
  final List<AIMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AIConversation({
    this.id,
    required this.userId,
    this.title,
    this.messages = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  AIConversation copyWith({List<AIMessage>? messages, DateTime? updatedAt}) => AIConversation(
        id: id,
        userId: userId,
        title: title,
        messages: messages ?? this.messages,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [id, userId, title, messages];
}
