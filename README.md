# Totoo Ba? - AI Product Verification (Mobile Frontend)

**Totoo Ba?** is a Flutter mobile application designed to verify FDA Philippines-regulated products using text-based search and AI-powered image analysis. The app allows users to verify drug products, food products, medical devices, cosmetics, and establishments through an intuitive mobile interface.

This is the Repository exclusively for the mobile frontend portion of this project.
See the other parts of the project here:
- [Web](https://github.com/Neil-urk12/totoo-ba-web)
- [Backend](https://github.com/Neil-urk12/totoo-ba-backend)

## Table of Contents

1. [Features](#features)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Running the project](#running-the-project)
5. [Contributing](#contributing)
6. [Reporting Issues / Suggestions](#reporting-issues)

## Features

- **Text-based Product Verification** - Search and verify drug products by name with real-time results
- **Image-based Product Verification** - Scan product labels using camera or gallery with AI-powered analysis
- **Saved Products Management** - Save, filter, and sort verified products with pull-to-refresh functionality
- **Community Reports** - View and submit reports for suspicious products with pagination and sorting
- **Search History** - Track your verification history with detailed records
- **User Authentication** - Secure sign-in and registration system using Supabase
- **Settings & Preferences** - Dark/Light theme support and account management
- **Onboarding Experience** - Beautiful animated onboarding screen for new users
- **Responsive Design** - Material Design 3 with smooth animations and responsive layouts
  
## Prerequisites

- **Flutter SDK** 3.9.2 or higher
- **Dart SDK** 3.0.0 or higher
- **Git** for version control
- **Android Studio** (for Android development) or **VS Code** (with Flutter extensions)
- **Java JDK** 11 or higher (required for Android development)
- **Android SDK** (automatically installed with Android Studio)

### Supported Platforms
- **Android**: API level 21+ (Android 5.0 Lollipop or higher)
- **iOS**: iOS 11.0 or higher (requires macOS and Xcode for development)

### Optional Tools
- **Supabase CLI** (for backend management)
- **Flutter DevTools** (for debugging and performance analysis)

## Installation

### 1. Clone the Repository
```bash
git clone https://github.com/Neil-urk12/totoo-ba-mobile.git
cd totoo-ba-mobile
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Set Up Environment Configuration
1. Copy the environment template:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your actual values:
   ```env
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   OAUTH_REDIRECT_URL=your_oauth_redirect_url
   APP_NAME=Totoo ba?
   APP_VERSION=1.0.0
   ENABLE_OAUTH=true
   ENABLE_ANALYTICS=false
   ENABLE_CRASH_REPORTING=false
   BACKEND_API_URL=your_backend_api_url
   ```

3. **Get your Supabase credentials:**
   - Go to [Supabase Dashboard](https://supabase.com)
   - Create a new project or use existing one
   - Copy the URL and anon key from Settings > API

### 4. Verify Installation
```bash
# Check Flutter installation
flutter doctor

# Analyze code for any issues
flutter analyze

# Run tests
flutter test
```
## Running the Project

### Development Mode
1. **Start the development server:**
   ```bash
   flutter run
   ```

2. **For specific platform:**
   ```bash
   # Android
   flutter run -d android
   ```

3. **Enable hot reload** for faster development:
   - Press `r` in the terminal or click the hot reload button in your IDE

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/specific_test.dart
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format code
flutter format .

# Fix linting issues
dart fix --apply
```

### Debugging
1. **Using Flutter DevTools:**
   ```bash
   flutter pub global activate devtools
   flutter pub global run devtools --appSizeBase=your_app.apk
   ```

2. **Common debugging commands:**
   - `flutter clean` - Clean build cache
   - `flutter pub upgrade` - Update dependencies
   - `flutter doctor` - Check development environment

### Build for Production
```bash
# Build APK for Android
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

**APK Location:** `build/app/outputs/flutter-apk/app-release.apk`

### Troubleshooting
- **Permission Issues:** Make sure to grant camera and storage permissions in Android settings
- **Network Issues:** Verify your Supabase URL and API keys are correct
- **Build Issues:** Run `flutter clean && flutter pub get` to refresh dependencies
- **Performance Issues:** Use `flutter run --profile` to analyze performance
## Project Structure

```
lib/
├── config/              # Configuration files
│   ├── api_config.dart
│   └── supabase_config.dart
├── models/              # Data models
│   ├── drug_product.dart
│   ├── saved_record.dart
│   └── user.dart
├── providers/           # Riverpod state management
│   ├── auth_provider.dart
│   └── search_provider.dart
├── screens/             # UI screens
│   ├── home_screen.dart
│   ├── onboarding_screen.dart
│   └── settings_screen.dart
├── services/            # API services
│   ├── text_verification_service.dart
│   └── image_verification_service.dart
├── theme/               # App theming
│   └── app_theme.dart
└── widgets/             # Reusable UI components
    └── product_card.dart
```

## Contributing

We welcome contributions! Please follow these guidelines:

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/YourFeature`
3. Make your changes following Flutter best practices
4. Add tests for new functionality
5. Ensure code formatting: `flutter format .`
6. Run analysis: `flutter analyze`
7. Commit your changes: `git commit -m 'Add: Your feature description'`
8. Push to the branch: `git push origin feature/YourFeature`
9. Open a Pull Request

### Code Style Guidelines
- Follow [Flutter Style Guide](https://flutter.dev/docs/development/design/style)
- Use `const` constructors where possible
- Implement proper error handling
- Add documentation for public APIs
- Use meaningful variable and function names

### Before Submitting PR
- [ ] Run `flutter test` - all tests pass
- [ ] Run `flutter analyze` - no warnings or errors
- [ ] Test on physical device if possible
- [ ] Update documentation if needed
- [ ] Follow conventional commit messages

## Reporting Issues

We appreciate bug reports and feature requests! When reporting issues, please include:

### Bug Reports
- **Flutter version:** `flutter --version`
- **Device/Emulator details:** Model, OS version
- **Steps to reproduce:** Clear step-by-step instructions
- **Expected behavior:** What should happen
- **Actual behavior:** What actually happens
- **Error logs:** Console output and stack traces
- **Screenshots:** If applicable

### Feature Requests
- **Use case:** Describe the problem you're trying to solve
- **Proposed solution:** How you think it should work
- **Alternatives considered:** Other solutions you've considered
- **Additional context:** Any other relevant information

### Submit Issues
- Go to [Issues Page](https://github.com/Neil-urk12/totoo-ba-mobile/issues)
- Choose the appropriate template (Bug Report or Feature Request)
- Fill in all required information
- Add appropriate labels

---

## Acknowledgments

- [Supabase](https://supabase.com) for backend services
- [Flutter](https://flutter.dev) for the mobile framework
- [FDA Philippines](https://www.fda.gov.ph) for product verification data
- Community contributors and testers

---

**Made with ❤️ for the Filipino community**
