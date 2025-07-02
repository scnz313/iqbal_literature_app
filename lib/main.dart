import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'utils/responsive_util.dart';
import 'utils/font_downloader.dart';
import 'config/routes/app_pages.dart';
import 'firebase_options.dart';
import 'services/cache/cache_service.dart';
import 'services/api/gemini_api.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'data/repositories/book_repository.dart';
import 'data/repositories/poem_repository.dart';
import 'services/cache/analysis_cache_service.dart';
import 'services/api/deepseek_api_client.dart';
import 'services/analysis/text_analysis_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/themes/app_theme.dart';
import 'features/home/controllers/home_controller.dart';
import 'data/services/analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/services/storage_service.dart';
import 'data/services/search_service.dart';
import 'features/books/controllers/book_controller.dart';
import 'features/poems/controllers/poem_controller.dart';
import 'features/search/controllers/search_controller.dart' as app;
import 'features/settings/controllers/settings_controller.dart';
import 'config/providers/theme_provider.dart';
import 'config/providers/locale_provider.dart';
import 'config/providers/font_scale_provider.dart';
import 'core/localization/app_translations.dart';
import 'data/models/notes/word_note.dart';
import 'data/repositories/note_repository.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Enable 120 Hz / highest available refresh rate on supported Android devices
  if (Platform.isAndroid) {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      debugPrint('⚠️ Unable to set high refresh rate: $e');
    }
  }

  // Optimize system UI initialization
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, // Allow both portrait orientations
    DeviceOrientation.landscapeLeft, // Allow landscape for tablets
    DeviceOrientation.landscapeRight,
  ]);

  try {
    // Platform-specific Firebase initialization logic
    if (Platform.isIOS) {
      // iOS: native side (AppDelegate.swift) handles Firebase initialization.
      // Just wait a bit to ensure it's done.
      debugPrint('⏳ Waiting for native Firebase initialization...');
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('✅ Proceeding after waiting; current Firebase apps: ${Firebase.apps.length}');
    } else {
      // Android/others: initialize from Dart side if needed
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('🔥 Firebase initialized from Dart side (non-iOS)');
      } else {
        debugPrint('🔥 Firebase already initialized (${Firebase.apps.length} apps)');
      }
    }

    // Initialize Hive for local storage
    await Hive.initFlutter();

    // Register Hive adapters
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(WordNoteAdapter());
    }

    // Clear Hive boxes to start fresh - remove this after fixing caching issues
    try {
      final booksBox = await Hive.openBox('books_cache');
      final favoritesBox = await Hive.openBox('favorite_books');
      await booksBox.clear();
      debugPrint('🧹 Cleared books cache to fix null ID issue');
    } catch (e) {
      debugPrint('⚠️ Error clearing book cache: $e');
    }

    // Preload fonts for PDF export in the background
    FontDownloader.preloadFonts().then((_) {
      debugPrint('✅ Font preloading completed for PDF export');
    });

    // Initialize services
    await CacheService.init();

    // Initialize GeminiAPI with newer key
    GeminiAPI.configure("AIzaSyC8sY9B8jI7cpdv8DFbMSmSVqjkwfH_ARQ");

    // Initialize core dependencies
    final prefs = await SharedPreferences.getInstance();
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;
    final analytics = FirebaseAnalytics.instance;

    // Register core services
    Get.put<SharedPreferences>(prefs, permanent: true);
    Get.put<FirebaseFirestore>(firestore, permanent: true);
    Get.put<FirebaseStorage>(storage, permanent: true);
    Get.put<FirebaseAnalytics>(analytics, permanent: true);

    // Initialize service layer
    final storageService = StorageService(storage: storage, prefs: prefs);
    await storageService.initialize();
    Get.put<StorageService>(storageService, permanent: true);

    final analyticsService = AnalyticsService(analytics);
    Get.put<AnalyticsService>(analyticsService, permanent: true);

    final analysisCacheService = AnalysisCacheService();
    await analysisCacheService.init();
    Get.put<AnalysisCacheService>(analysisCacheService, permanent: true);

    // Initialize repositories
    final bookRepository = BookRepository(firestore);
    final poemRepository = PoemRepository(firestore);

    Get.put<BookRepository>(bookRepository, permanent: true);
    Get.put<PoemRepository>(poemRepository, permanent: true);

    // Initialize providers
    final themeProvider = ThemeProvider(storageService);
    await themeProvider.loadTheme();
    Get.put<ThemeProvider>(themeProvider, permanent: true);

    final localeProvider = LocaleProvider(storageService);
    await localeProvider.loadLanguage();
    Get.put<LocaleProvider>(localeProvider, permanent: true);

    final fontScaleProvider = FontScaleProvider(storageService);
    Get.put<FontScaleProvider>(fontScaleProvider, permanent: true);

    // Initialize API services
    final deepseekClient = DeepSeekApiClient();
    Get.put<DeepSeekApiClient>(deepseekClient, permanent: true);

    final textAnalysisService =
        TextAnalysisService(deepseekClient, analysisCacheService);
    Get.put<TextAnalysisService>(textAnalysisService, permanent: true);

    // Initialize SearchService
    final searchService = SearchService(firestore);
    Get.put<SearchService>(searchService, permanent: true);

    // Initialize controllers
    Get.put<HomeController>(
      HomeController(
        bookRepository: bookRepository,
        poemRepository: poemRepository,
        analyticsService: analyticsService,
      ),
      permanent: true,
    );

    Get.put<BookController>(
      BookController(bookRepository, analyticsService),
      permanent: true,
    );

    Get.put<PoemController>(
      PoemController(
        poemRepository,
        analyticsService,
        textAnalysisService,
      ),
      permanent: true,
    );

    Get.put<app.SearchController>(
      app.SearchController(searchService),
      permanent: true,
    );

    Get.put<SettingsController>(
      SettingsController(storageService, analyticsService),
      permanent: true,
    );

    // Preload books data
    bookRepository.getAllBooks().then((books) {
      debugPrint('�� Preloaded ${books.length} books on app start');
    });

    // Register NoteRepository as a singleton
    if (!Get.isRegistered<NoteRepository>()) {
      Get.put(NoteRepository(), permanent: true);
    }

    runApp(const MyApp());
  } catch (e, stackTrace) {
    debugPrint('Error during initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    runApp(FallbackApp(error: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    // Use Obx to make the entire app reactive to locale changes
    return ScreenUtilInit(
        designSize:
            const Size(ResponsiveUtil.designWidth, ResponsiveUtil.designHeight),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Obx(() {
            final localeProvider = Get.find<LocaleProvider>();
            final themeProvider = Get.find<ThemeProvider>();

            return GetMaterialApp(
              title: 'app_name'.tr,
              debugShowCheckedModeBanner: false,
              initialRoute: AppPages.initial,
              getPages: AppPages.routes,

              // Theme configuration using the new ThemeProvider logic
              theme: themeProvider.currentThemeData,
              darkTheme: themeProvider.darkTheme,
              themeMode: themeProvider.themeMode,
              defaultTransition: Transition.fadeIn,

              // Add translations
              translations: AppTranslations(),

              // Configure localization
              locale: localeProvider.locale.value,
              fallbackLocale: const Locale('en', 'US'),

              unknownRoute: GetPage(
                name: '/notfound',
                page: () => const NotFoundScreen(),
              ),
            );
          });
        });
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('Page Not Found', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Get.offAllNamed(Routes.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class FallbackApp extends StatelessWidget {
  final String? error;
  const FallbackApp({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Something went wrong', style: TextStyle(fontSize: 18)),
              if (error != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              const Text('Please try again later', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
