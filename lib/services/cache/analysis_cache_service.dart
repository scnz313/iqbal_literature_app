
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // Added for jsonEncode

class AnalysisCacheService {
  static const String _boxName = 'analysis_cache';
  static const String _wordAnalysisPrefix = 'word_analysis_';
  static const String _poemAnalysisPrefix = 'poem_analysis_';
  static const String _timelinePrefix = 'timeline_';
  static const String _usageStatsKey = 'api_usage_stats';
  static const String _historyKey = 'analysis_history';
  static const Duration _cacheDuration = Duration(days: 30);

  // Rate limiting constants
  static const int _maxDailyRequests = 50;

  late Box _cacheBox;
  bool _isInitialized = false;

  // Public initialization method for compatibility
  Future<void> init() async {
    await _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    _cacheBox = await Hive.openBox(_boxName);
    _isInitialized = true;
  }

  Future<bool> canMakeRequest() async {
    await _initialize();
    final stats = await _getUsageStats();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Reset count if it's a new day
    if (stats['date'] != today) {
      await _resetDailyCount();
      return true;
    }

    return stats['count'] < _maxDailyRequests;
  }

  Future<void> incrementRequestCount() async {
    await _initialize();
    final stats = await _getUsageStats();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Reset count if it's a new day
    if (stats['date'] != today) {
      await _resetDailyCount();
      return;
    }

    stats['count'] = (stats['count'] as int) + 1;
    await _cacheBox.put(_usageStatsKey, stats);
  }

  Future<Map<String, dynamic>> _getUsageStats() async {
    await _initialize();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final stats = _cacheBox.get(_usageStatsKey);
    if (stats == null) {
      final newStats = {
        'date': today,
        'count': 0,
      };
      await _cacheBox.put(_usageStatsKey, newStats);
      return newStats;
    }

    return Map<String, dynamic>.from(stats);
  }

  Future<void> _resetDailyCount() async {
    await _initialize();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await _cacheBox.put(_usageStatsKey, {
      'date': today,
      'count': 0,
    });
  }

  Future<Map<String, dynamic>?> getWordAnalysis(String word) async {
    await _initialize();
    final key = '${_wordAnalysisPrefix}${word.toLowerCase()}';
    final cachedData = _cacheBox.get(key);

    if (cachedData != null) {
      try {
        final Map<String, dynamic> data = Map<String, dynamic>.from(cachedData);

        // Check if cache is still valid
        if (data.containsKey('timestamp')) {
          final timestamp = DateTime.parse(data['timestamp']);
          if (DateTime.now().difference(timestamp) < _cacheDuration) {
            debugPrint('📦 Using cached word analysis for "$word"');
            // Add to history
            await _addToHistory(word, 'word', data['timestamp']);

            // Make sure we return a proper Map<String, dynamic>
            if (data['analysis'] is Map) {
              return Map<String, dynamic>.from(data['analysis']);
            } else {
              debugPrint('⚠️ Cached word analysis has invalid format');
              return null;
            }
          }
        }
      } catch (e) {
        debugPrint('❌ Error retrieving cached word analysis: $e');
        return null;
      }
    }

    return null;
  }

  Future<void> cacheWordAnalysis(
      String word, Map<String, dynamic> analysis) async {
    await _initialize();
    final key = '${_wordAnalysisPrefix}${word.toLowerCase()}';
    final timestamp = DateTime.now().toIso8601String();

    final data = {
      'analysis': analysis,
      'timestamp': timestamp,
    };

    await _cacheBox.put(key, data);
    // Add to history
    await _addToHistory(word, 'word', timestamp);
    debugPrint('📦 Cached word analysis for "$word"');
  }

  Future<dynamic> getPoemAnalysis(int poemId) async {
    await _initialize();
    final key = '${_poemAnalysisPrefix}$poemId';
    final cachedData = _cacheBox.get(key);

    if (cachedData != null) {
      try {
        Map<String, dynamic> data;
        if (cachedData is Map && cachedData.keys.every((k) => k is String)) {
          data = Map<String, dynamic>.from(cachedData);
        } else {
          // Invalid structure – purge and return null
          await _cacheBox.delete(key);
          debugPrint('🗑️ Removed corrupt poem analysis cache for #$poemId');
          return null;
        }

        // Check timestamp validity
        if (data.containsKey('timestamp')) {
          final timestamp = DateTime.parse(data['timestamp']);
          if (DateTime.now().difference(timestamp) < _cacheDuration) {
            debugPrint('📦 Using cached poem analysis for poem #$poemId');
            await _addToHistory('Poem #$poemId', 'poem', data['timestamp']);
            return data['analysis']; // Could be String or Map
          }
        }
      } catch (e) {
        debugPrint('❌ Error retrieving cached poem analysis: $e');
        return null;
      }
    }

    return null;
  }

  Future<void> cachePoemAnalysis(int poemId, dynamic analysis) async {
    await _initialize();
    final key = '${_poemAnalysisPrefix}$poemId';
    final timestamp = DateTime.now().toIso8601String();

    final data = {
      'analysis': (analysis is Map) ? jsonEncode(analysis) : analysis,
      'timestamp': timestamp,
    };

    await _cacheBox.put(key, data);
    await _addToHistory('Poem #$poemId', 'poem', timestamp);
    debugPrint('📦 Cached poem analysis for poem #$poemId');
  }

  Future<List<Map<String, dynamic>>?> getTimelineEvents(int bookId) async {
    await _initialize();
    final key = '${_timelinePrefix}$bookId';
    final cachedData = _cacheBox.get(key);

    if (cachedData != null) {
      try {
        final Map<String, dynamic> data = Map<String, dynamic>.from(cachedData);

        // Check if cache is still valid
        if (data.containsKey('timestamp')) {
          final timestamp = DateTime.parse(data['timestamp']);
          if (DateTime.now().difference(timestamp) < _cacheDuration) {
            debugPrint('📦 Using cached timeline for book #$bookId');
            // Add to history
            await _addToHistory(
                'Book #$bookId Timeline', 'timeline', data['timestamp']);

            // Make sure we return a proper List<Map<String, dynamic>>
            if (data['timeline'] is List) {
              return (data['timeline'] as List)
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList();
            } else {
              debugPrint('⚠️ Cached timeline has invalid format');
              return null;
            }
          }
        }
      } catch (e) {
        debugPrint('❌ Error retrieving cached timeline: $e');
        return null;
      }
    }

    return null;
  }

  Future<void> cacheTimelineEvents(
      int bookId, List<Map<String, dynamic>> timeline) async {
    await _initialize();
    final key = '${_timelinePrefix}$bookId';
    final timestamp = DateTime.now().toIso8601String();

    final data = {
      'timeline': timeline,
      'timestamp': timestamp,
    };

    await _cacheBox.put(key, data);
    // Add to history
    await _addToHistory('Book #$bookId Timeline', 'timeline', timestamp);
    debugPrint('📦 Cached timeline for book #$bookId');
  }

  Future<void> _addToHistory(String item, String type, String timestamp) async {
    await _initialize();
    
    final rawHistory = _cacheBox.get(_historyKey);

    // Sanitize any previously-stored malformed history structure so that
    // it never breaks the caching layer again. We defensively parse every
    // entry and discard anything that does not exactly match the expected
    // {"item": String, "type": String, "timestamp": String} shape.
    final List<Map<String, dynamic>> historyList = [];

    if (rawHistory is List) {
      for (final entry in rawHistory) {
        try {
          if (entry is Map && entry.keys.every((k) => k is String)) {
            // Deep-copy to the target typed map – this will throw if any key
            // is not a String, which we then catch and skip.
            historyList.add(Map<String, dynamic>.from(entry));
          } else {
            debugPrint('⚠️ Skipping invalid history entry (wrong type): $entry');
          }
        } catch (e) {
          debugPrint('⚠️ Skipping corrupt history entry: $e');
        }
      }
    } else if (rawHistory != null) {
      // The stored value is not a list at all – purge it to avoid repeated failures.
      debugPrint('🗑️ Removing malformed analysis history structure');
      await _cacheBox.delete(_historyKey);
    }

    // Check if we're adding a duplicate (same item within last 5 entries)
    bool isDuplicate = false;
    for (int i = 0; i < historyList.length && i < 5; i++) {
      if (historyList[i]['item'] == item && historyList[i]['type'] == type) {
        isDuplicate = true;
        break;
      }
    }
    
    // Skip if it's a recent duplicate
    if (isDuplicate) {
      return;
    }

    // Create new entry
    final newEntry = {
      'item': item,
      'type': type,
      'timestamp': timestamp,
    };

    // Implement efficient insertion with size limit (keep newest 100)
    if (historyList.length >= 100) {
      // Remove oldest entry before adding new one
      historyList.removeLast();
    }
    
    // Add to beginning
    historyList.insert(0, newEntry);

    // Save back to cache
    await _cacheBox.put(_historyKey, historyList);
  }

  Future<List<Map<String, dynamic>>> getAnalysisHistory() async {
    await _initialize();
    final history = _cacheBox.get(_historyKey);
    
    if (history == null) {
      return [];
    }
    
    // Return a defensive copy to prevent external modifications
    return List<Map<String, dynamic>>.from(history);
  }

  // Add method to clean up old history entries
  Future<void> cleanupOldHistory({Duration maxAge = const Duration(days: 30)}) async {
    await _initialize();
    final history = _cacheBox.get(_historyKey);
    
    if (history == null || (history as List).isEmpty) {
      return;
    }
    
    final historyList = List<Map<String, dynamic>>.from(history);
    final cutoffTime = DateTime.now().subtract(maxAge);
    
    // Remove entries older than maxAge
    historyList.removeWhere((entry) {
      try {
        final timestamp = DateTime.parse(entry['timestamp']);
        return timestamp.isBefore(cutoffTime);
      } catch (e) {
        // Remove entries with invalid timestamps
        return true;
      }
    });
    
    await _cacheBox.put(_historyKey, historyList);
    debugPrint('🧹 Cleaned up ${history.length - historyList.length} old history entries');
  }

  Future<void> clearCache() async {
    await _initialize();

    // Clear everything except usage stats
    final keys = _cacheBox.keys.where((key) => key != _usageStatsKey).toList();
    for (final key in keys) {
      await _cacheBox.delete(key);
    }

    debugPrint('🧹 Analysis cache cleared');
  }
}
