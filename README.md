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
- **Dark/Light Theme**: Comfortable reading in any lighting
- **Responsive Design**: Optimized for all screen sizes
- **Offline Support**: Read content without internet connection
- **Share**: Share beautiful verses with friends and family

### 🔧 Technical Features
- **Firebase Integration**: Real-time data sync and analytics
- **Local Database**: SQLite for offline storage
- **Performance Optimized**: Smooth scrolling and fast search
- **Cross-Platform**: Available on Android and iOS

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

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── config/           # App configuration and routing
├── core/            # Core utilities, themes, and constants
├── data/            # Data layer (repositories, services)
├── di/              # Dependency injection
├── features/        # Feature modules
│   ├── books/       # Books and literature management
│   ├── poems/       # Poem viewing and interaction
│   ├── search/      # Search functionality
│   ├── favorites/   # User favorites
│   ├── settings/    # App settings
│   └── ...
├── models/          # Data models
├── services/        # External services (API, cache, etc.)
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

## 🚀 Building for Production

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
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

### v1.0.2 (Current)
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

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Dr. Allama Iqbal** - For his timeless literary contributions
- **Iqbal Academy Pakistan** - For preserving and promoting Iqbal's works
- **Flutter Community** - For the amazing framework and packages
- **Firebase** - For reliable backend services

## 📞 Contact & Support

- **Developer**: Hashim Hameem
- **Email**: [your-email@example.com]
- **GitHub**: [@hashimhameem](https://github.com/hashimhameem)

For support, email us or create an issue on GitHub.

---

<div align="center">

**"خودی کو کر بلند اتنا کہ ہر تقدیر سے پہلے"**  
*"Elevate yourself so much that before every destiny"*  
**خدا بندے سے خود پوچھے بتا تیری رضا کیا ہے**  
*"God Himself asks His servant: Tell me, what is your wish?"*

*- Dr. Allama Iqbal*

</div>
