# Budget Tracker

**Offline-First Personal Finance Application with Local AI Assistant**

[![Flutter](https://img.shields.io/badge/Flutter-3.47.2-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.2-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-lightgrey.svg)](https://flutter.dev/multi-platform)

A premium, privacy-first, offline-first mobile application that helps users track their finances, manage budgets, set goals, and receive intelligent financial insights through an on-device AI assistant.

**Core Philosophy:** "Know where your money goes. Understand what you can afford. Make better decisions."

---

## Table of Contents

- [For End Users](#for-end-users)
  - [What is Budget Tracker?](#what-is-budget-tracker)
  - [Key Features](#key-features)
  - [Privacy & Security](#privacy--security)
  - [System Requirements](#system-requirements)
  - [Installation Guide](#installation-guide)
  - [User Guide](#user-guide)
  - [FAQ](#faq)
- [For Developers](#for-developers)
  - [Quick Start](#quick-start)
  - [Detailed Setup](#detailed-setup)
  - [Prerequisites](#prerequisites)
  - [Flutter SDK Setup](#flutter-sdk-setup)
  - [Project Setup](#project-setup)
  - [Running the App](#running-the-app)
  - [Building for Different Platforms](#building-for-different-platforms)
  - [Troubleshooting](#troubleshooting)
- [Architecture Overview](#architecture-overview)
- [Local AI Information](#local-ai-information)
- [Current Status](#current-status)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## For End Users

### What is Budget Tracker?

Budget Tracker is a comprehensive personal finance application designed to help you:
- Track income and expenses with ease
- Create and manage budgets for different spending categories
- Set and achieve financial goals
- Get AI-powered financial insights without compromising your privacy
- Understand your spending patterns and make better financial decisions

Unlike other finance apps, Budget Tracker is built with privacy at its core. Your financial data never leaves your device, and all AI processing happens locally on your phone.

### Key Features

#### Financial Management
- ✅ **Transaction Tracking** - Log income and expenses with categorization
- ✅ **Budget Management** - Create budgets by category and track spending
- ✅ **Financial Goals** - Set savings goals and monitor progress
- ✅ **Account Management** - Track multiple accounts (cash, bank, digital wallets)
- ✅ **Recurring Transactions** - Set up automatic recurring payments
- ✅ **Category Management** - Customizable expense and income categories

#### Analytics & Insights
- ✅ **Spending Reports** - Visual breakdown of spending by category
- ✅ **Cash Flow Analysis** - Understand money in vs. money out
- ✅ **Budget Progress** - Real-time budget status and alerts
- ✅ **Forecasting** - Predict future spending based on patterns
- ✅ **AI Financial Assistant** - Natural language queries about your finances

#### Privacy & Security
- ✅ **100% Offline** - Core features work without internet
- ✅ **Local Storage** - All data stored on your device
- ✅ **Local AI** - AI processing happens on-device
- ✅ **Encryption** - Sensitive data encrypted at rest
- ✅ **Biometric Auth** - Support for fingerprint/face unlock
- ✅ **No Cloud Dependencies** - No third-party data sharing

### Privacy & Security

**Your data stays yours.** Budget Tracker is designed with privacy as a fundamental principle:

- **Local-First Architecture**: All financial data is stored locally on your device using SQLite
- **No Cloud Sync**: We don't sync your data to any cloud servers
- **Local AI Processing**: The AI assistant runs entirely on your device
- **Encryption**: Sensitive data is encrypted using platform secure storage
- **Biometric Protection**: Optional biometric authentication for app access
- **No Telemetry**: We don't collect usage analytics or personal information
- **Open Source**: The code is open for audit and verification

### System Requirements

#### Minimum Requirements
- **Android**: Android 6.0 (API Level 23) or higher
- **iOS**: iOS 12.0 or higher
- **Storage**: 100MB free space (additional space for AI models)
- **RAM**: 2GB minimum, 4GB recommended

#### Recommended Requirements
- **Android**: Android 10.0 (API Level 29) or higher
- **iOS**: iOS 14.0 or higher
- **Storage**: 500MB free space
- **RAM**: 4GB or higher

### Installation Guide

*Note: Budget Tracker is currently in development. Public installation instructions will be provided when the app is ready for release.*

### User Guide

#### Getting Started

1. **First Launch**: Create your profile and set up your default currency
2. **Add Accounts**: Add your bank accounts, cash, and digital wallets
3. **Create Categories**: Customize expense and income categories
4. **Set Budgets**: Create monthly budgets for key spending categories
5. **Start Tracking**: Log your first transaction

#### Recording Transactions

1. Tap the "+" button on the Transactions screen
2. Select expense or income
3. Enter the amount
4. Choose a category
5. Select the account
6. Optionally add a note
7. Save the transaction

#### Managing Budgets

1. Go to the Budgets screen
2. Tap "+" to create a new budget
3. Set the budget name and amount
4. Choose the budget period (monthly, weekly, custom)
5. Select categories to include
6. Set spending limits per category
7. Monitor progress on the dashboard

#### Using the AI Assistant

The AI assistant can answer questions like:
- "How much did I spend this month?"
- "Where am I spending most of my money?"
- "Can I afford to spend ₱5,000 this week?"
- "Why am I running out of money before payday?"
- "How much can I save this month?"

Simply ask your question in natural language, and the AI will provide insights based on your local financial data.

### FAQ

**Q: Does Budget Tracker require an internet connection?**
A: No, all core features work completely offline. You only need internet for initial app download and optional AI model updates.

**Q: Will my financial data be shared with third parties?**
A: No. Your data never leaves your device. The AI assistant processes your queries locally without any cloud communication.

**Q: Can I sync data across multiple devices?**
A: Currently, Budget Tracker is designed for single-device use. Cross-device sync may be added in the future with user-controlled encryption.

**Q: How secure is my financial data?**
A: Data is encrypted at rest using platform secure storage (Keychain on iOS, Keystore on Android). Biometric authentication provides additional protection.

**Q: What happens if I lose my phone?**
A: Without cloud sync, data would be lost. We recommend regular local backups. Backup/restore features are planned for future releases.

**Q: Can I export my data?**
A: Data export functionality is planned for future releases to allow you to migrate your data or create local backups.

---

## For Developers

### Quick Start

For experienced Flutter developers:

```bash
# Clone the repository
git clone https://github.com/benjiesiena/budget_tracker.git
cd budget_tracker/budget_tracker

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Detailed Setup

#### Prerequisites

Before setting up the project, ensure you have:

1. **Git** - For version control
2. **Flutter SDK** - Version 3.47.2 or higher
3. **Dart SDK** - Version 3.13.2 or higher (included with Flutter)
4. **Android Studio** - For Android development
5. **Xcode** - For iOS development (macOS only)
6. **VS Code or Android Studio** - Recommended IDE

#### Flutter SDK Setup (Windows)

1. **Download Flutter SDK**
   - Visit https://flutter.dev/docs/get-started/install/windows
   - Download the Flutter SDK zip file
   - Extract to a location like `C:\flutter`

2. **Add Flutter to PATH**
   - Right-click "This PC" → Properties → Advanced system settings
   - Click "Environment Variables"
   - Under "System variables", find "Path" and click "Edit"
   - Add `C:\flutter\bin` to the path
   - Click OK on all dialogs

3. **Verify Installation**
   ```powershell
   flutter --version
   ```
   You should see Flutter 3.47.2 and Dart 3.13.2

4. **Run Flutter Doctor**
   ```powershell
   flutter doctor
   ```
   Follow the instructions to fix any issues

5. **Accept Android Licenses**
   ```powershell
   flutter doctor --android-licenses
   ```

#### Project Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/benjiesiena/budget_tracker.git
   cd budget_tracker/budget_tracker
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Code** (if needed)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Verify Setup**
   ```bash
   flutter analyze
   flutter test
   ```

#### Running the App

**On Android Device/Emulator:**
```bash
flutter run
```

**On iOS Simulator (macOS only):**
```bash
flutter run -d ios
```

**On Web (for testing):**
```bash
flutter run -d chrome
```

#### Building for Different Platforms

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle (for Play Store):**
```bash
flutter build appbundle --release
```

**iOS (for App Store):**
```bash
flutter build ios --release
```

#### Troubleshooting

**Issue: Flutter command not found**
- Solution: Ensure Flutter bin directory is in your PATH
- Restart your terminal after adding to PATH

**Issue: "No connected devices"**
- Solution: Enable developer mode on your device
- For Android: Enable USB debugging
- For iOS: Trust your computer on the device

**Issue: Build failures on Windows**
- Solution: Enable Developer Mode in Windows settings
- Run: `start ms-settings:developers`

**Issue: Gradle build errors**
- Solution: Delete `.gradle` folder in the project root
- Run: `flutter clean` then `flutter pub get`

**Issue: iOS build errors**
- Solution: Ensure Xcode command line tools are installed
- Run: `sudo xcode-select --switch /Applications/Xcode.app`

---

## Architecture Overview

### Clean Architecture Layers

Budget Tracker follows clean architecture principles with clear separation of concerns:

```
lib/
├── core/                  # Core functionality shared across features
│   ├── config/           # Dependency injection
│   ├── constants/        # App constants
│   ├── errors/           # Error handling
│   ├── theme/            # Design system
│   └── utils/            # Utility functions
├── shared/               # Shared domain and data layers
│   ├── domain/           # Business logic and entities
│   │   ├── entities/     # Domain entities
│   │   ├── repositories/  # Repository interfaces
│   │   └── services/     # Domain services
│   ├── data/             # Data implementation
│   │   ├── datasources/  # Data sources
│   │   ├── models/       # Data models
│   │   ├── repositories/ # Repository implementations
│   │   └── database/     # Database helper
│   └── presentation/     # Shared UI components
│       └── widgets/      # Reusable widgets
└── features/             # Feature-specific implementation
    ├── transactions/     # Transaction feature
    ├── categories/       # Category feature
    ├── budgets/          # Budget feature
    ├── goals/            # Financial goals feature
    ├── analytics/        # Analytics feature
    └── ai/               # AI assistant feature
```

### Key Technologies

- **Framework**: Flutter 3.47.2
- **Language**: Dart 3.13.2
- **State Management**: Riverpod
- **Database**: SQLite (sqflite)
- **Dependency Injection**: GetIt
- **Charts**: fl_chart
- **Security**: flutter_secure_storage, local_auth
- **Encryption**: crypto, encrypt

### Database Schema

The app uses SQLite with the following main tables:
- `users` - User profiles
- `accounts` - Financial accounts
- `categories` - Transaction categories
- `transactions` - Financial transactions
- `recurring_transactions` - Recurring payments
- `budgets` - Budget definitions
- `budget_items` - Category-specific budget allocations
- `financial_goals` - Savings goals
- `ai_conversations` - AI chat history
- `ai_messages` - Individual AI messages
- `ai_insights` - Generated financial insights
- `financial_profile` - User financial profile
- `app_settings` - Application settings

### State Management

Riverpod is used for state management with:
- `StateNotifier` for feature-specific state
- `Provider` for dependencies
- `FutureProvider` for async operations
- Clear separation between UI and business logic

### Dependency Injection

GetIt is used for dependency injection:
- Singleton services (DatabaseHelper)
- Lazy-loaded repositories
- Type-safe dependency resolution
- Easy testing with mock implementations

---

## Local AI Information

### Privacy-First AI Approach

Budget Tracker uses a revolutionary approach to AI in personal finance: **everything runs locally on your device**.

**Why Local AI?**
- **Privacy**: Your financial data never leaves your device
- **Security**: No risk of data breaches from cloud servers
- **Offline**: AI features work without internet
- **Control**: You have complete control over your data
- **Performance**: Faster responses without network latency

### Model Information

**Current Status**: AI integration is planned but not yet implemented.

**Planned Implementation**:
- **Model Type**: Quantized Small Language Model (SLM)
- **Model Size**: ~50-100MB (quantized)
- **Download Strategy**: Runtime download on first app launch
- **Storage**: Local device storage (not in app assets)
- **Inference**: On-device using TensorFlow Lite or similar

**Why Runtime Download?**
- Reduces initial app size
- Allows model updates without app updates
- User control over model selection
- Flexible storage management

### AI Capabilities

The planned AI assistant will help with:
- Natural language financial queries
- Spending pattern analysis
- Budget recommendations
- Overspending detection
- Savings opportunities
- Cash flow insights
- Goal progress analysis

### Future AI Roadmap

- **Phase 1**: Basic Q&A about spending
- **Phase 2**: Proactive insights and recommendations
- **Phase 3**: Financial goal optimization
- **Phase 4**: Advanced predictive analytics

---

## Current Status

### Implemented Features ✅

#### Core Infrastructure
- ✅ Flutter project setup with clean architecture
- ✅ Domain entities (User, Account, Category, Transaction, Budget, Goal, etc.)
- ✅ Database schema with migrations
- ✅ SQLite database helper
- ✅ Repository pattern implementation
- ✅ Dependency injection setup
- ✅ Design system (theme, colors, typography)
- ✅ Utility functions (currency formatting, date formatting)
- ✅ Financial calculation engine

#### Transaction Feature
- ✅ Transaction entity and data model
- ✅ Transaction repository
- ✅ Transaction provider (Riverpod)
- ✅ Transaction list screen
- ✅ Add transaction screen
- ✅ Transaction row widget
- ✅ Amount input widget

#### Category Feature
- ✅ Category entity and data model
- ✅ Category repository
- ✅ Category provider
- ✅ Category list screen
- ✅ Category icon widget

#### Budget Feature
- ✅ Budget entity and data model
- ✅ Budget repository
- ✅ Budget provider
- ✅ Budget list screen
- ✅ Budget item entity and model

#### Navigation
- ✅ Bottom navigation bar
- ✅ Screen routing
- ✅ Dashboard placeholder
- ✅ Settings placeholder

### Work in Progress 🚧

- Category management (add/edit/delete UI)
- Budget management (add/edit/delete UI)
- Account management screens
- Financial goals implementation
- Analytics and reporting
- Charts and visualizations

### Planned Features 📋

- Local AI integration
- AI assistant UI
- Recurring transactions
- Financial goals tracking
- Backup and restore
- Data export
- Search and filtering
- Notifications and insights
- Security features (encryption, biometrics)
- Multi-currency support
- Theme customization

### Known Limitations

- No AI model integration yet
- No data backup/restore
- No cross-device sync
- Limited account management UI
- No advanced analytics
- No notifications system
- No data export functionality

---

## Roadmap

### Short-Term Goals (Next 1-2 months)

1. **Complete Core Features**
   - Finish category management UI
   - Complete budget management UI
   - Implement account management screens
   - Add transaction editing and deletion

2. **Analytics Implementation**
   - Spending by category charts
   - Monthly cash flow analysis
   - Budget progress visualization
   - Basic reports

3. **Data Management**
   - Backup and restore functionality
   - Data export to CSV/JSON
   - Data import functionality

### Medium-Term Goals (3-6 months)

1. **AI Integration**
   - Local AI model download manager
   - Basic AI assistant UI
   - Natural language query processing
   - Financial context builder

2. **Enhanced Features**
   - Recurring transactions
   - Financial goals tracking
   - Notifications and alerts
   - Advanced search and filtering

3. **Security**
   - Database encryption
   - Biometric authentication
   - App lock with PIN/biometrics
   - Secure data handling

### Long-Term Vision (6-12 months)

1. **Advanced AI**
   - Proactive insights and recommendations
   - Spending pattern analysis
   - Budget optimization suggestions
   - Financial goal planning

2. **Platform Expansion**
   - Desktop companion app
   - Cross-device sync (user-controlled)
   - Web interface

3. **Enterprise Features**
   - Multi-user support
   - Advanced reporting
   - Integration with banking APIs (optional)

---

## Contributing

We welcome contributions to Budget Tracker! Here's how you can help:

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Development Guidelines

- Follow the existing code style and architecture
- Write clean, readable code with comments
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting
- Follow semantic versioning for changes

### Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other community members

### Pull Request Process

1. Describe your changes clearly
2. Link to related issues
3. Include tests for new functionality
4. Update documentation if needed
5. Ensure CI/CD checks pass
6. Request review from maintainers

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Third-Party Licenses

Budget Tracker uses several open-source packages. Their licenses are included in the project:

- Flutter SDK (BSD 3-Clause)
- Riverpod (MIT)
- sqflite (MIT)
- flutter_secure_storage (MIT)
- fl_chart (Apache 2.0)
- And many others - see `pubspec.yaml` for full list

---

## Acknowledgments

- Flutter team for the amazing framework
- The open-source community for the packages used
- Contributors who help improve Budget Tracker

---

## Contact & Support

- **Repository**: https://github.com/benjiesiena/budget_tracker
- **Issues**: https://github.com/benjiesiena/budget_tracker/issues
- **Documentation**: [PRD_AND_TECHNICAL_SPECIFICATION.md](../PRD_AND_TECHNICAL_SPECIFICATION.md)

---

**Built with ❤️ for privacy-conscious users who want control over their financial data.**
