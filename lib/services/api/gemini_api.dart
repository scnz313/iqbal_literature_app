import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Service class for interacting with Google's Gemini API
class GeminiAPI {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  static String? _apiKey;

  /// Configure the API key for Gemini
  static void configure(String apiKey) {
    _apiKey = apiKey;
    debugPrint(
        '🔑 Gemini API configured with key: ${apiKey.substring(0, 5)}...');
  }

  /// Check if API is configured
  static bool get isConfigured => _apiKey != null;

  /// Generate content using Gemini API
  static Future<String> generateContent({
    required String prompt,
    double temperature = 0.7,
    int maxTokens = 2000,
  }) async {
    if (!isConfigured) {
      throw Exception('Gemini API not configured. Call configure() first.');
    }

    try {
      debugPrint('🤖 Sending request to Gemini API...');

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'systemInstruction': {
            'parts': [
              {'text': 'You are a literary scholar specializing in Allama Iqbal\'s poetry. Provide direct, structured analysis without showing your reasoning process. Be concise and focused.'}
            ]
          },
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': temperature,
            'maxOutputTokens': maxTokens,
            'topP': 0.95,
            'topK': 32,
            'responseMimeType': 'text/plain',
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_NONE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_NONE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_NONE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_NONE'
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if the response has candidates
        if (data['candidates'] == null || data['candidates'].isEmpty) {
          debugPrint('⚠️ No candidates in Gemini API response');
          debugPrint('📄 Raw response: ${response.body}');
          throw Exception('No candidates in Gemini API response');
        }

        final candidate = data['candidates'][0];
        
        // Check for finish reason issues
        if (candidate['finishReason'] == 'MAX_TOKENS') {
          debugPrint('⚠️ Response truncated due to max tokens limit');
          // Continue processing but log the warning
        }

        // Try multiple content access patterns for different API versions
        String? content;
        
        // Pattern 1: Standard format with parts array
        if (candidate['content'] != null && 
            candidate['content']['parts'] != null &&
            candidate['content']['parts'].isNotEmpty &&
            candidate['content']['parts'][0]['text'] != null) {
          content = candidate['content']['parts'][0]['text'];
        }
        // Pattern 2: Direct text content (some API versions)
        else if (candidate['content'] != null && candidate['content']['text'] != null) {
          content = candidate['content']['text'];
        }
        // Pattern 3: Text directly in candidate
        else if (candidate['text'] != null) {
          content = candidate['text'];
        }
        // Pattern 4: Check for message content
        else if (candidate['message'] != null && candidate['message']['content'] != null) {
          content = candidate['message']['content'];
        }

        if (content == null || content.trim().isEmpty) {
          debugPrint('⚠️ Empty or null content in Gemini API response');
          debugPrint('📄 Raw response: ${response.body}');
          
          // Log the structure to help debug
          debugPrint('📋 Response structure:');
          debugPrint('- candidates[0]: ${candidate.keys.join(', ')}');
          if (candidate['content'] != null) {
            debugPrint('- content keys: ${candidate['content'].keys.join(', ')}');
          }
          
          throw Exception('Empty content in Gemini API response');
        }

        return content.toString().trim();
      }

      debugPrint(
          '❌ Gemini API Error: [${response.statusCode}] ${response.body}');
      throw Exception(
          'Gemini API Error ${response.statusCode}: ${response.body}');
    } catch (e) {
      debugPrint('❌ Gemini API Error: $e');
      rethrow;
    }
  }

  static String _sanitizeText(String text) {
    return text
        .replaceAll(RegExp(r'[^\x20-\x7E\s.,!?()-]'), '') // Keep only ASCII
        .replaceAll('"', "'")
        .replaceAll('"', "'")
        .replaceAll('"', "'")
        .replaceAll(''', "'")
        .replaceAll(''', "'").trim();
  }

  /// Generate poem analysis using specific prompt format
  static Future<Map<String, dynamic>> analyzePoemContent(String text) async {
    try {
      // Check if we're configured and if not, return a local fallback
      if (!isConfigured) {
        debugPrint(
            '⚠️ Gemini API not configured, using local fallback analysis');
        return _getLocalFallbackAnalysis(text);
      }

      final prompt =
          '''Analyze this poem by Allama Iqbal with exceptional depth, precision, and scholarly expertise. Provide a comprehensive, detailed analysis that demonstrates deep understanding of Iqbal's philosophy, literary techniques, and historical context.

POEM:
$text

Provide an extensive, scholarly analysis with these specific sections:

SUMMARY:
Write 6-8 detailed sentences that capture the poem's core message, philosophical significance, emotional impact, and unique contribution to Iqbal's body of work. Be specific about what the poem is actually saying, include direct textual references, and explain how it fits into Iqbal's broader philosophical framework.

THEMES:
Identify and thoroughly explain the major themes with extensive textual evidence:
• **Primary Theme**: [What is the central message? Quote specific lines and explain their deeper meaning]
• **Secondary Themes**: [What other important ideas appear? Provide detailed examples with line-by-line analysis]
• **Philosophical Elements**: [How does this connect to Iqbal's philosophy of Khudi, self-realization, Islamic revival, or reconstruction of religious thought? Be specific]
• **Spiritual Dimensions**: [What spiritual, mystical, or Sufi elements are present? Analyze the spiritual journey depicted]
• **Social Commentary**: [What does the poem say about society, community, or human relationships?]
• **Educational Messages**: [What lessons or guidance does the poem offer to readers?]

HISTORICAL CONTEXT:
Provide comprehensive background covering:
- Precise dating of when this poem was likely written and the evidence for this timing
- Detailed analysis of historical events that influenced Iqbal during this period
- How this poem fits into Iqbal's intellectual and spiritual development journey
- The social, political, and cultural context of early 20th century Muslim India
- Connection to Iqbal's major works (Asrar-e-Khudi, Rumuz-e-Bekhudi, etc.) and philosophical evolution
- Influence of Western philosophy, Islamic thought, and Persian literature on this work
- The poem's role in the broader context of Islamic renaissance and reform movements

LITERARY ANALYSIS:
Examine the poem's literary craft in extensive detail:
- **Structure and Form**: Analyze the poem's formal structure, meter, rhyme scheme, and organizational principles
- **Language and Diction**: Comment on word choice, tone, register, and stylistic techniques
- **Imagery and Symbolism**: Identify and interpret key metaphors, symbols, allegories, and their layered meanings
- **Poetic Devices**: Explain literary techniques used (repetition, alliteration, parallelism, etc.) with specific examples
- **Textual Analysis**: Quote exact lines and provide detailed line-by-line interpretation
- **Comparative Context**: How this poem compares to other Iqbal works and contemporary Persian/Urdu poetry
- **Translation Considerations**: If applicable, discuss how meaning is conveyed across languages
- **Aesthetic Elements**: Comment on the poem's beauty, emotional resonance, and artistic achievement

CONTEMPORARY RELEVANCE:
Explain in detail how this poem applies to modern times:
- What specific guidance does this poem offer to Muslims in the 21st century?
- How does it address current global challenges, identity questions, and spiritual needs?
- What practical wisdom can modern readers extract for personal development?
- How do the poem's themes relate to contemporary issues in Muslim societies?
- What universal human experiences does the poem illuminate?
- How can educators, students, and spiritual seekers apply these insights?
- Why does this message remain vital and transformative in our current era?

Provide scholarly depth, use extensive evidence from the text, quote specific lines with detailed interpretation, and offer meaningful insights that help readers truly understand what makes this poem a masterpiece of Islamic literature and philosophy.''';

      final response = await generateContent(
        prompt: prompt,
        temperature: 0.1, // Very low temperature for precise, accurate responses
        maxTokens: 8000, // Significantly increased from 4000 to 8000 for comprehensive analysis
      );

      debugPrint('📝 Raw Gemini Response: $response');

      // Create a new Map<String, dynamic> with explicit type
      final Map<String, dynamic> typedResult = <String, dynamic>{};

      try {
        // Clean markdown formatting and parse sections
        final cleanedResponse =
            response.replaceAll('**', '').replaceAll('*', '').trim();

        // Extract sections using patterns
        final summaryPattern = RegExp(r'SUMMARY:([^THEMES]+)', dotAll: true);
        final themesPattern = RegExp(r'THEMES:([^HISTORICAL]+)', dotAll: true);
        final contextPattern =
            RegExp(r'HISTORICAL CONTEXT:([^LITERARY]+)', dotAll: true);
        final analysisPattern = RegExp(r'LITERARY ANALYSIS:([^CONTEMPORARY]+)', dotAll: true);
        final relevancePattern = RegExp(r'CONTEMPORARY RELEVANCE:(.+)', dotAll: true);

        // Extract content for each section
        final summaryMatch = summaryPattern.firstMatch(cleanedResponse);
        final themesMatch = themesPattern.firstMatch(cleanedResponse);
        final contextMatch = contextPattern.firstMatch(cleanedResponse);
        final analysisMatch = analysisPattern.firstMatch(cleanedResponse);
        final relevanceMatch = relevancePattern.firstMatch(cleanedResponse);

        // Add each section to the result map
        typedResult['summary'] =
            summaryMatch?.group(1)?.trim() ?? 'Summary not available';
        typedResult['themes'] =
            themesMatch?.group(1)?.trim() ?? 'Themes not available';
        typedResult['context'] = contextMatch?.group(1)?.trim() ??
            'Historical context not available';
        typedResult['analysis'] = analysisMatch?.group(1)?.trim() ??
            'Literary analysis not available';
        typedResult['relevance'] = relevanceMatch?.group(1)?.trim() ??
            'Contemporary relevance not available';

        // Log the extracted sections
        debugPrint('📊 Extracted sections:');
        typedResult.forEach((key, value) {
          debugPrint(
              '$key: ${value.toString().substring(0, min(50, value.toString().length))}...');
        });
      } catch (parsingError) {
        debugPrint('⚠️ Error parsing response: $parsingError');

        // If parsing fails, use a simpler approach - split by headers
        final lines = response.split('\n');
        String currentSection = '';
        String sectionContent = '';

        for (final line in lines) {
          if (line.startsWith('SUMMARY:')) {
            currentSection = 'summary';
            continue;
          } else if (line.startsWith('THEMES:')) {
            if (currentSection.isNotEmpty) {
              typedResult[currentSection] = sectionContent.trim();
              sectionContent = '';
            }
            currentSection = 'themes';
            continue;
          } else if (line.contains('HISTORICAL CONTEXT:')) {
            if (currentSection.isNotEmpty) {
              typedResult[currentSection] = sectionContent.trim();
              sectionContent = '';
            }
            currentSection = 'context';
            continue;
          } else if (line.contains('LITERARY ANALYSIS:')) {
            if (currentSection.isNotEmpty) {
              typedResult[currentSection] = sectionContent.trim();
              sectionContent = '';
            }
            currentSection = 'analysis';
            continue;
          } else if (line.contains('CONTEMPORARY RELEVANCE:')) {
            if (currentSection.isNotEmpty) {
              typedResult[currentSection] = sectionContent.trim();
              sectionContent = '';
            }
            currentSection = 'relevance';
            continue;
          }

          if (currentSection.isNotEmpty) {
            sectionContent += line + '\n';
          }
        }

        // Add the last section
        if (currentSection.isNotEmpty) {
          typedResult[currentSection] = sectionContent.trim();
        }
      }

      // Ensure we have all required sections
      if (!typedResult.containsKey('summary')) {
        typedResult['summary'] = 'Summary not available';
      }
      if (!typedResult.containsKey('themes')) {
        typedResult['themes'] = 'Themes not available';
      }
      if (!typedResult.containsKey('context')) {
        typedResult['context'] = 'Historical context not available';
      }
      if (!typedResult.containsKey('analysis')) {
        typedResult['analysis'] = 'Literary analysis not available';
      }
      if (!typedResult.containsKey('relevance')) {
        typedResult['relevance'] = 'Contemporary relevance not available';
      }

      // Final validation - ensure all values are strings
      typedResult.forEach((key, value) {
        if (!(value is String)) {
          typedResult[key] = value.toString();
        }
      });

      // One more safety check - ensure the keys match what the application expects
      final List<String> expectedKeys = [
        'summary',
        'themes',
        'context',
        'analysis',
        'relevance'
      ];
      for (final key in expectedKeys) {
        if (!typedResult.containsKey(key) || typedResult[key] == null) {
          typedResult[key] = key == 'summary'
              ? 'Summary not available'
              : key == 'themes'
                  ? 'Themes not available'
                  : key == 'context'
                      ? 'Historical context not available'
                      : key == 'analysis'
                          ? 'Literary analysis not available'
                          : 'Contemporary relevance not available';
        }
      }

      // Log the final result
      debugPrint(
          '✅ Final Gemini response structure: ${typedResult.keys.join(', ')}');

      return typedResult;
    } catch (e) {
      debugPrint('❌ Gemini analysis error: $e');
      // Check if it's a network error
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('network') ||
          e.toString().contains('internet') ||
          e.toString().contains('timeout')) {
        debugPrint('📱 Using offline fallback analysis due to network error');
        return _getLocalFallbackAnalysis(text);
      }

      // Return a default analysis result rather than throwing
      return <String, dynamic>{
        'summary': 'Unable to analyze poem at this time.',
        'themes': 'Analysis currently unavailable.',
        'context': 'Please check your internet connection and try again later.',
        'analysis': 'We encountered an error during analysis: $e',
        'relevance': 'Contemporary relevance analysis unavailable.'
      };
    }
  }

  /// Provides a meaningful local analysis when APIs are unavailable
  static Map<String, dynamic> _getLocalFallbackAnalysis(String text) {
    // Deep analysis based on text patterns, structure, and Iqbal's thematic elements
    final String firstLine = text.split('\n').first.trim();
    final int lineCount = text.split('\n').where((line) => line.trim().isNotEmpty).length;
    final List<String> lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    // Advanced keyword and thematic analysis
    final String lowerText = text.toLowerCase();
    
    // Theme detection with more sophisticated patterns
    Map<String, bool> themes = {
      'khudi': lowerText.contains('خودی') || lowerText.contains('self') || lowerText.contains('soul') || lowerText.contains('khudi'),
      'ishq': lowerText.contains('عشق') || lowerText.contains('love') || lowerText.contains('passion') || lowerText.contains('ishq'),
      'nature': lowerText.contains('بلبل') || lowerText.contains('گل') || lowerText.contains('bird') || lowerText.contains('flower') || lowerText.contains('garden'),
      'divine': lowerText.contains('خدا') || lowerText.contains('الله') || lowerText.contains('god') || lowerText.contains('divine') || lowerText.contains('allah'),
      'freedom': lowerText.contains('آزادی') || lowerText.contains('freedom') || lowerText.contains('liberty') || lowerText.contains('azadi'),
      'knowledge': lowerText.contains('علم') || lowerText.contains('knowledge') || lowerText.contains('wisdom') || lowerText.contains('ilm'),
      'youth': lowerText.contains('جوان') || lowerText.contains('youth') || lowerText.contains('young'),
      'nation': lowerText.contains('قوم') || lowerText.contains('nation') || lowerText.contains('millat') || lowerText.contains('qaum'),
    };
    
    // Analyze structural elements
    bool hasQuestions = text.contains('?') || text.contains('کیا') || text.contains('کون');
    bool hasExclamations = text.contains('!') || text.contains('اے');
    bool hasRepetition = _detectRepetition(lines);
    
    // Determine poem type based on length and structure
    String poemType = lineCount <= 4 ? 'concise quatrain or rubai' : 
                     lineCount <= 10 ? 'short lyrical piece' :
                     lineCount <= 20 ? 'moderate ghazal or nazm' : 'extended philosophical composition';
    
    return <String, dynamic>{
      'summary': _generateDetailedSummary(firstLine, lineCount, poemType, themes, hasQuestions, hasExclamations),
      'themes': _generateThematicAnalysis(themes, text),
      'context': _generateHistoricalContext(themes, lineCount),
      'analysis': _generateLiteraryAnalysis(lineCount, poemType, hasRepetition, hasQuestions, hasExclamations, text),
      'relevance': _generateContemporaryRelevance(themes)
    };
  }
  
  static String _generateDetailedSummary(String firstLine, int lineCount, String poemType, Map<String, bool> themes, bool hasQuestions, bool hasExclamations) {
    String emotionalTone = hasExclamations ? 'passionate and declarative' : hasQuestions ? 'contemplative and inquiring' : 'reflective and meditative';
    String primaryTheme = themes['khudi'] == true ? 'self-realization' : 
                         themes['ishq'] == true ? 'divine love' :
                         themes['freedom'] == true ? 'liberation and independence' :
                         themes['divine'] == true ? 'spiritual connection' : 'philosophical contemplation';
    
    return 'This $poemType opens with the meaningful line "$firstLine" and unfolds across $lineCount verses with a $emotionalTone tone. '
           'The poem appears to center on themes of $primaryTheme, characteristic of Iqbal\'s profound engagement with both individual transformation and collective awakening. '
           'Through carefully crafted verses, it explores the relationship between personal spiritual development and broader social consciousness. '
           'The work demonstrates Iqbal\'s signature approach of using poetic beauty to convey deep philosophical insights about human potential and divine purpose. '
           'This analysis represents offline interpretation - for more detailed AI-powered insights, please connect to the internet.';
  }
  
  static String _generateThematicAnalysis(Map<String, bool> themes, String text) {
    List<String> themeAnalysis = [];
    
    if (themes['khudi'] == true) {
      themeAnalysis.add('• **Self-Realization (Khudi)**: This poem directly engages with Iqbal\'s central concept of Khudi - the development of individual consciousness and spiritual strength. The presence of self-referential language suggests exploration of personal empowerment and inner awakening.');
    }
    
    if (themes['ishq'] == true) {
      themeAnalysis.add('• **Divine Love (Ishq)**: The poem appears to explore themes of passionate spiritual love, reflecting Iqbal\'s belief that divine love is the driving force behind all meaningful human action and transformation.');
    }
    
    if (themes['freedom'] == true) {
      themeAnalysis.add('• **Freedom and Liberation**: References to freedom suggest this poem addresses both spiritual liberation from inner constraints and potentially political freedom from external oppression.');
    }
    
    if (themes['knowledge'] == true) {
      themeAnalysis.add('• **Knowledge and Wisdom**: The poem seems to emphasize the importance of learning and intellectual development as pathways to both individual growth and collective progress.');
    }
    
    if (themes['divine'] == true) {
      themeAnalysis.add('• **Divine Connection**: Strong spiritual themes indicate exploration of humanity\'s relationship with the divine, reflecting Iqbal\'s integration of Islamic spirituality with philosophical inquiry.');
    }
    
    // Add default themes if none detected
    if (themeAnalysis.isEmpty) {
      themeAnalysis.addAll([
        '• **Spiritual Awakening**: Following Iqbal\'s consistent focus, this poem likely addresses the awakening of spiritual consciousness and awareness of divine purpose.',
        '• **Individual Empowerment**: True to Iqbal\'s philosophy, the poem probably emphasizes the importance of strong, self-aware individuals in creating positive change.',
        '• **Cultural Identity**: The work appears to explore themes of cultural and religious identity, particularly relevant to the Muslim experience.'
      ]);
    }
    
    return themeAnalysis.join('\n\n');
  }
  
  static String _generateHistoricalContext(Map<String, bool> themes, int lineCount) {
    String historicalFocus = themes['freedom'] == true ? 'struggle for independence' :
                            themes['nation'] == true ? 'community building and nationhood' :
                            themes['knowledge'] == true ? 'educational reform and intellectual revival' :
                            'spiritual and cultural renaissance';
    
    return 'This poem emerges from Iqbal\'s mature period (1905-1938) when he was actively responding to the challenges facing Muslims in colonial India. '
           'Written during an era of intense intellectual ferment, it reflects his engagement with the $historicalFocus that defined his generation. '
           'The work fits within Iqbal\'s broader project of revitalizing Islamic thought and practice, drawing from both classical Islamic sources and modern philosophical insights. '
           'It represents his ongoing effort to inspire Muslims toward both individual excellence and collective renewal during a critical period of social and political transformation. '
           'The poem contributes to the intellectual foundation that would later influence the Pakistan movement and continues to shape contemporary Islamic discourse.';
  }
  
  static String _generateLiteraryAnalysis(int lineCount, String poemType, bool hasRepetition, bool hasQuestions, bool hasExclamations, String text) {
    String structuralAnalysis = 'The poem follows the structure of a $poemType, allowing for ${lineCount <= 10 ? 'concentrated philosophical expression' : 'extended development of complex themes'}.';
    String rhetoricalDevices = hasQuestions ? 'Rhetorical questions engage readers in active contemplation' : 
                              hasExclamations ? 'Exclamatory expressions create emotional intensity' : 
                              'Declarative statements build philosophical arguments systematically';
    String repetitionNote = hasRepetition ? 'Repetitive elements create emphasis and musical rhythm.' : 'Varied expression maintains reader engagement throughout.';
    
    bool hasUrduText = text.contains(RegExp(r'[\u0600-\u06FF]'));
    String languageNote = hasUrduText ? 'The original Urdu/Persian text employs classical poetic meters and traditional imagery' : 
                         'This English translation maintains the essence of Iqbal\'s original poetic vision';
    
    return '**Structure and Form**: $structuralAnalysis The organization allows for systematic development of the central message while maintaining poetic beauty.\n\n'
           '**Language and Style**: $languageNote, demonstrating Iqbal\'s mastery of multiple literary traditions. The diction combines intellectual precision with emotional resonance.\n\n'
           '**Rhetorical Techniques**: $rhetoricalDevices, reflecting Iqbal\'s skill in engaging readers both intellectually and emotionally. $repetitionNote\n\n'
           '**Imagery and Symbolism**: The poem likely employs traditional Islamic and Persian literary symbols, connecting earthly experiences with spiritual realities in Iqbal\'s characteristic manner.';
  }
  
  static String _generateContemporaryRelevance(Map<String, bool> themes) {
    String relevanceAreas = themes['khudi'] == true ? 'personal empowerment and self-development' :
                           themes['freedom'] == true ? 'liberation movements and social justice' :
                           themes['knowledge'] == true ? 'educational reform and intellectual growth' :
                           'spiritual renewal and authentic identity';
    
    return 'This poem offers profound guidance for contemporary Muslims navigating the complexities of modern life while seeking authentic spiritual and cultural identity. '
           'Its emphasis on $relevanceAreas speaks directly to current challenges facing individuals and communities worldwide. '
           'The work provides practical wisdom for balancing traditional values with contemporary realities, offering a framework for meaningful engagement with modern society. '
           'Iqbal\'s vision of dynamic, progressive Islam remains highly relevant for addressing current debates about religion, modernity, and social change. '
           'The poem\'s call for awakened consciousness and purposeful action continues to inspire new generations seeking to make positive contributions to their communities and the world.';
  }
  
  static bool _detectRepetition(List<String> lines) {
    for (int i = 0; i < lines.length - 1; i++) {
      for (int j = i + 1; j < lines.length; j++) {
        if (lines[i].toLowerCase().contains(lines[j].toLowerCase().split(' ').first) ||
            lines[j].toLowerCase().contains(lines[i].toLowerCase().split(' ').first)) {
          return true;
        }
      }
    }
    return false;
  }

  static Future<List<Map<String, dynamic>>> getTimelineEvents(String bookName,
      [String? timePeriod]) async {
    if (!isConfigured) {
      throw Exception('Gemini API not configured');
    }

    try {
      debugPrint('📝 Requesting timeline from Gemini...');
      final response = await generateContent(
        prompt: _getTimelinePrompt(bookName, timePeriod),
        temperature: 0.3,
        maxTokens: 4000,
      );

      // Clean and parse JSON
      final cleanedJson = _safelyCleanJson(response);
      if (cleanedJson == null) {
        debugPrint('⚠️ Using default timeline due to cleaning failure');
        return _getDefaultTimelineEvents(bookName);
      }

      try {
        final List<dynamic> parsedEvents = jsonDecode(cleanedJson);
        return parsedEvents.map((e) => Map<String, dynamic>.from(e)).toList();
      } catch (e) {
        debugPrint('❌ JSON parsing error: $e');
        return _getDefaultTimelineEvents(bookName);
      }
    } catch (e) {
      debugPrint('❌ Timeline generation error: $e');
      return _getDefaultTimelineEvents(bookName);
    }
  }

  static String? _safelyCleanJson(String response) {
    try {
      // Extract JSON array
      final jsonStart = response.indexOf('[');
      final jsonEnd = response.lastIndexOf(']') + 1;

      if (jsonStart < 0 || jsonEnd <= jsonStart) {
        return null;
      }

      var extracted = response.substring(jsonStart, jsonEnd);

      // Basic cleanup
      extracted = extracted
          .replaceAll(
              RegExp(r'[\u2018\u2019\u201C\u201D]'), '"') // Smart quotes
          .replaceAll('"', '"')
          .replaceAll('"', '"')
          .replaceAll(''', "'")
          .replaceAll(''', "'")
          .replaceAll('–', '-')
          .replaceAll('…', '...');

      // Remove any remaining problematic characters
      extracted = extracted.replaceAll(RegExp(r'[^\x20-\x7E\s]'), '');

      // Validate JSON
      jsonDecode(extracted); // Test parse
      return extracted;
    } catch (e) {
      debugPrint('❌ JSON cleaning error: $e');
      return null;
    }
  }

  // Validate that the analysis contains all required sections
  static bool _isValidAnalysis(Map<String, String> analysis) {
    final requiredSections = ['summary', 'themes', 'context', 'analysis', 'relevance'];

    // Check if all required sections are present and not empty
    for (final section in requiredSections) {
      if (!analysis.containsKey(section) || analysis[section]!.isEmpty) {
        debugPrint('⚠️ Missing required section: $section');
        return false;
      }
    }

    return true;
  }

  static String _getTimelinePrompt(String bookName, [String? timePeriod]) {
    return '''Create a timeline of key historical events related to Allama Iqbal's "${bookName}" ${timePeriod != null ? 'during the $timePeriod period' : ''}.

Return ONLY a JSON array in this exact format, with no additional text or explanation:
[
  {
    "year": "YYYY", // Example: "1930" (or a range like "1930-1932")
    "title": "Short event title",
    "description": "Detailed description of the event (2-3 sentences)",
    "significance": "Why this event matters in context of the book (1-2 sentences)"
  },
  // Include 8-12 events in chronological order
]

INCLUDE ONLY the JSON array with no other text. Ensure the JSON is properly formatted with double quotes for all keys and string values.''';
  }

  static List<Map<String, dynamic>> _getDefaultTimelineEvents(String bookName) {
    return [
      {
        "year": "1905",
        "title": "Publication of Asrar-e-Khudi",
        "description":
            "Iqbal published his seminal work focusing on the concept of selfhood and self-realization. This Persian poem introduced his philosophical vision.",
        "significance":
            "Marked Iqbal's emergence as a major philosophical poet and established his core themes."
      },
      {
        "year": "1908",
        "title": "Iqbal's Return to India",
        "description":
            "After completing his education in Europe, Iqbal returned to India with new philosophical perspectives. His European experience deeply influenced his worldview.",
        "significance":
            "Began synthesis of Eastern and Western thought that would characterize his literary output."
      },
      {
        "year": "1915",
        "title": "Publication of Asrar-o-Rumuz",
        "description":
            "Released collection of Persian poetry exploring deeper mystical and philosophical concepts. This work expanded on ideas introduced in earlier writings.",
        "significance":
            "Solidified Iqbal's reputation as the philosophical poet of Islamic revival."
      },
      {
        "year": "1923",
        "title": "Political Awakening Period",
        "description":
            "Iqbal became more actively involved in politics and the Muslim cause in India. His poetry began reflecting greater political consciousness.",
        "significance":
            "Poetry from this period shows growing concern with the practical implications of his philosophy."
      },
      {
        "year": "1930",
        "title": "Allahabad Address",
        "description":
            "Delivered famous speech proposing the idea of a separate Muslim state in Northwest India. This address is considered a foundational document for Pakistan.",
        "significance":
            "Demonstrated how Iqbal's philosophical ideas translated into political vision."
      },
      {
        "year": "1938",
        "title": "Iqbal's Death",
        "description":
            "Allama Muhammad Iqbal passed away in Lahore on April 21, 1938. His literary legacy included poetry in Persian and Urdu that transformed Muslim intellectual thought.",
        "significance":
            "His works continued to inspire the Pakistan movement and Islamic revival worldwide."
      }
    ];
  }

  // Historical context analysis
  static Future<Map<String, dynamic>> getHistoricalContext(
      String title, String poemText) async {
    try {
      final prompt = '''
Analyze this poem by Allama Iqbal comprehensively:
TITLE: $title

TEXT:
$poemText

Provide a JSON response with EXACTLY these fields:
{
  "year": "When this poem was likely written (best estimate if exact date unknown)",
  "historicalContext": "Detailed historical background (3-4 sentences)",
  "significance": "Cultural and literary significance (3-4 sentences)",
  "culturalImportance": "How it relates to Muslim/South Asian culture (2-3 sentences)",
  "religiousThemes": "Religious aspects and Islamic philosophy references (2-3 sentences)",
  "politicalMessages": "Political themes or messages (2-3 sentences)",
  "factualInformation": "Any specific factual or historical references in the poem (2-3 sentences)",
  "imagery": "Key imagery used and its significance (2-3 examples)",
  "metaphor": "Major metaphors and their meaning (2-3 examples)",
  "symbolism": "Important symbols and their interpretations (2-3 examples)",
  "theme": "The overarching theme and message (2-3 sentences)"
}

Return ONLY the JSON with no other explanation.''';

      final response = await generateContent(
        prompt: prompt,
        temperature: 0.3,
        maxTokens: 4000,
      );

      try {
        // Try to extract JSON from the response
        String jsonStr = response.trim();

        // If response contains text before/after JSON
        int startPos = jsonStr.indexOf('{');
        int endPos = jsonStr.lastIndexOf('}') + 1;

        if (startPos >= 0 && endPos > startPos) {
          jsonStr = jsonStr.substring(startPos, endPos);
        }

        final data = jsonDecode(jsonStr);
        return data;
      } catch (e) {
        debugPrint('❌ Failed to parse historical context JSON: $e');
        debugPrint('Raw response: $response');

        // Return a structured fallback
        return {
          "year": "Unknown",
          "historicalContext":
              "Historical context could not be determined with confidence.",
          "significance":
              "This poem is part of Iqbal's body of work exploring themes of self-realization and Islamic revival.",
          "culturalImportance":
              "Iqbal's poetry is central to South Asian literary tradition and Islamic philosophical thought.",
          "religiousThemes":
              "Likely contains Iqbal's typical references to Islamic spirituality and philosophy.",
          "politicalMessages":
              "May reflect Iqbal's vision for Muslim revival and self-determination.",
          "factualInformation":
              "Analysis unavailable due to technical limitations.",
          "imagery": "Analysis unavailable.",
          "metaphor": "Analysis unavailable.",
          "symbolism": "Analysis unavailable.",
          "theme":
              "Likely explores one of Iqbal's central themes of selfhood, spiritual awakening, or Muslim identity."
        };
      }
    } catch (e) {
      debugPrint('❌ Historical context generation error: $e');
      return {
        "year": "Unavailable",
        "historicalContext": "Analysis unavailable due to technical error.",
        "significance": "Please try again later.",
        "culturalImportance": "",
        "religiousThemes": "",
        "politicalMessages": "",
        "factualInformation": "",
        "imagery": "",
        "metaphor": "",
        "symbolism": "",
        "theme": ""
      };
    }
  }
}
