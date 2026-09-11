import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/ai/runtime/ai_engine.dart';
import '../../../../shared/presentation/providers/app_providers.dart';
import '../../domain/ai_message.dart';

class AIChatState {
  final List<AIMessage> messages;
  final bool isResponding;

  const AIChatState({this.messages = const [], this.isResponding = false});

  AIChatState copyWith({List<AIMessage>? messages, bool? isResponding}) {
    return AIChatState(
      messages: messages ?? this.messages,
      isResponding: isResponding ?? this.isResponding,
    );
  }
}

/// In-memory chat state for the current session. A real build would persist
/// each [AIMessage] to the `ai_conversations`/`ai_messages` tables (schema
/// already defined — see V1__initial_schema.sql) so history survives app
/// restarts; that's a straightforward repository to add on top of this
/// notifier without touching the orchestrator or the UI.
class AIChatNotifier extends Notifier<AIChatState> {
  static const _conversationId = 1;

  @override
  AIChatState build() => const AIChatState();

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isResponding) return;

    final userMessage = AIMessage(
      conversationId: _conversationId,
      role: AIMessageRole.user,
      content: text.trim(),
      createdAt: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, userMessage], isResponding: true);

    final orchestrator = ref.read(aiOrchestratorProvider);
    final history =
        state.messages.map((m) => AIEngineMessage(role: m.role.name, content: m.content)).toList();

    try {
      final reply = await orchestrator.sendMessage(
        userMessage: text.trim(),
        conversationId: _conversationId,
        history: history,
      );
      state = state.copyWith(messages: [...state.messages, reply], isResponding: false);
    } catch (_) {
      final fallback = AIMessage(
        conversationId: _conversationId,
        role: AIMessageRole.assistant,
        content: 'Something went wrong answering that — please try again.',
        createdAt: DateTime.now(),
      );
      state = state.copyWith(messages: [...state.messages, fallback], isResponding: false);
    }
  }
}

final aiChatProvider = NotifierProvider<AIChatNotifier, AIChatState>(AIChatNotifier.new);
