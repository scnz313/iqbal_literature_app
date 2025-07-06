# 📚 Iqbal Literature - جاوید نامہ

A comprehensive Flutter application dedicated to the literary works of Dr. Allama Iqbal, the great poet-philosopher of the East. This app provides an immersive experience to explore Iqbal's poetry, prose, and philosophical writings with modern features and beautiful UI.

## 🌟 Features

### 📖 Literature Collection
- **Complete Poetry Collection**: Access to Iqbal's famous works including Bang-e-Dra, Bal-e-Jibril, Zarb-e-Kaleem, and more
- **Prose Works**: Philosophical writings and lectures
- **Multilingual Support**: Content in Urdu, Persian, and English
- **Beautiful Typography**: Authentic Nastaliq fonts for Urdu text

### 🔍 Smart Features
- **Advanced Search**: Find poems, verses, and themes across all works
- **AI-Powered Analysis**: Deep literary analysis using Gemini and DeepSeek APIs
- **Historical Context**: Background information and historical significance
- **Daily Verse**: Discover a new verse every day
- **Favorites**: Save and organize your favorite poems and verses

### 📱 User Experience
- **Modern UI/UX**: Clean, intuitive interface with Material Design
- **Round App Icons**: Modern adaptive icons for all platforms
- **Dark/Light Theme**: Comfortable reading in any lighting
- **Responsive Design**: Optimized for all screen sizes and tablets
- **Offline Support**: Read content without internet connection
- **Enhanced Sharing**: Share beautiful verses with improved PDF export
- **Performance Optimized**: Production-ready with debug modes disabled

### 🔧 Technical Features
- **Firebase Integration**: Real-time data sync and analytics
- **Local Database**: SQLite for offline storage
- **Production Ready**: Optimized builds with proper signing configuration
- **Cross-Platform**: Available on Android and iOS
- **Universal APK**: Support for all device architectures

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.2.0)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/hashimhameem/iqbal_literature.git
   cd iqbal_literature
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Create a new Firebase project
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Configure Firebase services (Firestore, Analytics, etc.)

4. **Configure App Icons**
   ```bash
   flutter pub run flutter_launcher_icons:main
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── config/           # App configuration and routing
├── core/            # Core utilities, themes, and constants
│   ├── utils/       # Debug utilities and responsive helpers
│   └── themes/      # App themes and text styles
├── data/            # Data layer (repositories, services)
├── di/              # Dependency injection
├── features/        # Feature modules
│   ├── books/       # Books and literature management
│   ├── poems/       # Poem viewing and interaction
│   ├── search/      # Search functionality
│   ├── favorites/   # User favorites
│   ├── settings/    # App settings
│   ├── historical_context/ # Historical context and analysis
│   └── ...
├── models/          # Data models
├── services/        # External services (API, cache, share)
│   ├── analysis/    # AI-powered text analysis
│   ├── api/         # External API clients
│   └── share/       # Sharing and PDF services
├── utils/           # Utility functions
└── widgets/         # Reusable UI components
```

## 🛠️ Built With

### Framework & Language
- **Flutter** - UI framework
- **Dart** - Programming language

### State Management
- **GetX** - State management and navigation

### Database & Storage
- **SQLite** - Local database
- **Firebase Firestore** - Cloud database
- **Firebase Storage** - File storage
- **Shared Preferences** - Local preferences

### AI & Analytics
- **Google Gemini API** - AI-powered text analysis
- **DeepSeek API** - Advanced literary analysis
- **Firebase Analytics** - User analytics
- **Firebase Crashlytics** - Crash reporting

### UI & Fonts
- **Google Fonts** - Typography
- **Nastaliq Fonts** - Authentic Urdu typography
- **Flutter ScreenUtil** - Responsive design
- **Shimmer** - Loading animations
- **Flutter Launcher Icons** - Adaptive app icons

## 📱 Screenshots

| Home Screen | Poetry Collection | Search Results | Analysis |
|-------------|-------------------|----------------|----------|
| ![Home](screenshots/home.png) | ![Books](screenshots/books.png) | ![Search](screenshots/search.png) | ![Analysis](screenshots/analysis.png) |

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:
```env
GEMINI_API_KEY=your_gemini_api_key
DEEPSEEK_API_KEY=your_deepseek_api_key
```

### Firebase Configuration
1. Set up Firebase project
2. Enable required services:
   - Firestore Database
   - Firebase Storage
   - Firebase Analytics
   - Firebase Crashlytics
   - Firebase Performance

### App Signing (Android)
For production releases, configure signing in `android/key.properties`:
```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=upload
storeFile=upload-keystore.jks
```

## 🚀 Building for Production

### Android
```bash
# App Bundle (recommended for Play Store)
flutter build appbundle --release

# Universal APK
flutter build apk --release

# Architecture-specific APKs
flutter build apk --release --split-per-abi
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Contribution Guidelines
- Follow Flutter/Dart best practices
- Write clear commit messages
- Add tests for new features
- Update documentation as needed

## 📝 Version History

### v1.1.0 (Current)
- ✨ **New Features:**
  - Round adaptive app icons for modern design
  - Enhanced tablet support with responsive layouts
  - Improved PDF export functionality
  - Better image sharing capabilities
  - Production-ready debug utilities

- 🔧 **Technical Improvements:**
  - Disabled debug modes for production
  - Optimized build configuration
  - Fixed app signing for Play Store
  - Universal APK support
  - Performance optimizations

- 🐛 **Bug Fixes:**
  - Fixed signing configuration issues
  - Resolved build compatibility problems
  - Improved error handling

### v1.0.2
- Enhanced AI-powered literary analysis
- Improved search functionality
- Better performance optimizations
- Bug fixes and stability improvements

### v1.0.1
- Added daily verse feature
- Enhanced UI/UX
- Performance improvements

### v1.0.0
- Initial release
- Complete poetry collection
- Basic search functionality
- Firebase integration

## 🌍 Localization

The app supports multiple languages:
- **Urdu** (اردو) - Primary
- **English** - Secondary
- **Persian** (فارسی) - For Persian poetry

## 📦 Build Artifacts

The app generates the following build artifacts:
- **App Bundle**: `build/app/outputs/bundle/release/app-release.aab` (~70MB)
- **Universal APK**: `build/app/outputs/apk/release/app-release.apk` (~79MB)
- **Architecture-specific APKs**: 24-44MB each (ARM64, ARMv7, x86_64, x86)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Dr. Allama Iqbal** - For his timeless literary contributions
- **Iqbal Academy Pakistan** - For preserving and promoting Iqbal's works
- **Flutter Community** - For the amazing framework and packages
- **Google Fonts** - For beautiful typography support
- **Firebase** - For robust backend services

## 📞 Support

For support, issues, or feature requests:
- Create an issue on GitHub
- Check the documentation files:
  - [Final Analysis Report](FINAL_ANALYSIS_REPORT.md)
  - [App Signing Guide](APP_SIGNING_GUIDE.md)
  - [Build Status Summary](BUILD_STATUS_SUMMARY.md)

---

**Made with ❤️ for the lovers of Iqbal's poetry**
