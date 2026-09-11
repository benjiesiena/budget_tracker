import 'package:flutter_test/flutter_test.dart';
import 'package:budget_tracker/infrastructure/ai/tools/ai_response_validator.dart';

void main() {
  const validator = AIResponseValidator();

  group('percentage handling', () {
    test('does not flag an over-100% budget percentage as fabricated', () {
      // percentUsed is stored as a fraction (1.2 == 120%) in tool results,
      // but response text prints the whole-number percentage ("120%").
      // This was silently discarding correct over-budget answers.
      final result = validator.validate(
        response: "You've used 120% of your August budget (₱1,200 of ₱1,000). "
            'You are ₱200 over budget.',
        toolResults: {
          'get_budget_status': {
            'success': true,
            'data': {
              'budgetName': 'August',
              'totalBudget': 1000,
              'spent': 1200,
              'remaining': -200,
              'percentUsed': 1.2,
            },
          },
        },
        questionNeedsData: true,
      );
      expect(result.isValid, isTrue);
    });

    test('does not flag a fully-complete goal (100%) as fabricated', () {
      final result = validator.validate(
        response: 'Emergency Fund is at 100% — fully funded!',
        toolResults: {
          'get_all_goals': {
            'success': true,
            'data': {
              'goals': [
                {'name': 'Emergency Fund', 'progressPercentage': 1.0},
              ],
            },
          },
        },
        questionNeedsData: true,
      );
      expect(result.isValid, isTrue);
    });

    test('still flags a genuinely fabricated large figure', () {
      final result = validator.validate(
        response: 'Your balance is ₱999999.',
        toolResults: {
          'get_current_balance': {
            'success': true,
            'data': {'balance': 500},
          },
        },
        questionNeedsData: true,
      );
      expect(result.isValid, isFalse);
    });
  });

  test('flags a data question answered with no tool results at all', () {
    final result = validator.validate(
      response: 'You spent ₱2000 this month.',
      toolResults: const {},
      questionNeedsData: true,
    );
    expect(result.isValid, isFalse);
  });
}
