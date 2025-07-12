import 'package:flutter/material.dart';
import '../../../services/analysis/text_analysis_service.dart';
import '../../../widgets/analysis/word_analysis_sheet.dart';
import '../../poems/widgets/poem_stanza_widget.dart';
import 'package:get/get.dart';
import '../controllers/poem_controller.dart';

class PoemText extends StatelessWidget {
  final String text;
  final String languageCode;
  final TextAnalysisService analysisService;
  final double fontSize;
  final int? poemId;
  final bool showLineNumbers;

  const PoemText({
    super.key,
    required this.text,
    required this.languageCode,
    required this.analysisService,
    this.fontSize = 24,
    this.poemId,
    this.showLineNumbers = false,
  });

  void _showWordAnalysis(BuildContext context, String word) async {
    try {
      final controller = Get.find<PoemController>();
      final analysis = await controller.analyzeWord(word);
      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          enableDrag: true,
          useSafeArea: true,
          isDismissible: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.6,
            maxChildSize: 0.95,
            builder: (_, scrollController) =>
                WordAnalysisSheet(analysis: analysis),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Get.snackbar(
          'Error',
          'Failed to analyze word: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stanzas = _parseIntoStanzas(text);
    var lineNumber = 1;
    final List<Widget> stanzaWidgets = [];

    for (int i = 0; i < stanzas.length; i++) {
      stanzaWidgets.add(
        PoemStanzaWidget(
          verses: stanzas[i],
          startLineNumber: lineNumber,
          fontSize: fontSize,
          onWordTap: (word) => _showWordAnalysis(context, word),
          poemId: poemId,
          showLineNumbers: showLineNumbers,
          isStanzaBreak: i > 0, // First stanza has no break, others do
        ),
      );
      
      // Update line number for next stanza
      lineNumber += stanzas[i].length;
    }

    return Column(
      children: stanzaWidgets,
    );
  }

  /// Parse the poem text into semantic stanzas
  /// This groups verses into meaningful units based on empty lines and patterns
  List<List<String>> _parseIntoStanzas(String text) {
    final lines = text.split('\n');
    final List<List<String>> stanzas = [];
    List<String> currentStanza = [];

    for (final line in lines) {
      final trimmedLine = line.trim();
      
      if (trimmedLine.isEmpty) {
        // Empty line indicates stanza break
        if (currentStanza.isNotEmpty) {
          stanzas.add(List.from(currentStanza));
          currentStanza.clear();
        }
      } else {
        currentStanza.add(trimmedLine);
      }
    }

    // Add the last stanza if it exists
    if (currentStanza.isNotEmpty) {
      stanzas.add(currentStanza);
    }

    // If we have no explicit stanzas (no empty lines), create semantic ones
    if (stanzas.length == 1 && stanzas[0].length > 4) {
      return _createSemanticStanzas(stanzas[0]);
    }

    return stanzas.isEmpty ? [[]] : stanzas;
  }

  /// Create semantic stanzas for poems without explicit breaks
  /// This groups lines into couplets (2 lines) or quatrains (4 lines) based on common poetry patterns
  List<List<String>> _createSemanticStanzas(List<String> allLines) {
    final List<List<String>> stanzas = [];
    
    // For Urdu poetry, typically organize into couplets (Sher)
    // Each couplet is usually 2 lines that form a complete thought
    final bool isUrdu = languageCode == 'ur' || allLines.any((line) => 
      line.contains(RegExp(r'[\u0600-\u06FF]')));
    
    if (isUrdu) {
      // Group into couplets (2 lines each)
      for (int i = 0; i < allLines.length; i += 2) {
        final couplet = <String>[];
        couplet.add(allLines[i]);
        if (i + 1 < allLines.length) {
          couplet.add(allLines[i + 1]);
        }
        stanzas.add(couplet);
      }
    } else {
      // For other languages, group into quatrains (4 lines) or smaller groups
      final groupSize = allLines.length > 8 ? 4 : 2;
      for (int i = 0; i < allLines.length; i += groupSize) {
        final group = <String>[];
        for (int j = i; j < i + groupSize && j < allLines.length; j++) {
          group.add(allLines[j]);
        }
        stanzas.add(group);
      }
    }
    
    return stanzas;
  }
}
