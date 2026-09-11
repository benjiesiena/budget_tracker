import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../tools/ai_tool.dart';
import 'ai_config.dart';
import 'ai_engine.dart';
import 'model_download_service.dart';

/// Local LLM-based AI engine using llama.cpp for on-device inference.
/// Implements the same [AIEngine] interface as RuleBasedAIEngine, but uses
/// a real transformer model for more natural responses and better intent detection.
class LocalLLMAIEngine implements AIEngine {
  LocalLLMAIEngine({
    String? modelFileName,
    int? contextSize,
    int? nThreads,
    this.downloadService,
  })  : modelFileName = modelFileName ?? AIConfig.modelFileName,
        contextSize = contextSize ?? AIConfig.contextSize,
        nThreads = nThreads ?? AIConfig.nThreads;

  final String modelFileName;
  final int contextSize;
  final int nThreads;
  final ModelDownloadService? downloadService;

  LlamaEngine? _llamaEngine;
  EngineChat? _chat;
  String? _modelPath;
  bool _isInitialized = false;

  @override
  Future<bool> get isReady async {
    if (_isInitialized && _llamaEngine != null) {
      return true;
    }
    return await _initializeModel();
  }

  Future<bool> _initializeModel() async {
    if (_isInitialized) return true;

    try {
      // Use the app's private storage directory
      final directory = await getApplicationDocumentsDirectory();
      final modelsDir = Directory(p.join(directory.path, 'models'));
      
      debugPrint('Using app documents directory: ${modelsDir.path}');
      
      // Create models directory if it doesn't exist
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
        debugPrint('Created models directory');
      }

      _modelPath = p.join(modelsDir.path, modelFileName);
      debugPrint('Expected model path: $_modelPath');

      // Check if model file exists
      final modelFile = File(_modelPath!);
      if (!await modelFile.exists()) {
        debugPrint('Model file not found at $_modelPath');
        
        // Try to download the model if download service is available
        if (downloadService != null) {
          debugPrint('Attempting to download model...');
          final downloadedPath = await downloadService!.downloadModel();
          if (downloadedPath != null) {
            _modelPath = downloadedPath;
            debugPrint('Model downloaded successfully to: $_modelPath');
          } else {
            debugPrint('Model download failed');
            return false;
          }
        } else {
          debugPrint('No download service available');
          debugPrint('The file should be manually placed in: ${modelsDir.path}');
          return false;
        }
      }
      
      final fileSize = await modelFile.length();
      debugPrint('Model file size: $fileSize bytes (${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB)');

      debugPrint('Initializing LLM with model: $_modelPath');

      // Use the new 0.9.0 API - Android libraries are bundled automatically
      _llamaEngine = await LlamaEngine.spawn(
        modelParams: ModelParams(
          path: _modelPath!,
          gpuLayers: AIConfig.nGpuLayers,
        ),
        contextParams: ContextParams(
          nCtx: contextSize,
          nThreads: nThreads,
        ),
      );

      // Create a chat session for conversational use
      _chat = await _llamaEngine!.createChat();
      
      _isInitialized = true;
      debugPrint('LLM model loaded successfully');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Failed to initialize LLM: $e\n$stackTrace');
      _isInitialized = false;
      return false;
    }
  }



  @override
  Future<AIEngineDecision> planToolCalls({
    required String userMessage,
    required List<AITool> availableTools,
    required List<AIEngineMessage> conversationHistory,
  }) async {
    // Ensure model is loaded
    if (!await isReady) {
      debugPrint('Model not ready, falling back to default behavior');
      return _fallbackDecision(availableTools);
    }

    try {
      // Build a prompt for intent detection
      final intentPrompt = _buildIntentDetectionPrompt(
        userMessage,
        availableTools,
        conversationHistory,
      );

      // Get LLM response for intent detection
      final intentResponse = await _generateLLMResponse(intentPrompt);

      // Parse the LLM response to determine which tools to call
      return _parseIntentResponse(intentResponse, availableTools, userMessage);
    } catch (e, stackTrace) {
      debugPrint('Intent detection failed: $e\n$stackTrace');
      return _fallbackDecision(availableTools);
    }
  }

  @override
  Future<String> generateResponse({
    required String userMessage,
    required Map<String, Map<String, dynamic>> toolResults,
    required List<AIEngineMessage> conversationHistory,
  }) async {
    // Ensure model is loaded
    if (!await isReady) {
      debugPrint('Model not ready, falling back to default response');
      return _fallbackResponse(toolResults);
    }

    try {
      // Build a prompt for response generation
      final responsePrompt = _buildResponsePrompt(
        userMessage,
        toolResults,
        conversationHistory,
      );

      // Get LLM response
      return await _generateLLMResponse(responsePrompt);
    } catch (e, stackTrace) {
      debugPrint('Response generation failed: $e\n$stackTrace');
      return _fallbackResponse(toolResults);
    }
  }

  String _buildIntentDetectionPrompt(
    String userMessage,
    List<AITool> availableTools,
    List<AIEngineMessage> conversationHistory,
  ) {
    final toolsList = availableTools.map((t) => '- ${t.name}: ${t.description}').join('\n');

    return '''You are a financial assistant that determines which tools to use for budget tracking questions.

Available tools:
$toolsList

User message: "$userMessage"

Respond with a JSON object containing:
{
  "tools": ["tool_name1", "tool_name2"],
  "reasoning": "brief explanation of why these tools are needed"
}

Only include tools that are necessary. If no tools are needed, return an empty array.
Keep your response concise and valid JSON only.''';
  }

  String _buildResponsePrompt(
    String userMessage,
    Map<String, Map<String, dynamic>> toolResults,
    List<AIEngineMessage> conversationHistory,
  ) {
    final resultsJson = _formatToolResults(toolResults);

    return '''You are a helpful financial assistant for a budget tracking app. You provide clear, accurate advice about spending, savings, and budgeting.

User question: "$userMessage"

Tool results (financial data):
$resultsJson

Important rules:
- Only use numbers from the tool results above - never make up financial figures
- Be concise and helpful
- If data is missing or insufficient, acknowledge it
- Provide practical, actionable advice
- Use the currency format shown in the data

Provide a natural, conversational response based on the tool results.''';
  }

  String _formatToolResults(Map<String, Map<String, dynamic>> toolResults) {
    if (toolResults.isEmpty) return 'No tool results available';

    final buffer = StringBuffer();
    for (final entry in toolResults.entries) {
      buffer.writeln('${entry.key}: ${entry.value}');
    }
    return buffer.toString();
  }

  Future<String> _generateLLMResponse(String prompt) async {
    if (_llamaEngine == null) {
      throw Exception('LLM not initialized');
    }

    // Use the synchronous Llama class for simpler generation
    // This is the "High-Level Wrapper" approach from documentation
    final session = await _llamaEngine!.createSession();
    
    // Generate response using the session
    final response = await session.generate(
      prompt: prompt,
      addSpecial: true,
      sampler: const SamplerParams(
        temperature: 0.7,
        topK: 40,
        topP: 0.9,
      ),
      maxTokens: 512,
    ).toList();
    
    await session.dispose();
    
    // Collect all text from events
    final buffer = StringBuffer();
    for (final event in response) {
      try {
        final eventMap = event as dynamic;
        if (eventMap.toString().contains('TokenEvent')) {
          buffer.write(eventMap.text);
        }
      } catch (e) {
        debugPrint('Error parsing event: $e');
      }
    }
    
    return buffer.toString().trim();
  }

  AIEngineDecision _parseIntentResponse(
    String response,
    List<AITool> availableTools,
    String userMessage,
  ) {
    try {
      // Try to parse JSON response
      final cleanResponse = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final jsonResponse = jsonDecode(cleanResponse) as Map<String, dynamic>;
      final toolsList = jsonResponse['tools'] as List<dynamic>?;
      
      if (toolsList == null) {
        return _fallbackDecision(availableTools);
      }

      final toolNames = <String>[];
      for (final toolName in toolsList) {
        if (toolName is String && availableTools.any((t) => t.name == toolName)) {
          toolNames.add(toolName);
        }
      }

      return AIEngineDecision(toolNamesToCall: toolNames);
    } catch (e) {
      debugPrint('Failed to parse intent response: $e');
      return _fallbackDecision(availableTools);
    }
  }

  AIEngineDecision _fallbackDecision(List<AITool> availableTools) {
    // Simple fallback: always get current balance for unknown queries
    if (availableTools.any((t) => t.name == 'get_current_balance')) {
      return const AIEngineDecision(toolNamesToCall: ['get_current_balance']);
    }
    return const AIEngineDecision(toolNamesToCall: []);
  }

  String _fallbackResponse(Map<String, Map<String, dynamic>> toolResults) {
    if (toolResults.isEmpty) {
      return "I'm having trouble processing your request right now. Please try again.";
    }

    // Simple fallback using the rule-based engine's logic
    if (toolResults.containsKey('get_current_balance')) {
      final balance = toolResults['get_current_balance'];
      if (balance != null && balance['balance'] != null) {
        return 'Your current balance is ₱${balance['balance']}.';
      }
    }

    return "I'm experiencing some technical difficulties. Please try again.";
  }

  /// Clean up resources
  Future<void> dispose() async {
    if (_llamaEngine != null) {
      await _llamaEngine!.dispose();
      _llamaEngine = null;
    }
    _isInitialized = false;
  }
}