import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

import '../../../services/api/gemini_api.dart';
import '../../../services/api/deepseek_api_client.dart';
import '../models/timeline_event.dart';
import '../data/timeline_data.dart';

class HistoricalContextController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<TimelineEvent> timelineEvents = <TimelineEvent>[].obs;
  final RxString error = ''.obs;
  DeepSeekApiClient? _deepSeekClient;

  @override
  void onInit() {
    super.onInit();
    // Try to get DeepSeek client if it's available
    try {
      _deepSeekClient = Get.find<DeepSeekApiClient>();
      debugPrint('✅ DeepSeek client found for historical context');
    } catch (e) {
      debugPrint('ℹ️ DeepSeek client not available for historical context');
    }
  }

  Future<void> loadTimelineData(String bookName, {String? timePeriod}) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      debugPrint('📊 Loading timeline for book: $bookName');
      debugPrint('📊 Time period: $timePeriod');

      final events = await GeminiAPI.getTimelineEvents(bookName, timePeriod);

      if (events.isEmpty) {
        debugPrint('⚠️ No events from API, using default timeline');
        timelineEvents.value = defaultTimelineEvents;
        error.value = 'Using default timeline data';
        return;
      }

      timelineEvents.value =
          events.map((e) => TimelineEvent.fromMap(e)).toList();
      debugPrint('✅ Loaded ${timelineEvents.length} timeline events');
    } catch (e) {
      debugPrint('⚠️ Timeline error: $e');
      // Load default timeline on error
      timelineEvents.value = defaultTimelineEvents;
      error.value = 'Using default timeline data';
      debugPrint('✅ Fallback to default timeline (${defaultTimelineEvents.length} events)');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, String>> getHistoricalContext(String title,
      [String? content]) async {
    try {
      isLoading.value = true;
      error.value = '';

      try {
        debugPrint('📝 Requesting historical context from Gemini...');
        final result =
            await GeminiAPI.getHistoricalContext(title, content ?? '');
        if (_isValidHistoricalContext(result.cast<String, String>())) {
          return result.cast<String, String>();
        }
      } catch (e) {
        debugPrint('⚠️ Gemini failed: $e');
        // Try DeepSeek as fallback if available
        if (_deepSeekClient != null) {
          try {
            debugPrint('📝 Falling back to DeepSeek...');
            final result =
                await _deepSeekClient!.getHistoricalContext(title, content);
            final parsedResult = _parseHistoricalContext(result);
            if (_isValidHistoricalContext(parsedResult)) {
              return parsedResult;
            }
          } catch (e) {
            debugPrint('❌ DeepSeek failed: $e');
          }
        } else {
          debugPrint('ℹ️ DeepSeek not available, using default context');
        }
      }

      return _getDefaultHistoricalContext();
    } catch (e) {
      error.value = 'Failed to load historical context: $e';
      return _getDefaultHistoricalContext();
    } finally {
      isLoading.value = false;
    }
  }

  bool _isValidHistoricalContext(Map<String, String> context) {
    return context.values
        .every((value) => value.isNotEmpty && value != 'Not available');
  }

  String _extractSection(List<String> sections, String header) {
    try {
      final section = sections.firstWhere(
        (s) => s.trim().startsWith(header),
        orElse: () => '',
      );
      return section.replaceFirst(header, '').trim().replaceAll(
          RegExp(r'[^\x00-\x7F\s.,!?()-]'), ''); // Keep only basic characters
    } catch (e) {
      return 'Not available';
    }
  }



  Map<String, String> _getDefaultHistoricalContext() {
    return {
      'year': 'Unknown',
      'historicalContext':
          'Historical context information is currently unavailable.',
      'significance': 'Please try again later.',
    };
  }

  Map<String, String> _parseHistoricalContext(String response) {
    try {
      final sections = response.split('\n\n');
      return {
        'year': _extractSection(sections, 'Year:'),
        'historicalContext': _extractSection(sections, 'Historical Context:'),
        'significance': _extractSection(sections, 'Significance:'),
      };
    } catch (e) {
      debugPrint('Error parsing historical context: $e');
      return _getDefaultHistoricalContext();
    }
  }
}
