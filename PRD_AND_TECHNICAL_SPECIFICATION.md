# Budget Tracker - Product Requirements Document & Technical Specification

## Executive Summary

**Project Name:** Budget Tracker - Offline-First Personal Finance Application with Local AI

**Version:** 1.0.0

**Last Updated:** 2026-08-29

**Status:** Planning Phase

---

## 1. Product Vision

Create a premium, privacy-first, offline-first mobile application that helps users track their finances, manage budgets, set goals, and receive intelligent financial insights through an on-device AI assistant.

**Core Philosophy:** "Know where your money goes. Understand what you can afford. Make better decisions."

**Key Differentiators:**
- 100% offline functionality for core features
- Local AI with no cloud dependencies
- Privacy-first architecture with local data storage
- Minimal, calm, trustworthy UI design
- Deterministic financial calculations
- Production-grade security

---

## 2. Target Platforms

**Primary Target:** Mobile (iOS & Android)

**Secondary Consideration:** Desktop companion app (future)

**Platform Strategy:** Cross-platform mobile development with native performance and platform-specific optimizations

---

## 3. Technology Stack Selection

### 3.1 Evaluation Criteria

- Offline database support
- On-device AI capabilities
- Performance
- Native API access
- Security features
- Long-term maintainability
- Development velocity
- Community support

### 3.2 Recommended Technology Stack

#### **Mobile Framework: Flutter**

**Rationale:**
- Excellent offline-first support with SQLite integration
- Strong performance with compiled native code
- Rich UI components for minimal design implementation
- Comprehensive local storage options (sqflite, hive, shared_preferences)
- Built-in platform channel support for native AI inference
- Strong typing with Dart
- Excellent hot reload for development velocity
- Large ecosystem and community
- Single codebase for iOS and Android

**Alternatives Considered:**
- **React Native:** Good ecosystem but performance overhead with JavaScript bridge
- **Kotlin Multiplatform:** Excellent but steeper learning curve and smaller ecosystem
- **Native (Swift/Kotlin):** Best performance but doubles development effort

#### **Local Database: SQLite (via sqflite)**

**Rationale:**
- Industry-standard for mobile offline storage
- ACID compliance for data integrity
- Excellent performance for financial data
- Built-in encryption support (SQLCipher)
- Mature migration system
- Cross-platform compatibility

#### **Local AI Runtime: ML Kit + Custom Model Integration**

**Rationale:**
- Google's ML Kit provides on-device ML infrastructure
- Support for custom TensorFlow Lite models
- Platform-optimized inference
- No cloud dependencies
- Supports quantized models for mobile efficiency

**Model Strategy:**
- Bundle lightweight quantized model (~50-100MB)
- Support optional larger model downloads
- Use transformer-based SLM optimized for mobile
- Model abstraction layer for future model swaps

#### **State Management: Riverpod**

**Rationale:**
- Compile-time safety
- Excellent testability
- Provider-based architecture aligns with clean architecture
- Good performance for complex state
- Strong community support

#### **Security: flutter_secure_storage + Platform Keychain/Keystore**

**Rationale:**
- Native platform secure storage integration
- Biometric authentication support
- Secure key management
- Encryption at rest

#### **Dependency Injection: get_it + injectable**

**Rationale:**
- Compile-time dependency registration
- Supports clean architecture layers
- Excellent for testing
- Type-safe

#### **Local Storage:**

- **App Settings:** shared_preferences
- **Encrypted Data:** flutter_secure_storage
- **Structured Data:** SQLite (sqflite)
- **Large Files:** Hive (optional for AI model caching)

#### **Charts: fl_chart**

**Rationale:**
- Flutter-native charting library
- Customizable for minimal design
- Good performance
- Supports required chart types (pie, line, bar)

#### **Date/Time: timezone**

**Rationale:**
- Proper timezone handling for financial transactions
- Critical for accurate monthly calculations

---

## 4. Architecture Overview

### 4.1 Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                   │
│  (Screens, Widgets, ViewModels, State Management)       │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                    Domain Layer                          │
│  (Use Cases, Entities, Business Logic, Calculations)    │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                    Data Layer                            │
│  (Repositories, Data Sources, DTOs, Mappers)           │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                    Infrastructure Layer                  │
│  (Database, Local Storage, External Services, AI)       │
└─────────────────────────────────────────────────────────┘
```

### 4.2 AI Architecture (Separate Domain)

```
┌─────────────────────────────────────────────────────────┐
│                 AI Presentation Layer                    │
│  (AI Screens, Chat UI, Insight Cards, Quick Actions)    │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                    AI Orchestrator                       │
│  (Conversation Manager, Intent Detection, Tool Router)   │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                   AI Tool Layer                          │
│  (Financial Tools, Context Builder, Response Validator)  │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                 Financial Domain Layer                   │
│  (Calculation Engine, Business Logic, Domain Services)  │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                    Local Database                        │
└─────────────────────────────────────────────────────────┘
```

### 4.3 Module Structure

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   ├── errors/
│   └── config/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── transactions/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── categories/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── budgets/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── goals/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── analytics/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── ai_assistant/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── infrastructure/
│   │
│   ├── settings/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── backup/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── shared/
│   ├── data/
│   │   ├── datasources/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── database/
│   │
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   ├── usecases/
│   │   └── services/
│   │
│   └── presentation/
│       ├── widgets/
│       ├── components/
│       └── providers/
│
└── infrastructure/
    ├── ai/
    │   ├── models/
    │   ├── runtime/
    │   └── tools/
    │
    ├── security/
    │   ├── encryption/
    │   ├── biometrics/
    │   └── key_management/
    │
    └── notifications/
```

---

## 5. Database Schema

### 5.1 Entity Relationships

```
User (1) ----< (1) Account
  │
  ├----< (1) Transaction
  │       │
  │       ├--< (1) Category
  │       └--< (1) RecurringTransaction
  │
  ├----< (1) Budget
  │       └----< (1) BudgetItem
  │
  ├----< (1) FinancialGoal
  │
  ├----< (1) AIConversation
  │       └----< (1) AIMessage
  │
  ├----< (1) AIInsight
  │
  └----< (1) FinancialProfile
```

### 5.2 Table Definitions

#### **users**
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    currency_code TEXT NOT NULL DEFAULT 'PHP',
    locale TEXT NOT NULL DEFAULT 'en_PH',
    timezone TEXT NOT NULL DEFAULT 'Asia/Manila',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_active ON users(is_active);
```

#### **accounts**
```sql
CREATE TABLE accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL, -- 'cash', 'bank', 'credit_card', 'digital_wallet', 'investment'
    balance REAL NOT NULL DEFAULT 0,
    currency_code TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1,
    icon TEXT,
    color TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_accounts_user_id ON accounts(user_id);
CREATE INDEX idx_accounts_is_active ON accounts(is_active);
```

#### **categories**
```sql
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL, -- 'expense', 'income', 'transfer'
    icon TEXT,
    color TEXT,
    is_default INTEGER NOT NULL DEFAULT 0,
    is_active INTEGER NOT NULL DEFAULT 1,
    parent_id INTEGER,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE INDEX idx_categories_user_id ON categories(user_id);
CREATE INDEX idx_categories_type ON categories(type);
CREATE INDEX idx_categories_is_active ON categories(is_active);
```

#### **transactions**
```sql
CREATE TABLE transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    account_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    type TEXT NOT NULL, -- 'expense', 'income', 'transfer'
    amount REAL NOT NULL,
    description TEXT,
    notes TEXT,
    date INTEGER NOT NULL,
    tags TEXT, -- JSON array
    is_recurring INTEGER NOT NULL DEFAULT 0,
    recurring_transaction_id INTEGER,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE RESTRICT,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
    FOREIGN KEY (recurring_transaction_id) REFERENCES recurring_transactions(id) ON DELETE SET NULL
);

CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_transactions_category_id ON transactions(category_id);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_date ON transactions(date);
CREATE INDEX idx_transactions_is_recurring ON transactions(is_recurring);
CREATE INDEX idx_transactions_tags ON transactions(tags);
```

#### **recurring_transactions**
```sql
CREATE TABLE recurring_transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    account_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    type TEXT NOT NULL,
    amount REAL NOT NULL,
    description TEXT NOT NULL,
    frequency TEXT NOT NULL, -- 'daily', 'weekly', 'biweekly', 'monthly', 'quarterly', 'yearly'
    interval INTEGER NOT NULL DEFAULT 1,
    start_date INTEGER NOT NULL,
    end_date INTEGER,
    last_processed_date INTEGER,
    next_due_date INTEGER,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE RESTRICT,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
);

CREATE INDEX idx_recurring_transactions_user_id ON recurring_transactions(user_id);
CREATE INDEX idx_recurring_transactions_is_active ON recurring_transactions(is_active);
CREATE INDEX idx_recurring_transactions_next_due_date ON recurring_transactions(next_due_date);
```

#### **budgets**
```sql
CREATE TABLE budgets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL, -- 'monthly', 'weekly', 'custom'
    period_start INTEGER NOT NULL,
    period_end INTEGER NOT NULL,
    total_budget REAL NOT NULL,
    strategy TEXT NOT NULL, -- 'zero_based', 'percentage_based', 'custom'
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_budgets_user_id ON budgets(user_id);
CREATE INDEX idx_budgets_type ON budgets(type);
CREATE INDEX idx_budgets_period ON budgets(period_start, period_end);
CREATE INDEX idx_budgets_is_active ON budgets(is_active);
```

#### **budget_items**
```sql
CREATE TABLE budget_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    budget_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    amount REAL NOT NULL,
    percentage REAL, -- For percentage-based budgets
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (budget_id) REFERENCES budgets(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
);

CREATE INDEX idx_budget_items_budget_id ON budget_items(budget_id);
CREATE INDEX idx_budget_items_category_id ON budget_items(category_id);
```

#### **financial_goals**
```sql
CREATE TABLE financial_goals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    target_amount REAL NOT NULL,
    current_amount REAL NOT NULL DEFAULT 0,
    target_date INTEGER,
    category_id INTEGER,
    icon TEXT,
    color TEXT,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE INDEX idx_financial_goals_user_id ON financial_goals(user_id);
CREATE INDEX idx_financial_goals_is_active ON financial_goals(is_active);
CREATE INDEX idx_financial_goals_target_date ON financial_goals(target_date);
```

#### **ai_conversations**
```sql
CREATE TABLE ai_conversations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_ai_conversations_user_id ON ai_conversations(user_id);
CREATE INDEX idx_ai_conversations_updated_at ON ai_conversations(updated_at);
```

#### **ai_messages**
```sql
CREATE TABLE ai_messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    conversation_id INTEGER NOT NULL,
    role TEXT NOT NULL, -- 'user', 'assistant', 'system'
    content TEXT NOT NULL,
    tool_calls TEXT, -- JSON array of tool calls
    tool_results TEXT, -- JSON object of tool results
    created_at INTEGER NOT NULL,
    FOREIGN KEY (conversation_id) REFERENCES ai_conversations(id) ON DELETE CASCADE
);

CREATE INDEX idx_ai_messages_conversation_id ON ai_messages(conversation_id);
CREATE INDEX idx_ai_messages_created_at ON ai_messages(created_at);
```

#### **ai_insights**
```sql
CREATE TABLE ai_insights (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    type TEXT NOT NULL, -- 'overspending', 'subscription', 'budget_warning', 'savings_opportunity', 'cashflow'
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    data TEXT, -- JSON object with supporting data
    priority TEXT NOT NULL DEFAULT 'medium', -- 'low', 'medium', 'high'
    is_read INTEGER NOT NULL DEFAULT 0,
    is_dismissed INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    expires_at INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_ai_insights_user_id ON ai_insights(user_id);
CREATE INDEX idx_ai_insights_type ON ai_insights(type);
CREATE INDEX idx_ai_insights_priority ON ai_insights(priority);
CREATE INDEX idx_ai_insights_is_read ON ai_insights(is_read);
CREATE INDEX idx_ai_insights_created_at ON ai_insights(created_at);
```

#### **financial_profile**
```sql
CREATE TABLE financial_profile (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL UNIQUE,
    monthly_income REAL,
    budget_strategy TEXT, -- 'zero_based', 'percentage_based', 'custom'
    savings_target_percentage REAL,
    emergency_fund_target_months REAL DEFAULT 3,
    preferred_categories TEXT, -- JSON array
    risk_tolerance TEXT, -- 'conservative', 'moderate', 'aggressive'
    financial_goals_summary TEXT, -- JSON object
    recurring_expenses_summary TEXT, -- JSON object
    ai_memory_enabled INTEGER NOT NULL DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_financial_profile_user_id ON financial_profile(user_id);
```

#### **app_settings**
```sql
CREATE TABLE app_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL UNIQUE,
    theme TEXT NOT NULL DEFAULT 'system', -- 'light', 'dark', 'system'
    language TEXT NOT NULL DEFAULT 'en',
    currency_format TEXT NOT NULL DEFAULT 'symbol',
    date_format TEXT NOT NULL DEFAULT 'MM/dd/yyyy',
    first_day_of_week INTEGER NOT NULL DEFAULT 0, -- 0 = Sunday
    biometric_enabled INTEGER NOT NULL DEFAULT 0,
    auto_lock_enabled INTEGER NOT NULL DEFAULT 1,
    auto_lock_timeout_seconds INTEGER NOT NULL DEFAULT 300,
    notifications_enabled INTEGER NOT NULL DEFAULT 1,
    budget_alert_threshold REAL NOT NULL DEFAULT 0.85,
    goal_reminder_enabled INTEGER NOT NULL DEFAULT 1,
    ai_model_version TEXT,
    last_backup_date INTEGER,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_app_settings_user_id ON app_settings(user_id);
```

### 5.3 Migration Strategy

Use `sqflite` migration system with versioned schema files:

```
database/
├── migrations/
│   ├── V1__initial_schema.sql
│   ├── V2__add_indexes.sql
│   ├── V3__add_ai_insights.sql
│   └── ...
└── database_helper.dart
```

---

## 6. Local AI Architecture

### 6.1 AI Engine Components

```
LocalAIEngine
├── ModelManager
│   ├── Model Discovery
│   ├── Model Download
│   ├── Model Installation
│   ├── Model Verification
│   ├── Model Loading
│   ├── Model Unloading
│   └── Model Update
│
├── PromptManager
│   ├── System Prompts
│   ├── Context Prompts
│   ├── Tool Descriptions
│   └── Response Templates
│
├── FinancialContextBuilder
│   ├── User Profile Context
│   ├── Transaction Context
│   ├── Budget Context
│   ├── Goal Context
│   └── Temporal Context
│
├── ToolExecutor
│   ├── Tool Registry
│   ├── Tool Selection
│   ├── Tool Execution
│   └── Result Formatting
│
├── ResponseValidator
│   ├── Fact Checking
│   ├── Calculation Verification
│   ├── Safety Checks
│   └── Privacy Validation
│
└── AIConversationManager
    ├── Conversation History
    ├── Context Window Management
    ├── Message deduplication
    └── Memory Persistence
```

### 6.2 AI Tool/Function Schema

#### **Tool Definition Structure**

```dart
class AITool {
  final String name;
  final String description;
  final Map<String, ToolParameter> parameters;
  final Future<dynamic> Function(Map<String, dynamic>) execute;
  final bool requiresCalculation;
}

class ToolParameter {
  final String type;
  final String description;
  final bool required;
  final dynamic defaultValue;
}
```

#### **Financial Tools Registry**

```dart
// Balance Tools
get_current_balance({
  DateTime? asOfDate,
  String? accountId,
})

get_account_balances({
  DateTime? asOfDate,
})

// Income Tools
get_monthly_income({
  required DateTime month,
  String? accountId,
})

get_income_by_category({
  required DateTime month,
})

get_income_trends({
  required int months,
})

// Expense Tools
get_monthly_expenses({
  required DateTime month,
  String? accountId,
  String? categoryId,
})

get_expenses_by_category({
  required DateTime month,
})

get_expenses_by_category_detailed({
  required DateTime month,
  required String categoryId,
})

get_spending_trends({
  required int months,
})

get_recent_transactions({
  int? limit,
  String? categoryId,
  String? type,
})

// Budget Tools
get_budget_status({
  required DateTime month,
  String? budgetId,
})

get_budget_usage({
  required String budgetId,
})

get_remaining_budget({
  required String categoryId,
  required DateTime month,
})

// Goal Tools
get_goal_progress({
  required String goalId,
})

get_all_goals()

calculate_goal_completion_date({
  required String goalId,
  required double monthlyContribution,
})

// Calculation Tools
calculate_affordable_spending({
  required double proposedAmount,
  required DateTime startDate,
  required DateTime endDate,
})

calculate_savings_projection({
  required double monthlyIncome,
  required double monthlyExpenses,
  required int months,
})

calculate_cashflow_forecast({
  required int days,
  required DateTime startDate,
})

calculate_category_trend({
  required String categoryId,
  required int months,
})

calculate_savings_rate({
  required DateTime month,
})

// Recurring Transaction Tools
get_recurring_expenses()

get_upcoming_recurring_transactions({
  required int days,
})

calculate_recurring_monthly_total()

// Analytics Tools
get_spending_summary({
  required DateTime month,
})

get_income_vs_expense({
  required DateTime month,
})

get_top_spending_categories({
  required DateTime month,
  int? limit,
})

// Search Tools
search_transactions({
  required String query,
  DateTime? startDate,
  DateTime? endDate,
  String? categoryId,
})
```

### 6.3 System Prompt Template

```
You are a helpful financial assistant for a personal budget tracking application. Your role is to help users understand their finances, make better financial decisions, and achieve their financial goals.

IMPORTANT RULES:
1. NEVER fabricate financial data. Only use information provided by the tools.
2. Distinguish clearly between actual data, calculations, estimates, and recommendations.
3. Use the provided financial tools for all calculations. Do not perform critical financial calculations yourself.
4. Be concise and practical. Avoid unnecessary financial jargon.
5. When uncertain, say so rather than guessing.
6. Always base insights on actual user data from the tools.
7. Use phrases like "Based on your spending history..." rather than "You should definitely..."
8. Prioritize actionable advice over theoretical suggestions.

AVAILABLE TOOLS:
{{tool_descriptions}}

USER PROFILE:
{{user_profile}}

CURRENT CONTEXT:
{{financial_context}}

RESPONSE GUIDELINES:
- Keep responses under 150 words when possible
- Use structured formatting (bullet points, line breaks) for readability
- Highlight key amounts and dates
- Provide specific, actionable suggestions
- Include relevant context from the user's financial data
- When providing estimates, clearly label them as projections
```

### 6.4 Tool Selection Logic

```dart
class IntentDetector {
  Intent detectIntent(String userQuery) {
    // Pattern matching for common intents
    if (userQuery.contains('spend') && userQuery.contains('afford')) {
      return Intent.affordabilityCheck;
    }
    if (userQuery.contains('spend') && userQuery.contains('month')) {
      return Intent.monthlySpending;
    }
    if (userQuery.contains('budget') && userQuery.contains('status')) {
      return Intent.budgetStatus;
    }
    // ... more patterns
  }
}

class ToolRouter {
  List<String> selectTools(Intent intent, Map<String, dynamic> context) {
    switch (intent) {
      case Intent.affordabilityCheck:
        return [
          'get_current_balance',
          'get_recurring_expenses',
          'calculate_cashflow_forecast',
        ];
      case Intent.monthlySpending:
        return [
          'get_monthly_expenses',
          'get_expenses_by_category',
          'get_spending_trends',
        ];
      // ... more cases
    }
  }
}
```

### 6.5 Response Validation

```dart
class ResponseValidator {
  ValidationResult validate(AIResponse response, ToolResults toolResults) {
    // Check for hallucinated numbers
    if (containsUnsubstantiatedFigures(response, toolResults)) {
      return ValidationResult.error('Response contains unverified figures');
    }
    
    // Check for fabrication
    if (containsFabricatedData(response, toolResults)) {
      return ValidationResult.error('Response contains fabricated data');
    }
    
    // Check calculation accuracy
    if (calculationMismatch(response, toolResults)) {
      return ValidationResult.error('Calculation mismatch detected');
    }
    
    // Check privacy violations
    if (containsSensitiveInfo(response)) {
      return ValidationResult.error('Privacy violation detected');
    }
    
    return ValidationResult.valid();
  }
}
```

---

## 7. Financial Calculation Engine

### 7.1 Core Calculation Functions

```dart
class FinancialCalculator {
  // Balance Calculations
  double calculateCurrentBalance(List<Transaction> transactions, String accountId);
  double calculateNetWorth(List<Account> accounts);
  
  // Budget Calculations
  double calculateBudgetUsage(Budget budget, List<Transaction> transactions);
  double calculateBudgetRemaining(Budget budget, List<Transaction> transactions);
  double calculateBudgetPercentage(Budget budget, List<Transaction> transactions);
  
  // Income Calculations
  double calculateMonthlyIncome(List<Transaction> transactions, DateTime month);
  double calculateAverageMonthlyIncome(List<Transaction> transactions, int months);
  
  // Expense Calculations
  double calculateMonthlyExpenses(List<Transaction> transactions, DateTime month);
  double calculateAverageMonthlyExpenses(List<Transaction> transactions, int months);
  Map<String, double> calculateExpensesByCategory(List<Transaction> transactions, DateTime month);
  
  // Savings Calculations
  double calculateSavingsRate(List<Transaction> transactions, DateTime month);
  double calculateSavingsRate(List<Transaction> transactions, int months);
  
  // Trend Calculations
  double calculateCategoryTrend(String categoryId, List<Transaction> transactions, int months);
  Map<DateTime, double> calculateSpendingTrend(List<Transaction> transactions, int months);
  
  // Goal Calculations
  double calculateGoalProgress(FinancialGoal goal);
  DateTime calculateGoalCompletionDate(FinancialGoal goal, double monthlyContribution);
  double calculateRequiredMonthlySavings(FinancialGoal goal);
  
  // Cash Flow Calculations
  CashFlowForecast calculateCashFlowForecast(
    List<Transaction> transactions,
    List<RecurringTransaction> recurringTransactions,
    DateTime startDate,
    int days,
  );
  
  // Affordability Calculations
  AffordabilityResult calculateAffordableSpending(
    double currentBalance,
    List<RecurringTransaction> recurringExpenses,
    double proposedAmount,
    DateTime startDate,
    DateTime endDate,
  );
  
  // Recurring Transaction Calculations
  double calculateRecurringMonthlyTotal(List<RecurringTransaction> recurringTransactions);
  List<Transaction> generateRecurringTransactions(
    List<RecurringTransaction> recurringTransactions,
    DateTime startDate,
    DateTime endDate,
  );
}
```

### 7.2 Calculation Principles

1. **Deterministic:** Same inputs always produce same outputs
2. **Testable:** Pure functions with no side effects
3. **Documented:** Clear input/output contracts
4. **Validated:** Input validation and error handling
5. **Precise:** Use proper decimal arithmetic for financial calculations

---

## 8. Design System Specifications

### 8.1 Color Palette

#### **Light Mode**
```dart
class AppColors {
  // Neutrals
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF5F5F5);
  
  // Text
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF666666);
  static const textTertiary = Color(0xFF999999);
  static const textDisabled = Color(0xFFCCCCCC);
  
  // Primary Accent
  static const primary = Color(0xFF0066CC);
  static const primaryLight = Color(0xFF3399FF);
  static const primaryDark = Color(0xFF004C99);
  
  // Financial States
  static const positive = Color(0xFF10B981);  // Green
  static const positiveLight = Color(0xFFD1FAE5);
  static const negative = Color(0xFFEF4444);  // Red
  static const negativeLight = Color(0xFFFEE2E2);
  static const warning = Color(0xFFF59E0B);   // Orange
  static const warningLight = Color(0xFFFEF3C7);
  
  // Borders & Dividers
  static const border = Color(0xFFE5E5E5);
  static const divider = Color(0xFFEEEEEE);
  
  // Interactive
  static const interactive = Color(0xFF0066CC);
  static const interactiveHover = Color(0xFF3399FF);
  static const interactivePressed = Color(0xFF004C99);
}
```

#### **Dark Mode**
```dart
class AppColorsDark {
  // Neutrals
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const surfaceVariant = Color(0xFF2C2C2C);
  
  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
  static const textTertiary = Color(0xFF808080);
  static const textDisabled = Color(0xFF4D4D4D);
  
  // Primary Accent
  static const primary = Color(0xFF4D9FFF);
  static const primaryLight = Color(0xFF80BFFF);
  static const primaryDark = Color(0xFF3380CC);
  
  // Financial States
  static const positive = Color(0xFF34D399);
  static const positiveLight = Color(0xFF064E3B);
  static const negative = Color(0xFFF87171);
  static const negativeLight = Color(0xFF7F1D1D);
  static const warning = Color(0xFFFBBF24);
  static const warningLight = Color(0xFF78350F);
  
  // Borders & Dividers
  static const border = Color(0xFF333333);
  static const divider = Color(0xFF2A2A2A);
}
```

### 8.2 Typography

```dart
class AppTypography {
  // Font Family
  static const String fontFamily = 'SF Pro Display';
  
  // Page Title
  static const pageTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );
  
  // Section Heading
  static const sectionHeading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );
  
  // Primary Value
  static const primaryValue = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );
  
  // Body Text
  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );
  
  // Supporting Text
  static const supporting = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  
  // Caption
  static const caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
  );
  
  // Button
  static const button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );
}
```

### 8.3 Spacing System

```dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
```

### 8.4 Border Radius

```dart
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;
}
```

### 8.5 Shadows

```dart
class AppShadows {
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];
  
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];
  
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];
}
```

### 8.6 Component Specifications

#### **PrimaryButton**
```dart
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  
  // Specs:
  // - Height: 48px
  // - Border Radius: 12px
  // - Background: Primary color
  // - Text: Button typography, white
  // - Loading state: Show spinner, disable interaction
  // - Disabled state: 40% opacity
}
```

#### **SecondaryButton**
```dart
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  
  // Specs:
  // - Height: 48px
  // - Border Radius: 12px
  // - Background: Transparent
  // - Border: 1px solid Border color
  // - Text: Button typography, Primary color
}
```

#### **AmountInput**
```dart
class AmountInput extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String currency;
  
  // Specs:
  // - Large typography for amount (32px)
  // - Currency symbol prefix
  // - Clear focus states
  // - Decimal precision control
}
```

#### **TransactionRow**
```dart
class TransactionRow extends StatelessWidget {
  final Transaction transaction;
  
  // Specs:
  // - Height: 64px
  // - Category icon on left (40px)
  // - Description and date in middle
  // - Amount on right
  // - Subtle divider at bottom
}
```

#### **CategoryIcon**
```dart
class CategoryIcon extends StatelessWidget {
  final String icon;
  final Color color;
  
  // Specs:
  // - Size: 40px
  // - Border Radius: 12px
  // - Background: Category color with 20% opacity
  - Icon: 20px, centered
}
```

#### **BudgetProgress**
```dart
class BudgetProgress extends StatelessWidget {
  final double spent;
  final double budget;
  final double remaining;
  
  // Specs:
  // - Linear progress bar
  // - Height: 8px
  // - Border Radius: 4px
  // - Color coding: Green (<80%), Orange (80-100%), Red (>100%)
  // - Show spent, budget, remaining values
}
```

#### **FinancialSummary**
```dart
class FinancialSummary extends StatelessWidget {
  final String label;
  final double amount;
  final String? subtitle;
  final bool isPositive;
  
  // Specs:
  // - Label: Supporting typography
  // - Amount: Primary value typography
  // - Color coding for positive/negative
  // - Optional subtitle
}
```

#### **InsightCard**
```dart
class InsightCard extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  
  // Specs:
  // - Subtle background (Surface variant)
  // - Border Radius: 16px
  // - Padding: 16px
  // - Icon indicator on left
  // - Title: Section heading
  - Message: Body typography
  - Action button: Secondary button style
}
```

#### **GoalProgress**
```dart
class GoalProgress extends StatelessWidget {
  final FinancialGoal goal;
  
  // Specs:
  // - Circular or linear progress
  - Current amount vs target
  - Progress percentage
  - Estimated completion date
  - Required monthly contribution
}
```

#### **ChartCard**
```dart
class ChartCard extends StatelessWidget {
  final String title;
  final Widget chart;
  
  // Specs:
  // - Card with subtle shadow
  // - Title: Section heading
  - Chart: Constrained height (200px)
  - Responsive width
}
```

#### **EmptyState**
```dart
class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  
  // Specs:
  // - Centered content
  - Icon or illustration (optional)
  - Title: Section heading
  - Message: Body typography, muted
  - Action button: Primary button
}
```

#### **AIMessage**
```dart
class AIMessage extends StatelessWidget {
  final String content;
  final bool isUser;
  
  // Specs:
  // - User message: Right-aligned, primary background
  - AI message: Left-aligned, surface variant background
  - Border Radius: 16px
  - Padding: 12px
  - Max width: 80% of container
}
```

#### **AIQuickAction**
```dart
class AIQuickAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  
  // Specs:
  // - Pill-shaped button
  - Height: 36px
  - Border Radius: 18px
  - Background: Surface variant
  - Text: Supporting typography
  - Horizontal padding: 16px
}
```

---

## 9. Screen-by-Screen UI Specifications

### 9.1 Splash Screen

**Purpose:** App initialization, database setup, AI model loading

**Layout:**
- Centered app logo
- App name
- Loading indicator (if initialization takes time)

**Behavior:**
- Show for minimum 2 seconds
- Navigate to onboarding or home based on user state
- Show initialization errors gracefully

---

### 9.2 Onboarding Flow

#### **Screen 1: Welcome**
```
┌─────────────────────────────────────┐
│                                     │
│         [App Logo]                  │
│                                     │
│      Welcome to Budget Tracker      │
│                                     │
│  Know where your money goes.        │
│  Understand what you can afford.    │
│  Make better decisions.             │
│                                     │
│                                     │
│        [Get Started]                │
│                                     │
└─────────────────────────────────────┘
```

#### **Screen 2: Choose Currency**
```
┌─────────────────────────────────────┐
│   < Back        Choose Currency    │
├─────────────────────────────────────┤
│                                     │
│  Select your primary currency       │
│                                     │
│  [●] Philippine Peso (₱)          │
│  [ ] US Dollar ($)                  │
│  [ ] Euro (€)                       │
│  [ ] Japanese Yen (¥)               │
│  [ ] British Pound (£)              │
│  [ ] Other...                       │
│                                     │
│                                     │
│        [Continue]                   │
│                                     │
└─────────────────────────────────────┘
```

#### **Screen 3: Set Income**
```
┌─────────────────────────────────────┐
│   < Back        Set Monthly Income  │
├─────────────────────────────────────┤
│                                     │
│  What's your monthly income?        │
│                                     │
│                                     │
│          ₱ 45,000                   │
│                                     │
│                                     │
│  This helps us suggest budgets      │
│  and track your progress.           │
│                                     │
│  ☐ I'll add this later              │
│                                     │
│                                     │
│        [Continue]                   │
│                                     │
└─────────────────────────────────────┘
```

#### **Screen 4: Choose Budgeting Style**
```
┌─────────────────────────────────────┐
│  < Back    Choose Budgeting Style   │
├─────────────────────────────────────┤
│                                     │
│  How do you prefer to budget?       │
│                                     │
│  [●] Zero-Based Budgeting           │
│      Every peso is assigned         │
│      to a category.                 │
│                                     │
│  [ ] Percentage-Based               │
│      50% needs, 30% wants,          │
│      20% savings.                   │
│                                     │
│  [ ] Custom                         │
│      Set your own limits.           │
│                                     │
│                                     │
│        [Continue]                   │
│                                     │
└─────────────────────────────────────┘
```

#### **Screen 5: Create First Budget**
```
┌─────────────────────────────────────┐
│  < Back      Create Your Budget     │
├─────────────────────────────────────┤
│                                     │
│  Set a monthly spending limit       │
│                                     │
│                                     │
│      Monthly Budget                 │
│          ₱ 35,000                   │
│                                     │
│                                     │
│  Based on your income of ₱45,000    │
│  this leaves ₱10,000 for savings.   │
│                                     │
│  ☐ I'll set this later              │
│                                     │
│                                     │
│        [Continue]                   │
│                                     │
└─────────────────────────────────────┘
```

#### **Screen 6: Optional Financial Goal**
```
┌─────────────────────────────────────┐
│  < Back      Set a Goal (Optional)  │
├─────────────────────────────────────┤
│                                     │
│  What are you saving for?           │
│                                     │
│  [Emergency Fund]                   │
│  [Vacation]                         │
│  [New Phone]                        │
│  [Car]                              │
│  [Custom Goal]                      │
│  [Skip for now]                     │
│                                     │
└─────────────────────────────────────┘
```

#### **Screen 7: AI Introduction**
```
┌─────────────────────────────────────┐
│  < Back       Meet Your AI Assistant│
├─────────────────────────────────────┤
│                                     │
│         [AI Icon]                   │
│                                     │
│  Your personal financial assistant  │
│                                     │
│  Ask questions about your money:    │
│  • "Can I afford ₱5,000?"          │
│  • "Where did I spend the most?"   │
│  • "How can I save more?"          │
│                                     │
│  Works completely offline.          │
│  Your data stays on your device.    │
│                                     │
│                                     │
│        [Start Using Budget Tracker] │
│                                     │
└─────────────────────────────────────┘
```

---

### 9.3 Home Screen

```
┌─────────────────────────────────────┐
│  ☰      Budget Tracker        🔔    │
├─────────────────────────────────────┤
│                                     │
│  August 2026              [▼]       │
│                                     │
│  Available Balance                  │
│  ₱24,580                            │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Income          Expenses           │
│  ₱45,000         ₱20,420            │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Budget Status                      │
│  ₱8,400 remaining this month        │
│  ████████████░░░░ 78%               │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Spending Overview                  │
│  Food          ₱6,200  ████░░░░░░  │
│  Transport     ₱3,100  ██░░░░░░░░  │
│  Bills         ₱5,500  ███░░░░░░░  │
│  Shopping      ₱2,400  ██░░░░░░░░  │
│  Other         ₱3,220  ██░░░░░░░░  │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  💡 AI Insight                      │
│  You're spending 18% more on        │
│  dining this month than usual.      │
│                                     │
│  [Review spending]                  │
│                                     │
└─────────────────────────────────────┘
│ [Home] [Transactions] [Budget] [Goals] [AI] │
└─────────────────────────────────────────────┘
```

---

### 9.4 Transaction List Screen

```
┌─────────────────────────────────────┐
│  < Transactions        [+ Add]     │
├─────────────────────────────────────┤
│  [🔍 Search transactions...]        │
│                                     │
│  August                             │
│  ─────────────────────────────────  │
│                                     │
│  [🍔] GrabFood          -₱250      │
│      Lunch                           │
│      Aug 28                          │
│  ─────────────────────────────────  │
│                                     │
│  [🚗] Gas               -₱1,500     │
│      Fuel                            │
│      Aug 27                          │
│  ─────────────────────────────────  │
│                                     │
│  [💰] Salary            +₱45,000    │
│      Monthly salary                  │
│      Aug 15                          │
│  ─────────────────────────────────  │
│                                     │
│  July                               │
│  ─────────────────────────────────  │
│                                     │
│  [🛒] Groceries         -₱3,200     │
│      Weekly shopping                 │
│      Jul 30                          │
│                                     │
└─────────────────────────────────────┘
│ [Home] [Transactions] [Budget] [Goals] [AI] │
└─────────────────────────────────────────────┘
```

---

### 9.5 Add Transaction Screen

```
┌─────────────────────────────────────┐
│  < Cancel            Add Expense    │
├─────────────────────────────────────┤
│                                     │
│  [●] Expense  [ ] Income  [ ] Transfer│
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Amount                             │
│  ₱ 350                              │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Category                           │
│  [Food                    >]        │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Description                        │
│  Lunch                              │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Date                               │
│  Today, Aug 29              [▼]     │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Account                            │
│  [Cash                    >]        │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  + Add notes                        │
│  + Add tags                         │
│  ☐ Make recurring                   │
│                                     │
│                                     │
│        [Save Transaction]           │
│                                     │
└─────────────────────────────────────┘
```

---

### 9.6 Budget Overview Screen

```
┌─────────────────────────────────────┐
│  < Budgets           [+ New Budget]  │
├─────────────────────────────────────┤
│                                     │
│  August 2026                        │
│                                     │
│  Total Budget: ₱35,000               │
│  Spent: ₱20,420                      │
│  Remaining: ₱14,580                  │
│  ████████████████░░░ 58%             │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Category Budgets                   │
│                                     │
│  Food                               │
│  ₱6,200 / ₱8,000                     │
│  ██████████░░░░░░░ 78%              │
│  ₱1,800 remaining                   │
│  ─────────────────────────────────  │
│                                     │
│  Transportation                     │
│  ₱3,100 / ₱5,000                     │
│  ████████░░░░░░░░░ 62%              │
│  ₱1,900 remaining                   │
│  ─────────────────────────────────  │
│                                     │
│  Bills                              │
│  ₱5,500 / ₱6,000                     │
│  ███████████░░░░░░ 92%              │
│  ⚠️ Approaching limit                │
│  ─────────────────────────────────  │
│                                     │
│  Shopping                           │
│  ₱2,400 / ₱3,000                     │
│  ████████░░░░░░░░░ 80%              │
│  ₱600 remaining                     │
│                                     │
└─────────────────────────────────────┘
│ [Home] [Transactions] [Budget] [Goals] [AI] │
└─────────────────────────────────────────────┘
```

---

### 9.7 Goals List Screen

```
┌─────────────────────────────────────┐
│  < Goals               [+ New Goal]  │
├─────────────────────────────────────┤
│                                     │
│  Emergency Fund                     │
│  ████████████████░░░░ 45%           │
│  ₱45,000 of ₱100,000                │
│  ₱55,000 remaining                  │
│  Target: Dec 2026                   │
│  Save ₱5,500/month to reach goal    │
│  ─────────────────────────────────  │
│                                     │
│  Vacation                           │
│  ████████░░░░░░░░░░░ 30%           │
│  ₱15,000 of ₱50,000                 │
│  ₱35,000 remaining                  │
│  Target: Mar 2027                   │
│  Save ₱4,200/month to reach goal    │
│  ─────────────────────────────────  │
│                                     │
│  New Phone                          │
│  ████████████░░░░░░░ 65%           │
│  ₱32,500 of ₱50,000                 │
│  ₱17,500 remaining                  │
│  Target: Oct 2026                   │
│  Save ₱8,750/month to reach goal    │
│                                     │
└─────────────────────────────────────┘
│ [Home] [Transactions] [Budget] [Goals] [AI] │
└─────────────────────────────────────────────┘
```

---

### 9.8 Analytics Screen

```
┌─────────────────────────────────────┐
│  < Analytics                        │
├─────────────────────────────────────┤
│  [This Month ▼]                     │
│                                     │
│  Income vs Expenses                 │
│  ┌────────────────────────────────┐│
│  │  [Bar Chart]                   ││
│  │  Income:  ████████████████     ││
│  │  Expenses: ██████████░░░░░     ││
│  │  Savings:  ██████░░░░░░░░░░░    ││
│  └────────────────────────────────┘│
│                                     │
│  Income     ₱45,000                 │
│  Expenses   ₱20,420                 │
│  Savings    ₱24,580                 │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Spending by Category               │
│  ┌────────────────────────────────┐│
│  │  [Donut Chart]                 ││
│  │  Food:        ████░░░░░░  30%  ││
│  │  Transport:   ██░░░░░░░░░  15%  ││
│  │  Bills:       ███░░░░░░░░  27%  ││
│  │  Shopping:    ██░░░░░░░░░  12%  ││
│  │  Other:       ██░░░░░░░░░  16%  ││
│  └────────────────────────────────┘│
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Monthly Trend                      │
│  ┌────────────────────────────────┐│
│  │  [Line Chart]                  ││
│  │  May:  ██████████░░░░░  ₱18K  ││
│  │  Jun:  ████████████░░░░  ₱22K  ││
│  │  Jul:  ████████████░░░░  ₱21K  ││
│  │  Aug:  ██████████░░░░░  ₱20K  ││
│  └────────────────────────────────┘│
│                                     │
│  Compared to last month: -₱1,580   │
│                                     │
└─────────────────────────────────────┘
│ [Home] [Transactions] [Budget] [Goals] [AI] │
└─────────────────────────────────────────────┘
```

---

### 9.9 AI Assistant Screen

```
┌─────────────────────────────────────┐
│  < AI Assistant                     │
├─────────────────────────────────────┤
│  ┌────────────────────────────────┐│
│  │ Good afternoon 👋               ││
│  │                                 ││
│  │ How can I help with your       ││
│  │ money today?                   ││
│  └────────────────────────────────┘│
│                                     │
│  [Can I afford something?]          │
│  [Analyze my spending]              │
│  [Help me save]                    │
│  [Review my budget]                │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  [👤] Can I spend ₱2,000 this      │
│       weekend?                     │
│                                     │
│  ┌────────────────────────────────┐│
│  │ [🤖] Probably, but be careful. ││
│  │                               ││
│  │ You currently have:           ││
│  │ ₱8,400 available              ││
│  │                               ││
│  │ Your planned expenses:        ││
│  │ ₱5,200                        ││
│  │                               ││
│  │ That leaves approximately:    ││
│  │ ₱3,200                        ││
│  │                               ││
│  │ A ₱2,000 purchase would leave ││
│  │ about ₱1,200.                 ││
│  │                               ││
│  │ If you need to keep at least  ││
│  │ ₱2,000 as a buffer, consider  ││
│  │ limiting to around ₱1,000.    ││
│  └────────────────────────────────┘│
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  [Ask a question...]               │
│                                     │
└─────────────────────────────────────┘
│ [Home] [Transactions] [Budget] [Goals] [AI] │
└─────────────────────────────────────────────┘
```

---

### 9.10 Settings Screen

```
┌─────────────────────────────────────┐
│  < Settings                         │
├─────────────────────────────────────┤
│                                     │
│  Profile                            │
│  [CJ]                        [>]    │
│  cj@example.com                     │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Preferences                        │
│  Currency              [PHP   >]   │
│  Theme                 [System >]   │
│  Language              [English >]  │
│  Date Format           [MM/DD >]    │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Security                           │
│  App Lock              [On     >]   │
│  Biometrics            [On     >]   │
│  Auto-lock timeout     [5 min  >]   │
│  Change PIN                            │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  AI Settings                         │
│  AI Memory             [On     >]   │
│  Model Version          [v1.0   >]  │
│  Clear AI Memory                      │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Notifications                       │
│  Budget Alerts         [On     >]   │
│  Goal Reminders        [On     >]   │
│  Upcoming Expenses    [On     >]   │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Data                                │
│  Backup & Restore        [>]        │
│  Export Data             [>]        │
│  Import Data             [>]        │
│  Clear All Data                        │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  About                              │
│  Version               1.0.0        │
│  Privacy Policy                      │
│  Terms of Service                    │
│  Send Feedback                       │
│                                     │
└─────────────────────────────────────┘
```

---

## 10. Navigation Flow

### 10.1 Main Navigation

```
Home (default)
    ↓
Transactions
    ↓
Budget
    ↓
Goals
    ↓
AI Assistant
```

### 10.2 Transaction Flow

```
Transaction List
    ↓ (tap transaction)
Transaction Details
    ↓ (tap edit)
Edit Transaction
    ↓ (tap delete)
[Confirm Delete]

Transaction List
    ↓ (tap + Add)
Add Transaction
    ↓ (save)
Transaction List
```

### 10.3 Budget Flow

```
Budget Overview
    ↓ (tap budget)
Budget Details
    ↓ (tap edit)
Edit Budget
    ↓ (save)
Budget Overview

Budget Overview
    ↓ (tap + New)
Create Budget
    ↓ (save)
Budget Overview
```

### 10.4 Goals Flow

```
Goals List
    ↓ (tap goal)
Goal Details
    ↓ (tap add contribution)
Add Contribution
    ↓ (save)
Goal Details

Goals List
    ↓ (tap + New)
Create Goal
    ↓ (save)
Goals List
```

### 10.5 AI Flow

```
AI Assistant
    ↓ (tap quick action)
[Pre-filled question]
    ↓ (send)
AI Response
    ↓ (follow-up question)
AI Response

AI Assistant
    ↓ (tap custom question)
[Type question]
    ↓ (send)
AI Response
```

---

## 11. Security Architecture

### 11.1 Security Measures

1. **Data Encryption at Rest**
   - SQLite database encryption using SQLCipher
   - Sensitive fields encrypted in app settings
   - Secure key storage using platform keychain/keystore

2. **Authentication**
   - PIN-based authentication (4-6 digits)
   - Biometric authentication (fingerprint/face)
   - Automatic app lock after timeout
   - Failed attempt lockout

3. **Secure Storage**
   - API keys in secure storage
   - Encryption keys in hardware-backed storage
   - No sensitive data in logs
   - No sensitive data in crash reports

4. **AI Privacy**
   - No financial data sent to cloud
   - AI inference performed locally
   - AI memory stored securely
   - Option to disable AI memory

5. **Backup Security**
   - Encrypted backup files
   - User-controlled encryption keys
   - Secure import validation
   - No automatic cloud sync

### 11.2 Key Management

```dart
class SecurityManager {
  // Generate encryption key
  Future<String> generateEncryptionKey();
  
  // Store key securely
  Future<void> storeKey(String key, String identifier);
  
  // Retrieve key securely
  Future<String?> retrieveKey(String identifier);
  
  // Delete key
  Future<void> deleteKey(String identifier);
  
  // Biometric authentication
  Future<bool> authenticateWithBiometrics();
  
  // PIN verification
  Future<bool> verifyPIN(String pin);
}
```

---

## 12. Offline Strategy

### 12.1 Offline-First Principles

1. **No Required Network Calls**
   - All core functionality works offline
   - No API dependencies for features
   - Graceful degradation for optional features

2. **Local Data Storage**
   - SQLite database for all financial data
   - Local file storage for exports
   - Secure local storage for settings

3. **Offline AI**
   - AI model runs on device
   - No cloud inference required
   - Model updates downloaded when available

4. **Offline Testing**
   - Test with airplane mode
   - Test with no network permissions
   - Test with disabled Wi-Fi and mobile data

### 12.2 Sync Strategy (Future)

When optional cloud sync is added:

1. **Opt-in Only**
   - User must explicitly enable
   - Clear communication about what syncs
   - Easy to disable

2. **Conflict Resolution**
   - Last-write-wins with timestamps
   - Manual conflict resolution UI
   - Preserve local data as source of truth

3. **Privacy-First**
   - End-to-end encryption
   - User-controlled encryption keys
   - No server-side data access

---

## 13. Backup and Restore Strategy

### 13.1 Backup Format

```json
{
  "version": "1.0.0",
  "exported_at": "2026-08-29T10:30:00Z",
  "user": {
    "name": "CJ",
    "currency": "PHP",
    "locale": "en_PH"
  },
  "data": {
    "accounts": [...],
    "categories": [...],
    "transactions": [...],
    "budgets": [...],
    "goals": [...],
    "recurring_transactions": [...],
    "settings": {...}
  },
  "encrypted": false,
  "checksum": "sha256hash"
}
```

### 13.2 Backup Process

1. Export all data to JSON
2. Optional encryption with user-provided password
3. Generate checksum for integrity
4. Save to device storage or share

### 13.3 Restore Process

1. Verify file format and version
2. Verify checksum
3. Decrypt if encrypted
4. Validate data integrity
5. Create backup of current data
6. Import new data
7. Rebuild indexes
8. Verify import success

---

## 14. Testing Strategy

### 14.1 Unit Tests

```dart
// Financial Calculations
test('calculate monthly income', () {
  // Test income calculation logic
});

test('calculate budget usage', () {
  // Test budget percentage calculation
});

test('calculate affordable spending', () {
  // Test affordability logic
});

// AI Tools
test('get_current_balance tool', () {
  // Test balance retrieval
});

test('get_expenses_by_category tool', () {
  // Test category expense aggregation
});

// Domain Logic
test('transaction validation', () {
  // Test transaction business rules
});

test('budget constraints', () {
  // Test budget validation
});
```

### 14.2 Integration Tests

```dart
test('database transaction creation', () {
  // Test database operations
});

test('repository pattern', () {
  // Test data layer integration
});

test('AI tool execution', () {
  // Test AI tool with real data
});

test('use case execution', () {
  // Test complete use case flows
});
```

### 14.3 Widget Tests

```dart
testWidgets('home screen renders correctly', (tester) {
  // Test home screen UI
});

testWidgets('transaction creation flow', (tester) {
  // Test transaction add flow
});

testWidgets('budget progress display', (tester) {
  // Test budget visualization
});
```

### 14.4 Offline Tests

```dart
test('app works without network', () {
  // Test with airplane mode
});

test('AI works offline', () {
  // Test AI without network
});

test('database operations offline', () {
  // Test local persistence
});
```

### 14.5 AI Evaluation Tests

```dart
test('AI answers monthly spending question', () {
  // Test: "How much did I spend this month?"
});

test('AI answers affordability question', () {
  // Test: "Can I afford ₱3,000?"
});

test('AI identifies overspending', () {
  // Test: "Why am I overspending?"
});

test('AI provides budget insights', () {
  // Test: "How am I doing on my budget?"
});

test('AI does not hallucinate data', () {
  // Verify AI uses only tool data
});

test('AI distinguishes estimates from facts', () {
  // Verify clear labeling
});
```

---

## 15. Performance Requirements

### 15.1 Performance Targets

- **App Launch:** < 2 seconds
- **Screen Transitions:** < 300ms
- **Transaction Save:** < 500ms
- **List Loading:** < 500ms
- **Chart Rendering:** < 1 second
- **AI Response:** < 5 seconds (simple queries)
- **Search:** < 300ms

### 15.2 Memory Management

- **App Memory:** < 150MB baseline
- **AI Model:** < 100MB when loaded
- **Database:** Efficient paging for large datasets
- **Image Caching:** Size limits and cleanup

### 15.3 Battery Optimization

- **Background Processing:** Minimal
- **AI Inference:** On-demand only
- **Location:** Not used
- **Push Notifications:** Local only

---

## 16. Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)
- [ ] Project setup with Flutter
- [ ] Architecture implementation
- [ ] Design system setup
- [ ] Database schema and migrations
- [ ] Dependency injection setup
- [ ] Navigation structure
- [ ] Basic settings screen

### Phase 2: Financial Core (Weeks 3-5)
- [ ] Account management
- [ ] Category management
- [ ] Transaction CRUD
- [ ] Transaction list and search
- [ ] Basic financial calculations
- [ ] Transaction editing and deletion

### Phase 3: Budget System (Weeks 6-7)
- [ ] Budget creation and management
- [ ] Budget item management
- [ ] Budget progress tracking
- [ ] Budget status calculations
- [ ] Budget alerts and warnings

### Phase 4: Goals System (Week 8)
- [ ] Goal creation and management
- [ ] Goal progress tracking
- [ ] Goal completion calculations
- [ ] Goal notifications

### Phase 5: Analytics (Week 9)
- [ ] Spending by category
- [ ] Income vs expenses
- [ ] Monthly trends
- [ ] Chart implementations
- [ ] Analytics screen

### Phase 6: Local AI Infrastructure (Weeks 10-12)
- [ ] AI model management system
- [ ] AI runtime integration
- [ ] Tool system implementation
- [ ] Financial context builder
- [ ] Intent detection
- [ ] Response validation

### Phase 7: AI Assistant (Weeks 13-14)
- [ ] AI conversation UI
- [ ] AI tool implementations
- [ ] AI prompt management
- [ ] AI memory system
- [ ] AI insights generation
- [ ] Quick actions

### Phase 8: Security (Week 15)
- [ ] Encryption implementation
- [ ] Biometric authentication
- [ ] PIN authentication
- [ ] App lock
- [ ] Secure key management

### Phase 9: Backup & Restore (Week 16)
- [ ] Data export
- [ ] Data import
- [ ] Backup encryption
- [ ] Restore validation

### Phase 10: Polish & Testing (Weeks 17-18)
- [ ] Comprehensive testing
- [ ] Offline testing
- [ ] Performance optimization
- [ ] Accessibility audit
- [ ] UI polish
- [ ] Error handling

### Phase 11: Documentation & Deployment (Weeks 19-20)
- [ ] User documentation
- [ ] Developer documentation
- [ ] App store preparation
- [ ] Beta testing
- [ ] Bug fixes
- [ ] Production deployment

---

## 17. Success Criteria

### 17.1 Functional Requirements
- ✅ All core features work 100% offline
- ✅ AI assistant provides accurate financial insights
- ✅ Financial calculations are deterministic and accurate
- ✅ Data persists reliably across app sessions
- ✅ Security features protect sensitive data
- ✅ Backup/restore preserves data integrity

### 17.2 Non-Functional Requirements
- ✅ App launches in < 2 seconds
- ✅ UI feels responsive and smooth
- ✅ Battery usage is minimal
- ✅ Memory usage stays within limits
- ✅ Accessibility standards met
- ✅ Design is minimal and user-friendly

### 17.3 Quality Requirements
- ✅ 80%+ code coverage for critical paths
- ✅ All offline tests pass
- ✅ AI evaluation tests pass
- ✅ No critical bugs in production
- ✅ User satisfaction rating > 4.0/5.0

---

## 18. Future Enhancements

### 18.1 Potential Features
- Multi-currency support with historical rates
- Investment tracking
- Debt payoff planning
- Receipt scanning (OCR)
- Bank account aggregation (with user consent)
- Cloud sync (opt-in, encrypted)
- Shared budgets (for families)
- Advanced analytics and reporting
- Export to PDF/Excel
- Apple Watch/Android Wear companion
- Desktop companion app

### 18.2 AI Enhancements
- Larger model options
- Voice input/output
- Proactive insights
- Spending pattern recognition
- Anomaly detection
- Personalized recommendations
- Financial health scoring

---

## 19. Conclusion

This specification provides a comprehensive blueprint for building a production-ready, offline-first budget tracking mobile application with local AI. The architecture prioritizes privacy, performance, and user experience while maintaining flexibility for future enhancements.

The clean architecture ensures maintainability, the modular AI system allows for model evolution, and the offline-first approach guarantees reliability regardless of network conditions.

**Next Steps:**
1. Review and approve this specification
2. Set up Flutter project with chosen dependencies
3. Begin Phase 1 implementation
4. Establish development and testing workflows
5. Create initial database schema and migrations

---

**Document Version:** 1.0.0  
**Last Updated:** 2026-08-29  
**Status:** Ready for Implementation
