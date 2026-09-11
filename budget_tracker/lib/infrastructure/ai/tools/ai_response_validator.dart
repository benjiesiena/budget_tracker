class ValidationResult {
  final bool isValid;
  final String? error;
  const ValidationResult._(this.isValid, this.error);
  const ValidationResult.valid() : this._(true, null);
  const ValidationResult.error(String message) : this._(false, message);
}

/// Second line of defense against hallucinated numbers, per PRD 6.5.
///
/// [RuleBasedAIEngine]'s templates already only interpolate values pulled
/// from tool results, so in this scaffold the validator's main job is
/// catching genuinely unexpected output (e.g. a future response-generation
/// backend, or a real LLM, drifting from the tool data) rather than fixing
/// bugs in the template engine itself. It flags:
///   - currency-looking numbers in the response that don't appear anywhere
///     in the tool results (possible fabrication)
///   - responses produced when zero tools were called for a question that
///     clearly needed financial data
class AIResponseValidator {
  const AIResponseValidator();

  ValidationResult validate({
    required String response,
    required Map<String, Map<String, dynamic>> toolResults,
    required bool questionNeedsData,
  }) {
    if (questionNeedsData && toolResults.isEmpty) {
      return const ValidationResult.error('Response answers a data question with no tool results backing it.');
    }

    final numbersInResponse = _extractNumbers(response);
    final numbersInToolResults = _extractNumbersFromResults(toolResults);
    // Templates print fractions (e.g. percentUsed: 1.2) as whole percentages
    // ("120%"), so a legitimate percentage in the response often won't
    // match any raw tool number directly — only that number *times 100*
    // does. Without this, every over-100%-budget or 100%-complete-goal
    // response got wrongly flagged as fabricated.
    final derivedPercentages = numbersInToolResults.map((v) => v * 100).toList();

    for (final n in numbersInResponse) {
      // Small numbers (percentages, counts, days) are allowed to appear
      // without an exact tool-result match; only flag amounts that look
      // like they could be fabricated currency figures.
      if (n < 100) continue;
      final matchesRawValue = numbersInToolResults.any((t) => (t - n).abs() < 1.0);
      final matchesPercentage = derivedPercentages.any((t) => (t - n).abs() < 1.0);
      if (!matchesRawValue && !matchesPercentage) {
        return ValidationResult.error('Response contains a figure ($n) not found in any tool result.');
      }
    }

    return const ValidationResult.valid();
  }

  List<double> _extractNumbers(String text) {
    final matches = RegExp(r'[\d]+(\.\d+)?').allMatches(text.replaceAll(',', ''));
    return matches.map((m) => double.parse(m.group(0)!)).toList();
  }

  List<double> _extractNumbersFromResults(Map<String, Map<String, dynamic>> results) {
    final numbers = <double>[];
    void walk(dynamic value) {
      if (value is num) numbers.add(value.toDouble());
      if (value is Map) value.values.forEach(walk);
      if (value is List) value.forEach(walk);
    }

    results.values.forEach(walk);
    return numbers;
  }
}
