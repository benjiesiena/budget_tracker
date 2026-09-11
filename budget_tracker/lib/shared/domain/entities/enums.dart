/// Shared enums used across entities, the database layer, and AI tools.
/// Centralized (rather than per-entity strings) so a typo can't silently
/// create a new, unrecognized category of data.

enum TransactionType { expense, income, transfer }

enum AccountType { cash, bank, creditCard, digitalWallet, investment }

enum CategoryType { expense, income, transfer }

enum BudgetType { monthly, weekly, custom }

enum BudgetStrategy { zeroBased, percentageBased, custom }

enum RecurringFrequency { daily, weekly, biweekly, monthly, quarterly, yearly }

enum InsightType { overspending, subscription, budgetWarning, savingsOpportunity, cashflow }

enum InsightPriority { low, medium, high }

extension TransactionTypeX on TransactionType {
  String get dbValue => switch (this) {
        TransactionType.expense => "expense",
        TransactionType.income => "income",
        TransactionType.transfer => "transfer",
      };

  static TransactionType fromDb(String value) => switch (value) {
        "expense" => TransactionType.expense,
        "income" => TransactionType.income,
        "transfer" => TransactionType.transfer,
        _ => throw ArgumentError("Unknown transaction type: $value"),
      };
}

extension AccountTypeX on AccountType {
  String get dbValue => switch (this) {
        AccountType.cash => "cash",
        AccountType.bank => "bank",
        AccountType.creditCard => "credit_card",
        AccountType.digitalWallet => "digital_wallet",
        AccountType.investment => "investment",
      };

  static AccountType fromDb(String value) => switch (value) {
        "cash" => AccountType.cash,
        "bank" => AccountType.bank,
        "credit_card" => AccountType.creditCard,
        "digital_wallet" => AccountType.digitalWallet,
        "investment" => AccountType.investment,
        _ => throw ArgumentError("Unknown account type: $value"),
      };
}

extension CategoryTypeX on CategoryType {
  String get dbValue => switch (this) {
        CategoryType.expense => "expense",
        CategoryType.income => "income",
        CategoryType.transfer => "transfer",
      };

  static CategoryType fromDb(String value) => switch (value) {
        "expense" => CategoryType.expense,
        "income" => CategoryType.income,
        "transfer" => CategoryType.transfer,
        _ => throw ArgumentError("Unknown category type: $value"),
      };
}

extension RecurringFrequencyX on RecurringFrequency {
  String get dbValue => name;

  static RecurringFrequency fromDb(String value) =>
      RecurringFrequency.values.firstWhere((f) => f.name == value);

  /// Approximate number of days between occurrences. Used for forecasting
  /// only; exact next-due-date logic lives in RecurringTransaction.nextOccurrence.
  int get approxDays => switch (this) {
        RecurringFrequency.daily => 1,
        RecurringFrequency.weekly => 7,
        RecurringFrequency.biweekly => 14,
        RecurringFrequency.monthly => 30,
        RecurringFrequency.quarterly => 91,
        RecurringFrequency.yearly => 365,
      };
}
