import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/poem.dart';
import '../../../data/repositories/poem_repository.dart';
import '../../../services/share/share_bottom_sheet.dart';
import 'package:iqbal_literature/services/analysis/analysis_bottom_sheet.dart';
import 'dart:convert'; // Add this import for jsonDecode
import '../../../data/repositories/note_repository.dart';
import '../../../data/models/notes/word_note.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../services/api/openrouter_service.dart';
import '../../../services/cache/analysis_cache_service.dart';
import '../../../data/services/analytics_service.dart';
import '../../../services/api/gemini_api.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../books/controllers/book_controller.dart';

class PoemController extends GetxController {
  final PoemRepository _poemRepository;
  final AnalyticsService _analyticsService;
  final NoteRepository _noteRepository = NoteRepository();
  late Box<WordNote> _notesBox;

  PoemController(
    this._poemRepository,
    this._analyticsService,
  ) {
    // Remove the TextAnalysisService dependency
  }

  final RxList<Poem> poems = <Poem>[].obs;
  final RxString currentBookName = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxSet<String> favorites = <String>{}.obs;
  final RxString viewType = ''.obs;
  final RxDouble fontSize = 20.0.obs;
  static const double minFontSize = 16.0;
  static const double maxFontSize = 36.0;
  final isShowingNotes = false.obs;

  // Add these properties at the top with other properties
  final isAnalyzing = false.obs;
  final showAnalysis = false.obs;
  final poemAnalysis = ''.obs;
  final Rx<Map<String, dynamic>> poemAnalysisStructured = Rx<Map<String, dynamic>>({});

  // Notes related properties
  final RxList<WordNote> currentPoemNotes = <WordNote>[].obs;
  final RxBool isLoadingNotes = false.obs;

  Timer? _debounce; // Add debounce timer

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
    _loadFontSize();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final bookId = args['book_id'];
      if (bookId != null) {
        loadPoemsByBookId(bookId);
      } else {
        loadAllPoems();
      }
    } else {
      loadAllPoems();
    }
    _initHive();
  }

  Future<void> _initHive() async {
    if (Hive.isBoxOpen('word_notes')) {
      _notesBox = Hive.box<WordNote>('word_notes');
      debugPrint('📝 PoemController: using already open word_notes box');
    } else {
      _notesBox = await Hive.openBox<WordNote>('word_notes');
      debugPrint('📝 PoemController: opened new word_notes box');
    }
  }

  Future<void> loadPoemsByBookId(dynamic bookId) async {
    try {
      debugPrint('\n==== LOADING BOOK POEMS ====');
      debugPrint('📥 Incoming book_id: $bookId (${bookId.runtimeType})');

      isLoading.value = true;
      error.value = '';
      poems.clear(); // Ensure list is empty

      // Parse book ID
      final int targetBookId;
      if (bookId is int) {
        targetBookId = bookId;
      } else if (bookId is String) {
        targetBookId = int.tryParse(bookId) ?? 3;
      } else {
        targetBookId = 3;
      }

      debugPrint('🔍 Parsed book_id: $targetBookId');

      if (targetBookId <= 0) {
        debugPrint('❌ Invalid book ID');
        error.value = 'Invalid book ID';
        return;
      }

      final result = await _poemRepository.getPoemsByBookId(targetBookId);

      debugPrint('📦 Repository returned ${result.length} poems');

      if (result.isEmpty) {
        debugPrint('⚠️ No poems found');
        error.value = 'No poems found for this book';
        return;
      }

      // Verify book IDs
      final validPoems = result.where((p) {
        final isValid = p.bookId == targetBookId;
        if (!isValid) {
          debugPrint('⚠️ Found poem with wrong book_id: ${p.bookId}');
        }
        return isValid;
      }).toList();

      poems.assignAll(validPoems);
      debugPrint('✅ Final result: ${poems.length} poems');
      debugPrint('Book IDs in list: ${poems.map((p) => p.bookId).toSet()}');
    } catch (e) {
      debugPrint('❌ Error: $e');
      error.value = 'Failed to load poems';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFavorites = prefs.getStringList('favorites') ?? [];
      favorites.addAll(savedFavorites.map((id) => id.toString()));
    } catch (e) {
      debugPrint('❌ Error loading favorites: $e');
    }
  }

  Future<void> _loadFontSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFontSize = prefs.getDouble('font_size');
      if (savedFontSize != null) {
        fontSize.value = savedFontSize.clamp(minFontSize, maxFontSize);
      }
    } catch (e) {
      debugPrint('❌ Error loading font size: $e');
    }
  }

  Future<void> _saveFontSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('font_size', fontSize.value);
    } catch (e) {
      debugPrint('❌ Error saving font size: $e');
    }
  }

  /// Navigate to a random poem from the entire collection
  Future<void> openRandomPoem() async {
    try {
      debugPrint('🎲 Opening random poem...');
      
      // Get all poems if not already loaded
      List<Poem> allPoems = poems.value;
      if (allPoems.isEmpty) {
        debugPrint('📚 Loading all poems for random selection...');
        allPoems = await _poemRepository.getAllPoems();
      }
      
      if (allPoems.isEmpty) {
        debugPrint('❌ No poems available for random selection');
        Get.snackbar(
          'No Poems Available',
          'Unable to load poems for random selection',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return;
      }
      
      // Select a random poem
      final random = Random();
      final randomIndex = random.nextInt(allPoems.length);
      final randomPoem = allPoems[randomIndex];
      
      debugPrint('🎯 Selected random poem: ${randomPoem.title} (ID: ${randomPoem.id})');
      
      // Log analytics event
      _analyticsService.logEvent(
        name: 'random_poem_opened',
        parameters: {
          'poem_id': randomPoem.id,
          'poem_title': randomPoem.title,
          'book_id': randomPoem.bookId,
          'total_poems_available': allPoems.length,
        },
      );
      
      // Navigate to poem detail view
      Get.toNamed('/poem-detail', arguments: randomPoem);
      
    } catch (e) {
      debugPrint('❌ Error opening random poem: $e');
      Get.snackbar(
        'Error',
        'Failed to open random poem. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  bool isFavorite(Poem poem) {
    return favorites.contains(poem.id.toString());
  }

  void toggleFavorite(Poem poem) {
    final id = poem.id.toString();
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
    _saveFavorites();

    _analyticsService.logEvent(
      name: 'toggle_poem_favorite',
      parameters: {
        'poem_id': poem.id,
        'is_favorite': favorites.contains(id),
      },
    );
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', favorites.toList());
    } catch (e) {
      debugPrint('❌ Error saving favorites: $e');
    }
  }

  Future<void> loadAllPoems() async {
    try {
      debugPrint('⏳ Loading all poems');
      isLoading.value = true;
      error.value = '';
      poems.clear();

      final result = await _poemRepository.getAllPoems();

      if (result.isEmpty) {
        error.value = 'No poems found';
      } else {
        poems.assignAll(result);
        debugPrint('✅ Loaded ${result.length} total poems');
        debugPrint(
            '📊 Poems from books: ${result.map((p) => p.bookId).toSet()}');
      }
    } catch (e) {
      debugPrint('❌ Error loading poems: $e');
      error.value = 'Failed to load poems';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> getBookName(int bookId) async {
    try {
      final bookController = Get.find<BookController>();
      final book = bookController.books.firstWhereOrNull((b) => b.id == bookId);
      return book?.name ?? '';
    } catch (e) {
      debugPrint('Error getting book name: $e');
      return '';
    }
  }

  void onPoemTap(Poem poem) {
    Get.toNamed('/poem-detail', arguments: poem);
  }

  void sharePoem(Poem poem) {
    if (Get.context != null) {
      ShareBottomSheet.show(Get.context!, poem);
    }
  }

  Future<void> refreshPoems() async {
    final args = Get.arguments;
    if (args is Map<String, dynamic> && args.containsKey('book')) {
      final book = args['book'];
      await loadPoemsByBookId(book.id);
    }
  }

  void increaseFontSize() {
    if (fontSize.value < maxFontSize) {
      fontSize.value += 2.0;
      // Debounce calls to _saveFontSize to prevent lag
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), _saveFontSize);
    }
  }

  void decreaseFontSize() {
    if (fontSize.value > minFontSize) {
      fontSize.value -= 2.0;
      // Debounce calls to _saveFontSize to prevent lag
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), _saveFontSize);
    }
  }

  // Generate a cache key for poem analysis
  String _generateCacheKey(String poemText) {
    // Use first 100 characters or full text if shorter, plus text length
    final textSample = poemText.length > 100 ? poemText.substring(0, 100) : poemText;
    return '${textSample.hashCode}_${poemText.length}';
  }

  Future<String> analyzePoemWithFallback(String poemText) async {
    final cacheKey = 'poem_analysis_${poemText.hashCode}';
    
    try {
      final cacheService = AnalysisCacheService();
      await cacheService.init();
      
      final cachedResult = await cacheService.getPoemAnalysis(cacheKey.hashCode);
      if (cachedResult != null && cachedResult is String && cachedResult.isNotEmpty) {
        debugPrint('📦 Using cached poem analysis');
        poemAnalysis.value = cachedResult;
        return cachedResult;
      }
    } catch (cacheError) {
      debugPrint('⚠️ Cache retrieval error: $cacheError');
    }

    try {
      isAnalyzing.value = true;
      
      // Use the new fallback method with enhanced error handling
      final analysis = await _analyzeWithFallback(poemText);
      
      poemAnalysis.value = analysis;
      
      // Cache the result
      try {
        final cacheService = AnalysisCacheService();
        await cacheService.init();
        await cacheService.cachePoemAnalysis(cacheKey.hashCode, analysis);
      } catch (cacheError) {
        debugPrint('⚠️ Cache save error: $cacheError');
      }
      
      return analysis;
    } catch (error) {
      debugPrint('❌ Poem analysis error: $error');
      final fallbackAnalysis = _createFallbackAnalysis(poemText, 'Analysis failed');
      poemAnalysis.value = fallbackAnalysis;
      return fallbackAnalysis;
    } finally {
      isAnalyzing.value = false;
    }
  }

  // New method with proper fallback handling
  Future<String> _analyzeWithFallback(String poemText) async {
    try {
      debugPrint('🤖 Starting analysis with Gemini API...');
      
      // Try Gemini API first with raw text response
      final response = await GeminiAPI.generateContent(
        prompt: '''Analyze this poem by Allama Iqbal with exceptional depth and scholarly expertise:

POEM:
$poemText

Provide a comprehensive analysis covering:

**SUMMARY:**
Write a detailed summary explaining the poem's core message, philosophical significance, and unique contribution to Iqbal's work.

**THEMES:**
• Primary Theme: [Central message with textual evidence]
• Secondary Themes: [Other important ideas with examples]
• Philosophical Elements: [Connection to Iqbal's Khudi philosophy]
• Spiritual Dimensions: [Mystical/Sufi elements]
• Social Commentary: [Social observations]
• Educational Messages: [Lessons for readers]

**HISTORICAL CONTEXT:**
• Dating: [When likely written and evidence]
• Historical Events: [Influences from Iqbal's era]
• Intellectual Development: [How it fits Iqbal's journey]
• Cultural Context: [Early 20th century Muslim India]
• Connection to Major Works: [Links to other works]
• Literary Influences: [Western, Islamic, Persian influences]
• Reform Context: [Role in Islamic renaissance]

**LITERARY ANALYSIS:**
• Structure and Form: [Formal elements, meter, rhyme]
• Language and Diction: [Word choice, tone, style]
• Imagery and Symbolism: [Metaphors, symbols, meanings]
• Poetic Devices: [Literary techniques with examples]
• Textual Analysis: [Line-by-line interpretation]
• Comparative Context: [Comparison to other works]
• Translation Considerations: [Language nuances]
• Aesthetic Elements: [Artistic achievement]

**CONTEMPORARY RELEVANCE:**
• Guidance for Muslims in the 21st Century: [Modern applications]
• Addressing Current Global Challenges: [Contemporary issues]
• Practical Wisdom for Personal Development: [Personal growth insights]
• Relevance to Contemporary Issues in Muslim Societies: [Current relevance]
• Universal Human Experiences: [Broader human themes]
• Application for Educators, Students, and Spiritual Seekers: [Educational value]
• Vital and Transformative Message: [Why it matters today]

Provide scholarly depth but keep the entire response around 400-450 words. For each major heading (SUMMARY, THEMES, CONTEXT, ANALYSIS, RELEVANCE) include no more than 3–4 concise bullet points. Avoid overly long paragraphs.''',
        temperature: 0.1,
        maxTokens: 8000,
      );
      
      debugPrint('✅ Gemini analysis successful');
      return response;
      
    } catch (geminiError) {
      debugPrint('⚠️ Gemini API failed: $geminiError');
      
      try {
        debugPrint('🔄 Trying OpenRouter as fallback...');
        final response = await OpenRouterService.getCompletion(
          '''Analyze this poem by Allama Iqbal in detail:

$poemText

Provide comprehensive analysis covering summary, themes, historical context, literary analysis, and contemporary relevance.'''
        );
        
        debugPrint('✅ OpenRouter analysis successful');
        return response;
        
      } catch (openRouterError) {
        debugPrint('⚠️ OpenRouter also failed: $openRouterError');
        
        // Return comprehensive offline fallback
        return _createFallbackAnalysis(poemText, 'Connection Issue');
      }
    }
  }

  // Helper to format analysis map to string if needed
  String _formatPoemAnalysis(Map<String, dynamic> analysis) {
    // Extract key sections
    final summary = analysis['summary']?.toString() ?? 'Not available';
    final themes = analysis['themes']?.toString() ?? 'Not available';
    final context = analysis['context']?.toString() ?? 'Not available';
    final literaryAnalysis =
        analysis['analysis']?.toString() ?? 'Not available';
    final relevance = analysis['relevance']?.toString() ?? 'Not available';

    // Return formatted string
    return '''Summary:
$summary

Themes:
$themes

Historical & Cultural Context:
$context

Literary Analysis:
$literaryAnalysis

Contemporary Relevance:
$relevance''';
  }

  // Simplified fallback analysis
  String _createFallbackAnalysis(String poemText, String errorContext) {
    return '''**SUMMARY:**
This appears to be a meaningful piece of poetry by Allama Iqbal. While we're unable to provide a detailed AI analysis at this moment due to connectivity issues, this poem likely explores themes common to Iqbal's work such as spiritual awakening, self-realization (Khudi), and the relationship between the individual and the divine.

**THEMES:**
• Self-realization and personal empowerment (Khudi)
• Spiritual awakening and divine connection
• Islamic identity and cultural renaissance
• Individual responsibility and action
• The relationship between humanity and God

**HISTORICAL & CULTURAL CONTEXT:**
Allama Iqbal (1877-1938) was a philosopher, poet, and political leader who played a key role in the Pakistan movement. His poetry was written during the decline of the Mughal Empire and the British colonial period, reflecting his vision for spiritual and intellectual revival of the Muslim community. This poem likely reflects his mature philosophical thinking developed between 1905-1938.

**LITERARY ANALYSIS:**
Iqbal's poetry characteristically uses rich metaphors, symbolic language, and draws from both Islamic and Persian literary traditions. His work demonstrates mastery of classical forms while addressing modern concerns. The poem likely employs imagery from nature, Islamic history, or mystical concepts to convey deeper philosophical meanings.

**CONTEMPORARY RELEVANCE:**
Iqbal's message of self-empowerment, spiritual growth, and individual responsibility remains highly relevant today. His emphasis on combining action with contemplation, and balancing material progress with spiritual development, offers guidance for contemporary readers seeking personal growth and meaningful engagement with their faith and community.

**Note:** This is a general analysis based on Iqbal's common themes. For a detailed, AI-powered analysis of this specific poem, please check your internet connection and try again.''';
  }

  Future<Map<String, dynamic>> analyzeWord(String word) async {
    try {
      isAnalyzing.value = true;

      try {
        // Try direct Gemini API approach first for more reliable results
        debugPrint('📝 Directly analyzing word: $word');
        final response = await GeminiAPI.generateContent(
          prompt: '''Analyze this Urdu/Persian word: "$word"
          
You MUST respond with ONLY a valid JSON object in this exact format, with no additional text:
{
  "meaning": {
    "english": "English meaning",
    "urdu": "Urdu meaning in English transliteration"
  },
  "pronunciation": "phonetic guide",
  "partOfSpeech": "grammar category",
  "examples": ["example 1", "example 2"]
}''',
          temperature: 0.1,
        );

        // Try to extract JSON from the response
        try {
          debugPrint(
              '📊 Raw word analysis response: ${response.substring(0, min(100, response.length))}...');

          // Extract JSON if response contains markdown code blocks
          Map<String, dynamic> result = {};

          if (response.contains('```json') || response.contains('```')) {
            // Extract JSON from markdown code block
            final startMarker =
                response.contains('```json') ? '```json' : '```';
            final endMarker = '```';

            final jsonStart =
                response.indexOf(startMarker) + startMarker.length;
            final jsonEnd = response.lastIndexOf(endMarker);

            if (jsonStart > 0 && jsonEnd > jsonStart) {
              final jsonStr = response.substring(jsonStart, jsonEnd).trim();
              debugPrint(
                  '📝 Extracted JSON: ${jsonStr.substring(0, min(100, jsonStr.length))}...');

              // Parse JSON with explicit type casting
              final dynamic rawData = jsonDecode(jsonStr);

              // Create a properly typed Map
              result = <String, dynamic>{};

              // Safely extract meaning map
              result['meaning'] = <String, String>{};
              if (rawData['meaning'] != null) {
                result['meaning'] = {
                  'english': rawData['meaning']['english']?.toString() ??
                      'Not available',
                  'urdu':
                      rawData['meaning']['urdu']?.toString() ?? 'Not available'
                };
              }

              // Extract other fields with safe conversions
              result['pronunciation'] =
                  rawData['pronunciation']?.toString() ?? 'Not available';
              result['partOfSpeech'] =
                  rawData['partOfSpeech']?.toString() ?? 'Unknown';

              // Handle examples list
              if (rawData['examples'] is List) {
                result['examples'] = (rawData['examples'] as List)
                    .map((e) => e.toString())
                    .toList();
              } else {
                result['examples'] = ['Example not available'];
              }

              return result;
            }
          }

          // If we couldn't extract from markdown, try entire JSON
          final jsonStart = response.indexOf('{');
          final jsonEnd = response.lastIndexOf('}') + 1;

          if (jsonStart >= 0 && jsonEnd > jsonStart) {
            final jsonStr = response.substring(jsonStart, jsonEnd);

            // Parse JSON with explicit type casting
            final dynamic rawData = jsonDecode(jsonStr);

            // Create a properly typed Map
            result = <String, dynamic>{};

            // Safely extract meaning map
            result['meaning'] = <String, String>{};
            if (rawData['meaning'] != null) {
              result['meaning'] = {
                'english': rawData['meaning']['english']?.toString() ??
                    'Not available',
                'urdu':
                    rawData['meaning']['urdu']?.toString() ?? 'Not available'
              };
            }

            // Extract other fields with safe conversions
            result['pronunciation'] =
                rawData['pronunciation']?.toString() ?? 'Not available';
            result['partOfSpeech'] =
                rawData['partOfSpeech']?.toString() ?? 'Unknown';

            // Handle examples list
            if (rawData['examples'] is List) {
              result['examples'] = (rawData['examples'] as List)
                  .map((e) => e.toString())
                  .toList();
            } else {
              result['examples'] = ['Example not available'];
            }

            return result;
          }
        } catch (jsonError) {
          debugPrint('⚠️ Error parsing word analysis JSON: $jsonError');
          // Fall back to service approach
        }
      } catch (directError) {
        debugPrint('⚠️ Direct word analysis failed: $directError');
        // Continue to service approach
      }

      // Return fallback if direct analysis fails
      return {
        'meaning': {
          'english': 'Analysis failed',
          'urdu': word,
        },
        'pronunciation': 'Not available',
        'partOfSpeech': 'Not available',
        'examples': ['Not available'],
      };
    } catch (e) {
      debugPrint('❌ Word analysis error: $e');
      return {
        'meaning': {
          'english': 'Analysis failed',
          'urdu': word,
        },
        'pronunciation': 'Not available',
        'partOfSpeech': 'Not available',
        'examples': ['Not available'],
      };
    } finally {
      isAnalyzing.value = false;
    }
  }

  void showHistoricalContext(BuildContext context, Poem poem) {
    debugPrint('Showing historical context for poem: ${poem.title}');
    _analyticsService.logEvent(
      name: 'view_historical_context',
      parameters: {'poem_id': poem.id},
    );

    // Show the historical context bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const Center(child: Text('Historical Context')),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> getHistoricalContext(int poemId) async {
    try {
      debugPrint('🔄 Getting historical context for poem ID: $poemId');
      isAnalyzing.value = true;

      final poem = poems.firstWhere((p) => p.id == poemId);
      debugPrint('📖 Found poem: ${poem.title}');

      // Try getting from cache first
      final cachedContext = await _poemRepository.getHistoricalContext(poemId);
      if (cachedContext != null) {
        debugPrint('📦 Using cached historical context');
        return cachedContext;
      }

      // Get fresh analysis from Gemini
      debugPrint('🤖 Requesting fresh analysis from Gemini...');
      final result =
          await GeminiAPI.getHistoricalContext(poem.title, poem.cleanData);

      // Cache the result for future use
      _poemRepository.saveHistoricalContext(poemId, result);

      // Return all sections from the analysis
      return {
        'year': result['year'] ?? 'Unknown',
        'historicalContext':
            result['historicalContext'] ?? 'No historical context available',
        'significance':
            result['significance'] ?? 'No significance data available',
        'culturalImportance': result['culturalImportance'],
        'religiousThemes': result['religiousThemes'],
        'politicalMessages': result['politicalMessages'],
        'specificAnalysis': result['factualInformation'],
        'imagery': result['imagery'],
        'metaphor': result['metaphor'],
        'symbolism': result['symbolism'],
        'theme': result['theme'],
      };
    } catch (e) {
      debugPrint('❌ Historical context error: $e');
      return {
        'year': 'Unavailable',
        'historicalContext':
            'Could not retrieve historical context. Please try again.',
        'significance': 'Analysis temporarily unavailable.'
      };
    } finally {
      isAnalyzing.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> getTimeline(String bookName,
      [String? timePeriod]) async {
    try {
      isAnalyzing.value = true;
      return await GeminiAPI.getTimelineEvents(bookName, timePeriod);
    } catch (e) {
      debugPrint('❌ Timeline generation failed: $e');
      return [
        {
          'year': 'N/A',
          'title': 'Timeline Unavailable',
          'description': 'Could not generate timeline',
          'significance': 'Please try again later'
        }
      ];
    } finally {
      isAnalyzing.value = false;
    }
  }

  /// Shows the poem analysis bottom sheet
  Future<void> showPoemAnalysis(String poemText) async {
    // Prevent multiple concurrent analysis requests
    if (isAnalyzing.value) {
      debugPrint('⚠️ Analysis already in progress, ignoring duplicate request');
      return;
    }

    // Ask user for preferred language first
    final BuildContext? context = Get.context;
    if (context == null) return;

    final String? chosenLang = await _chooseAnalysisLanguage(context);
    
    if (chosenLang == null) return; // user cancelled

    // Set loading state
    isAnalyzing.value = true;

    // Create analysis future with improved error handling
    Future<String> analysisFuture;
    
    try {
      if (chosenLang == 'en') {
        // For English, directly analyze without translation
        analysisFuture = analyzePoemWithFallback(poemText);
      } else {
        // For Urdu, analyze in English first, then translate
        analysisFuture = analyzePoemWithFallback(poemText).then((english) async {
          try {
            final urdu = await _translateText(english, true);
            return urdu; // Return raw text for analysis
          } catch (e) {
            debugPrint('⚠️ Translation failed: $e');
            return english; // fallback to English if translation fails
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error creating analysis future: $e');
      analysisFuture = Future.value(_createFallbackAnalysis(poemText, 'Analysis failed'));
    }

    AnalysisBottomSheet.show(
      context,
      'Poem Analysis',
      analysisFuture,
    ).whenComplete(() => isAnalyzing.value = false);
  }



  Future<String> _translateText(String text, bool toUrdu) async {
    final targetLang = toUrdu ? 'Urdu' : 'English';
    final prompt =
        'Translate the following poem analysis to $targetLang while preserving the section headings (e.g., "Summary:", "Themes:" etc.) in English and keeping bullet points format intact. Only provide the translated text without any additional commentary:\n\n$text';

    try {
      if (GeminiAPI.isConfigured) {
        return await GeminiAPI.generateContent(
          prompt: prompt,
          temperature: 0.3,
          maxTokens: 4000,
        );
      }
      // Fallback
      return await OpenRouterService.getCompletion(prompt);
    } catch (e) {
      debugPrint('❌ Translation error: $e');
      rethrow;
    }
  }

  // Methods for personal notes feature

  // Add a method to toggle notes visibility
  void toggleNotesVisibility(bool showing) {
    isShowingNotes.value = showing;
    debugPrint('📝 Notes visibility set to: $showing');
  }

  // Load notes for the current poem
  Future<void> loadPoemNotes(int poemId) async {
    isLoadingNotes.value = true;
    try {
      final notes = await _noteRepository.getNotesForPoem(poemId);
      currentPoemNotes.assignAll(notes);
      debugPrint('📝 Loaded ${notes.length} notes for poem $poemId');
    } catch (e) {
      if (e.toString().contains('already open')) {
        // If the box is already open, try to get notes directly
        try {
          final notes = getNotesForPoem(poemId);
          currentPoemNotes.assignAll(notes);
          debugPrint(
              '📝 Used direct method to load ${notes.length} notes for poem $poemId');
        } catch (directError) {
          debugPrint('❌ Error loading notes directly: $directError');
        }
      } else {
        debugPrint('❌ Error loading notes: $e');
      }
    } finally {
      isLoadingNotes.value = false;
    }
  }

  // Add a new note for a word
  Future<void> addWordNote({
    required int poemId,
    required String word,
    required int position,
    required String note,
    required String verse,
  }) async {
    try {
      await _noteRepository.addNote(
        poemId: poemId,
        word: word,
        position: position,
        note: note,
        verse: verse,
      );

      // Refresh the notes list
      await loadPoemNotes(poemId);

      // Log analytics event
      _analyticsService.logEvent(
        name: 'add_word_note',
        parameters: {
          'poem_id': poemId,
          'word': word,
        },
      );
    } catch (e) {
      debugPrint('❌ Error adding note: $e');
    }
  }

  // Update an existing note
  Future<void> updateWordNote(WordNote note, String newNoteText) async {
    try {
      await _noteRepository.updateNote(note, newNoteText);

      // Refresh the notes list
      await loadPoemNotes(note.poemId);

      // Log analytics event
      _analyticsService.logEvent(
        name: 'update_word_note',
        parameters: {
          'poem_id': note.poemId,
          'word': note.word,
        },
      );
    } catch (e) {
      debugPrint('❌ Error updating note: $e');
    }
  }

  // Delete a note
  Future<void> deleteWordNote(WordNote note) async {
    try {
      await _noteRepository.deleteNote(note);

      // Refresh the notes list
      await loadPoemNotes(note.poemId);

      // Log analytics event
      _analyticsService.logEvent(
        name: 'delete_word_note',
        parameters: {
          'poem_id': note.poemId,
          'word': note.word,
        },
      );
    } catch (e) {
      debugPrint('❌ Error deleting note: $e');
    }
  }

  // Check if a word has a note
  bool hasNoteForWord(String word, int position) {
    return currentPoemNotes
        .any((note) => note.word == word && note.position == position);
  }

  // Get a specific note for a word
  WordNote? getNoteForWord(String word, int position) {
    try {
      return currentPoemNotes
          .firstWhere((note) => note.word == word && note.position == position);
    } catch (generalError) {
      debugPrint('Error getting note: $generalError');
      return null;
    }
  }

  WordNote? getNoteByPoemId(int poemId, String word, int position) {
    try {
      return _notesBox.values.firstWhere(
        (note) =>
            note.poemId == poemId &&
            note.word == word &&
            note.position == position,
      );
    } on StateError {
      // No matching element found
      return null;
    } catch (e) {
      debugPrint('Error getting note: $e');
      return null;
    }
  }

  List<WordNote> getNotesForPoem(int poemId) {
    try {
      return _notesBox.values.where((note) => note.poemId == poemId).toList();
    } catch (e) {
      debugPrint('Error getting notes: $e');
      return [];
    }
  }

  Future<void> saveNote(WordNote note) async {
    try {
      await _notesBox.add(note);
    } catch (e) {
      debugPrint('Error saving note: $e');
    }
  }

  Future<void> deleteNote(WordNote note) async {
    try {
      // For HiveObjects we need to use the key
      final int? key = _notesBox.keyAt(_notesBox.values.toList().indexOf(note));
      if (key != null) {
        await _notesBox.delete(key);
      }
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }

  Future<void> updateNote(WordNote note) async {
    try {
      // For HiveObjects we need to use the key
      final int? key = _notesBox.keyAt(_notesBox.values.toList().indexOf(note));
      if (key != null) {
        await _notesBox.put(key, note);
      }
    } catch (e) {
      debugPrint('Error updating note: $e');
    }
  }

  // UI helper for language selection
  Future<String?> _chooseAnalysisLanguage(BuildContext context) async {
    if (!context.mounted) return null;
    
    final theme = Theme.of(context);
    
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (ctx) {
        if (!ctx.mounted) return const SizedBox.shrink();
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(top: 12.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Select Analysis Language',
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLangChoice(ctx, 'English', Icons.language, 'en'),
                  _buildLangChoice(ctx, 'اردو', Icons.translate, 'ur'),
                ],
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLangChoice(BuildContext context, String label, IconData icon, String value) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.pop(context, value),
      child: Container(
        width: 120.w,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 28.h),
            SizedBox(height: 8.h),
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  // Clean analysis text from unwanted characters
  String _sanitizeAnalysisText(String input) {
    var text = input
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll('##', '')
        .replaceAll('^', '')
        .replaceAll('```', '')
        .trim();
    // Remove multiple blank lines
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return text;
  }
}
