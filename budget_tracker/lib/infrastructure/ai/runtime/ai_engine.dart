import '../tools/ai_tool.dart';

/// A single exchange the engine needs to reason about tool selection.
class AIEngineMessage {
  final String role; // 'user' | 'assistant' | 'system'
  final String content;
  const AIEngineMessage({required this.role, required this.content});
}

/// What the engine decided to do with a user turn: call zero or more tools,
/// then produce a natural-language reply once tool results are available.
class AIEngineDecision {
  final List<String> toolNamesToCall;
  final Map<String, Map<String, dynamic>> toolArgs;

  const AIEngineDecision({required this.toolNamesToCall, this.toolArgs = const {}});
}

/// Abstraction over "whatever runs the model". The production implementation
/// would bundle a quantized transformer SLM via an on-device inference
/// runtime (e.g. tflite_flutter or ML Kit — deliberately left out of this
/// scaffold; see pubspec.yaml for why) and load it through a ModelManager.
/// That binary can't be built or shipped from this scaffold, so
/// [RuleBasedAIEngine] stands in as a fully offline, deterministic
/// implementation of the *same* interface. Swapping the real model in later
/// means implementing this interface — nothing above it (orchestrator, UI,
/// tools) needs to change.
abstract class AIEngine {
  /// True once the engine is ready to answer (model loaded, or — for the
  /// rule-based engine — always true).
  Future<bool> get isReady;

  /// Decides which tool(s), if any, are needed to answer [userMessage].
  Future<AIEngineDecision> planToolCalls({
    required String userMessage,
    required List<AITool> availableTools,
    required List<AIEngineMessage> conversationHistory,
  });

  /// Produces the final natural-language reply given the tool results that
  /// were gathered for [userMessage]. Implementations must only reference
  /// numbers present in [toolResults] — see ResponseValidator, which checks
  /// this after the fact as a second line of defense.
  Future<String> generateResponse({
    required String userMessage,
    required Map<String, Map<String, dynamic>> toolResults,
    required List<AIEngineMessage> conversationHistory,
  });
}
