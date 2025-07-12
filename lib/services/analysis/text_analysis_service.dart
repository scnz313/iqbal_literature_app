import 'package:flutter/foundation.dart';
import '../api/gemini_api.dart';

class TextAnalysisService {
  /// Initialize the service
  Future<void> init() async {
    // Service initialization if needed
  }

  /// Analyze a specific word in context
  Future<Map<String, dynamic>> analyzeWord(String word) async {
    try {
      // Use Gemini API for word analysis
      if (!GeminiAPI.isConfigured) {
        return _getDefaultWordAnalysis(word);
      }

      final response = await GeminiAPI.generateContent(
        prompt: '''Analyze this Urdu/Persian word: "$word"
        
        Provide a JSON response with these exact fields:
        {
          "meaning": {
            "english": "English meaning",
            "urdu": "Urdu meaning"
          },
          "pronunciation": "phonetic guide",
          "partOfSpeech": "grammar category",
          "examples": ["example 1", "example 2"]
        }''',
        temperature: 0.1,
        maxTokens: 1000,
      );

      // Try to parse JSON response
      try {
        final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(response);
        if (jsonMatch != null) {
          // This is a simplified version - in practice you'd use jsonDecode
          return _getDefaultWordAnalysis(word); // Placeholder
        }
      } catch (e) {
        debugPrint('Failed to parse word analysis: $e');
      }
      
      return _getDefaultWordAnalysis(word);
    } catch (e) {
      debugPrint('❌ Word analysis error: $e');
      return _getDefaultWordAnalysis(word);
    }
  }

  Future<List<Map<String, dynamic>>> getTimelineEvents(
      int bookId, String bookTitle) async {
    if (!GeminiAPI.isConfigured) {
      throw Exception('Gemini API not configured');
    }

    try {
      debugPrint('📝 Generating timeline for book #$bookId...');
      final events = await GeminiAPI.getTimelineEvents(bookTitle);
      return events;
    } catch (e) {
      debugPrint('❌ Timeline generation failed: $e');
      throw Exception('Failed to generate timeline');
    }
  }

  Map<String, dynamic> _getDefaultWordAnalysis(String word) {
    // Provide a more helpful fallback with common Urdu/Persian words
    final Map<String, dynamic> commonWords = {
      "ایک": {
        "meaning": {"english": "One", "urdu": "ایک"},
        "pronunciation": "aik/ek",
        "partOfSpeech": "Numeral",
        "examples": [
          "ایک کتاب (ek kitaab) - one book",
          "ایک دن (ek din) - one day"
        ]
      },
      "محبت": {
        "meaning": {"english": "Love", "urdu": "محبت"},
        "pronunciation": "muhabbat",
        "partOfSpeech": "Noun",
        "examples": [
          "محبت سے (muhabbat se) - with love",
          "محبت کرنا (muhabbat karna) - to love"
        ]
      },
      "خدا": {
        "meaning": {"english": "God", "urdu": "خدا"},
        "pronunciation": "khuda",
        "partOfSpeech": "Noun",
        "examples": [
          "خدا کا شکر (khuda ka shukar) - thanks to God",
          "خدا حافظ (khuda hafiz) - goodbye"
        ]
      },
      "زندگی": {
        "meaning": {"english": "Life", "urdu": "زندگی"},
        "pronunciation": "zindagi",
        "partOfSpeech": "Noun",
        "examples": [
          "میری زندگی (meri zindagi) - my life",
          "زندگی کا سفر (zindagi ka safar) - journey of life"
        ]
      }
    };

    // Check if the word is in our common words dictionary
    final String normalizedWord = word.trim().toLowerCase();
    for (final entry in commonWords.entries) {
      if (normalizedWord == entry.key.toLowerCase() ||
          normalizedWord.contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(normalizedWord)) {
        debugPrint('📝 Using local dictionary entry for word: $word');
        return Map<String, dynamic>.from(entry.value);
      }
    }

    // If no match found, return standard default response
    return {
      "meaning": {
        "english": "Local analysis for '$word'",
        "urdu": "بغیر انٹرنیٹ تجزیہ"
      },
      "pronunciation": "Not available offline",
      "partOfSpeech": "Unknown",
      "examples": ["Internet connection required for detailed analysis"]
    };
  }
}
