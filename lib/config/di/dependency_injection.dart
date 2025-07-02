import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Repositories
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/poem_repository.dart';
import '../../data/repositories/user_repository.dart';

// Services
import '../../data/services/storage_service.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/search_service.dart';
import '../../services/api/deepseek_api_client.dart';
import '../../services/cache/analysis_cache_service.dart';
import '../../services/analysis/text_analysis_service.dart';

// Providers
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

// Controllers
import '../../features/home/controllers/home_controller.dart';
import '../../features/books/controllers/book_controller.dart';
import '../../features/poems/controllers/poem_controller.dart';
import '../../features/search/controllers/search_controller.dart' as app;
import '../../features/settings/controllers/settings_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    try {
      // 1. Core Services
      final prefs = await SharedPreferences.getInstance();
      final firestore = FirebaseFirestore.instance;
      final storage = FirebaseStorage.instance;
      final analytics = FirebaseAnalytics.instance;

      // 2. Register Core Services
      Get.put<SharedPreferences>(prefs, permanent: true);
      Get.put<FirebaseFirestore>(firestore, permanent: true);
      Get.put<FirebaseAnalytics>(analytics, permanent: true);
      Get.put<FirebaseStorage>(storage, permanent: true);

      // Initialize Analysis Services - Move this before other services that might need it
      final analysisCacheService = AnalysisCacheService();
      await analysisCacheService.init();
      Get.put<AnalysisCacheService>(analysisCacheService, permanent: true);

      final deepseekClient = DeepSeekApiClient();
      Get.put<DeepSeekApiClient>(deepseekClient, permanent: true);

      final textAnalysisService = TextAnalysisService(deepseekClient, analysisCacheService);
      Get.put<TextAnalysisService>(textAnalysisService, permanent: true);

      // 3. Initialize Services
      final storageService = StorageService(
        storage: storage,
        prefs: prefs,
      );
      await storageService.initialize();
      Get.put<StorageService>(storageService, permanent: true);

      final analyticsService = AnalyticsService(analytics);
      Get.put<AnalyticsService>(analyticsService, permanent: true);

      // 4. Initialize Repositories
      final bookRepo = BookRepository(firestore);
      final poemRepo = PoemRepository(firestore);
      final userRepo = UserRepository(firestore, storageService);

      Get.put<BookRepository>(bookRepo, permanent: true);
      Get.put<PoemRepository>(poemRepo, permanent: true);
      Get.put<UserRepository>(userRepo, permanent: true);

      // 5. Initialize Providers
      final themeProvider = ThemeProvider(storageService);
      await themeProvider.loadTheme();
      Get.put<ThemeProvider>(themeProvider, permanent: true);

      final localeProvider = LocaleProvider(storageService);
      await localeProvider.loadLanguage();
      Get.put<LocaleProvider>(localeProvider, permanent: true);

      // 6. Register Controllers
      Get.lazyPut<HomeController>(
        () => HomeController(
          bookRepository: bookRepo,
          poemRepository: poemRepo,
          analyticsService: analyticsService,
        ),
        fenix: true,
      );

      Get.lazyPut<BookController>(
        () => BookController(bookRepo, analyticsService),
        fenix: true,
      );

      // Update PoemController registration - use put instead of lazyPut
      Get.put<PoemController>(
        PoemController(
          Get.find<PoemRepository>(),
          Get.find<AnalyticsService>(),
          Get.find<TextAnalysisService>(),
        ),
        permanent: true,  // Make it permanent
      );

      // Register SearchService before SearchController
      Get.lazyPut<SearchService>(
        () => SearchService(Get.find<FirebaseFirestore>()),
        fenix: true,
      );

      // Update SearchController registration
      Get.lazyPut<app.SearchController>(
        () => app.SearchController(Get.find<SearchService>()),
        fenix: true,
      );

      Get.lazyPut<SettingsController>(
        () => SettingsController(storageService, analyticsService),
        fenix: true,
      );

      debugPrint('Dependencies initialized successfully');
    } catch (e, stack) {
      debugPrint('Error initializing dependencies: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }
}