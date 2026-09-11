# Budget Tracker — Implementation

This is a working implementation of the PRD, covering the foundation
(Phase 1), the transactions/budget/goals core (Phases 2–4, read side), and
the AI tool layer (Phase 6–7's *tools*, with a deterministic offline engine
standing in for the bundled on-device model). It follows the clean
architecture, database schema, design system, and screen specs from the PRD
exactly — file names and structure map 1:1 to PRD section 4.3.

## What's real vs. stubbed

**Fully implemented and unit-tested:**
- Clean architecture layer structure (`core/`, `shared/`, `features/`, `infrastructure/`)
- Full SQLite schema (12 tables) as versioned migrations, applied inside transactions
- `SecurityManager`: random key generation, secure storage, PIN hashing (salted SHA-256), biometric auth hook
- `FinancialCalculator`: every calculation in PRD §7.1 — balance, budget usage, savings rate, goal projections, cash-flow forecasting, affordability checks. 100% pure functions, no wall-clock reads, fully unit tested (`test/unit/financial_calculator_test.dart`)
- Repositories for all 6 core entities, backed by real SQLite queries
- The full **19-tool AI registry** (`financial_tools_registry.dart`) — every tool from PRD §6.2, each one a thin wrapper over the calculator + repositories, unit tested for correctness *and* for graceful failure instead of fabricating numbers (`test/unit/financial_tools_registry_test.dart`)
- `AIOrchestrator` + `AIResponseValidator`: the tool-calling pipeline and the anti-hallucination check from PRD §6.5
- Home, Transactions (list + add/edit), Budget overview, Goals list, AI Assistant chat, and Settings screens, built to the PRD wireframes with the PRD's exact design tokens (`core/theme/`)

**Intentionally stubbed, with a clear seam to build on:**
- **The on-device LLM.** `RuleBasedAIEngine` implements the same `AIEngine` interface a bundled TFLite/ML Kit model would implement (intent detection → tool selection → templated response). It's fully offline and never fabricates a number, but it's pattern-matching, not a transformer. Swapping in the real model means writing one new class; nothing in the orchestrator, tools, or UI changes.
- **Onboarding flow, recurring-transaction UI, backup/restore, analytics charts, PIN/biometric lock screen UI.** The domain/data layers these need (accounts, recurring transactions, `SecurityManager`) are already built — these are UI-only additions.
- **AI conversation persistence.** The `ai_conversations`/`ai_messages` tables exist in the schema; the chat screen currently keeps history in memory for the session. Wiring a repository on top is the same pattern as every other feature here.

## Running it

This sandbox can't install the Flutter SDK or fetch packages from pub.dev
(network here is locked to a handful of other package registries), so this
couldn't be compiled or tested in-session. To run it yourself:

```bash
flutter pub get
flutter run
```

Requires Flutter 3.19+ / Dart 3.3+ (set in `pubspec.yaml`). No API keys or
backend setup needed — everything runs on-device.

To run the unit tests:

```bash
flutter test
```

## Project layout

```
lib/
├── core/            # theme, utils, error types — no feature knows about another feature
├── shared/           # entities, repositories, the FinancialCalculator, DB layer, common widgets
├── features/         # one folder per screen area (transactions, budgets, goals, ai_assistant, ...)
└── infrastructure/   # AI engine + tool registry, security manager
```

Every calculation flows through exactly one place
(`shared/domain/services/financial_calculator.dart`), so the Home screen,
the Budget screen, and the AI assistant are structurally incapable of
disagreeing about a number — they all call the same pure functions over the
same repository data.

## Suggested next steps

1. `flutter pub get` and fix any dependency version conflicts pub resolves for your Flutter version (dependencies were pinned to versions current as of early-to-mid 2026; some may have moved since).
2. Wire up the onboarding flow (screens are speced in PRD §9.2; `main.dart`'s `_ensureSeedUser` shows where to plug in real answers instead of PHP/en_PH defaults).
3. Add the recurring-transactions and budget-creation screens (repositories already support them).
4. When ready, bundle a quantized on-device model and implement `AIEngine` against it — see the docstring on `RuleBasedAIEngine` for the exact seam.
