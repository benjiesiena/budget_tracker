import 'package:flutter/foundation.dart';

import '../../../infrastructure/ai/runtime/ai_engine.dart';
import '../../../infrastructure/ai/tools/ai_response_validator.dart';
import '../../../infrastructure/ai/tools/financial_tools_registry.dart';
import 'ai_message.dart';

/// The AI Orchestrator from PRD 4.2 / 6.1 ("Conversation Manager, Intent
/// Detection, Tool Router" + "Response Validator"). This is the single
/// entry point the chat UI calls — it never talks to the engine or the
/// tools directly, so swapping the rule-based engine for a real on-device
/// model only requires a different [AIEngine] implementation.
class AIOrchestrator {
  AIOrchestrator({
    required this.engine,
    required this.toolsRegistry,
    this.validator = const AIResponseValidator(),
  });

  final AIEngine engine;
  final FinancialToolsRegistry toolsRegistry;
  final AIResponseValidator validator;

  /// Sends one user turn through the full pipeline: plan tool calls -> run
  /// tools -> generate response -> validate. Returns the assistant's
  /// message plus which tools were actually used, so the UI can show
  /// "Based on: get_current_balance, ..." if desired.
  Future<AIMessage> sendMessage({
    required String userMessage,
    required int conversationId,
    required List<AIEngineMessage> history,
  }) async {
    final tools = toolsRegistry.buildTools();
    final toolsByName = {for (final t in tools) t.name: t};

    final decision = await engine.planToolCalls(
      userMessage: userMessage,
      availableTools: tools,
      conversationHistory: history,
    );

    final toolResults = <String, Map<String, dynamic>>{};
    for (final toolName in decision.toolNamesToCall) {
      final tool = toolsByName[toolName];
      if (tool == null) continue;
      final args = decision.toolArgs[toolName] ?? const {};
      final result = await tool.execute(args);
      // ToolResult.toJson() returns {success, data, error} as an envelope.
      // Every response template in RuleBasedAIEngine reads fields flat
      // (e.g. result['balance']), not nested under 'data' — storing the
      // envelope directly meant every numeric field silently read as null
      // and fell back to 0 everywhere. Unwrap here, once, rather than
      // fixing every template's field access individually.
      toolResults[toolName] = result.success ? result.data : {'error': result.error ?? 'Tool call failed.'};
    }

    final responseText = await engine.generateResponse(
      userMessage: userMessage,
      toolResults: toolResults,
      conversationHistory: history,
    );

    final validation = validator.validate(
      response: responseText,
      toolResults: toolResults,
      questionNeedsData: decision.toolNamesToCall.isNotEmpty,
    );

    final finalText = validation.isValid
        ? responseText
        : "I want to double-check that before answering — could you rephrase the question?";

    if (!validation.isValid) {
      // The reason stays in the debug log only — a user shouldn't see
      // implementation details like "figure not found in tool result" in
      // the middle of a chat conversation.
      debugPrint('AI response failed validation: ${validation.error}');
    }

    return AIMessage(
      conversationId: conversationId,
      role: AIMessageRole.assistant,
      content: finalText,
      toolCallNames: decision.toolNamesToCall,
      createdAt: DateTime.now(),
    );
  }

  /// A handful of pre-filled prompts for the quick-action chips in the UI
  /// (PRD screen 9.9). Kept here, not hardcoded in the widget, so they stay
  /// aligned with what the intent detector can actually route.
  static const List<String> quickActions = [
    'Can I afford to spend ₱2,000 this weekend?',
    'Where did I spend the most this month?',
    'How am I doing on my budget?',
    'How can I save more?',
  ];
}
