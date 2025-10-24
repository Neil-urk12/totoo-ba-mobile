# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-24

### Added

#### Core Features
- **Text-based Product Verification** - Search and verify drug products by name with real-time results
- **Image-based Product Verification** - Scan product labels using camera or gallery with AI-powered analysis
- **Saved Products Management** - Save, filter, and sort verified products with pull-to-refresh functionality
  - Filter by verification status (Verified/Not Verified)
  - Filter by classification (Text/Image)
  - Sort by date or product name
- **Community Reports System** - View and submit reports for suspicious products
  - Multi-criteria sorting capabilities
  - Pull-to-refresh functionality
  - Pagination support for better performance
- **Search History Tracking** - Complete history of user verification attempts
- **Settings & Preferences**
  - Dark/Light theme support with system preference detection
  - Account management and profile settings
- **Onboarding Experience** - Beautiful animated onboarding screen for new users

#### Technical Implementation
- **Authentication System** - Complete user registration and sign-in flow using Supabase
- **State Management** - Riverpod implementation for robust app state handling
- **API Integration** - RESTful API calls for product verification and data management
- **Local Storage** - SharedPreferences for offline data persistence
- **Image Processing** - Camera and gallery integration with permission handling
- **Responsive UI** - Material Design 3 implementation with smooth animations

#### Developer Experience
- **Code Quality** - Flutter linting and analysis configuration
- **Environment Management** - `.env` file support for configuration
- **Testing Framework** - Unit test setup and structure

### Changed
- Initial project setup with Flutter 3.9.2+ and Dart
- Supabase backend integration for authentication and data services
- Material Design 3 theme implementation
- Responsive layout system for various screen sizes

### Deprecated
- None in initial release

### Removed
- None in initial release

### Fixed
- None in initial release

### Security
- Secure API key management through environment variables
- User authentication and authorization implementation
- Data validation for user inputs and API responses

---

## Installation & Requirements

### System Requirements
- **Android**: API level 21+ (Android 5.0 Lollipop or higher)
- **Internet Connection**: Required for product verification and API calls
- **Permissions**: Camera access for image verification, storage for saving data

### Installation Steps
1. Download the APK from the release assets
2. Enable "Install from Unknown Sources" in Android settings
3. Install the APK file
4. Launch "Totoo Ba?" and complete the onboarding process

---

**Full Changelog**: https://github.com/Neil-urk12/totoo-ba-mobile/compare/...v1.0.0

[1.0.0]: https://github.com/Neil-urk12/totoo-ba-mobile/releases/tag/v1.0.0
