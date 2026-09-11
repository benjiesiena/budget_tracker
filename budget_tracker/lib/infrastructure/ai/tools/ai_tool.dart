/// Describes one callable capability the AI assistant can invoke. Modeled
/// directly on the PRD's `AITool`/`ToolParameter` structure (section 6.2),
/// but with `execute` as a plain synchronous-looking Future so tools can be
/// unit tested without spinning up any model at all.
class AITool {
  final String name;
  final String description;
  final Map<String, ToolParameter> parameters;
  final Future<ToolResult> Function(Map<String, dynamic> args) execute;

  const AITool({
    required this.name,
    required this.description,
    required this.parameters,
    required this.execute,
  });
}

class ToolParameter {
  final String type; // 'string' | 'number' | 'date' | 'boolean'
  final String description;
  final bool required;
  final dynamic defaultValue;

  const ToolParameter({
    required this.type,
    required this.description,
    this.required = false,
    this.defaultValue,
  });
}

/// Every tool returns this shape rather than a raw value, so the response
/// validator (see ai_response_validator.dart) always has a `success` flag
/// and structured `data` to check claims against — it never has to parse
/// free text to figure out whether a number is trustworthy.
class ToolResult {
  final bool success;
  final Map<String, dynamic> data;
  final String? error;

  const ToolResult.ok(this.data) : success = true, error = null;
  const ToolResult.fail(this.error) : success = false, data = const {};

  Map<String, dynamic> toJson() => {
        'success': success,
        if (success) 'data': data,
        if (error != null) 'error': error,
      };
}
