import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/poem_controller.dart';
import 'note_dialog.dart';

import '../../../widgets/analysis/word_analysis_sheet.dart';
import 'dart:async'; // Added for Timer

class PoemStanzaWidget extends StatefulWidget {
  final List<String> verses;
  final int startLineNumber;
  final double fontSize;
  final Function(String) onWordTap;
  final int? poemId;
  final bool showLineNumbers;
  final bool isStanzaBreak;

  const PoemStanzaWidget({
    super.key,
    required this.verses,
    required this.startLineNumber,
    this.fontSize = 24,
    required this.onWordTap,
    this.poemId,
    this.showLineNumbers = false,
    this.isStanzaBreak = false,
  });

  @override
  State<PoemStanzaWidget> createState() => _PoemStanzaWidgetState();
}

class _PoemStanzaWidgetState extends State<PoemStanzaWidget> {
  String? temporaryHighlightWord;
  Timer? _highlightTimer;

  @override
  void dispose() {
    _highlightTimer?.cancel();
    super.dispose();
  }

  void _temporaryHighlightWord(String word) {
    setState(() {
      temporaryHighlightWord = word;
    });
    
    // Remove temporary highlight after 1.5 seconds
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          temporaryHighlightWord = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        vertical: widget.isStanzaBreak ? (isSmallScreen ? 24 : 32) : (isSmallScreen ? 8 : 12),
        horizontal: isSmallScreen ? 16 : 24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Stanza break indicator (subtle divider)
          if (widget.isStanzaBreak && widget.startLineNumber > 1)
            Container(
              width: screenWidth * 0.2,
              height: 1,
              margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    theme.colorScheme.outline.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          
          // Verses
          ...widget.verses.asMap().entries.map((entry) {
            final index = entry.key;
            final verse = entry.value.trim();
            
            if (verse.isEmpty) return const SizedBox.shrink();
            
            return _buildVerseLine(
              context, 
              verse, 
              widget.startLineNumber + index,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildVerseLine(
    BuildContext context,
    String verse,
    int lineNumber,
  ) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Optional line number (minimal style)
          if (widget.showLineNumbers)
            Padding(
              padding: EdgeInsets.only(bottom: isSmallScreen ? 4 : 6),
              child: Text(
                '$lineNumber',
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          
          // Verse text with center alignment
          _buildVerseText(context, verse, lineNumber),
        ],
      ),
    );
  }

  Widget _buildVerseText(
    BuildContext context,
    String verse,
    int lineNumber,
  ) {
    final theme = Theme.of(context);
    final words = verse.split(' ').where((word) => word.isNotEmpty).toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: screenWidth * 0.9, // Limit width for better readability
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: isSmallScreen ? 8 : 10,
            runSpacing: isSmallScreen ? 6 : 8,
            children: words.map((word) => _buildInteractiveWord(
              context,
              word,
              verse,
              lineNumber,
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveWord(
    BuildContext context,
    String word,
    String verse,
    int lineNumber,
  ) {
    final theme = Theme.of(context);
    final hasNote = _hasNoteForWord(word, verse, lineNumber);
    final isTemporaryHighlighted = temporaryHighlightWord == word;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    // Default styles
    Color? backgroundColor;
    Border? border;
    List<BoxShadow>? boxShadow;
    Color textColor = theme.colorScheme.onSurface;
    FontWeight fontWeight = FontWeight.w400;

    // Apply styles based on state, with temporary highlight taking precedence
    if (isTemporaryHighlighted) {
      // Most prominent style for temporary feedback
      backgroundColor = theme.colorScheme.primary.withOpacity(theme.brightness == Brightness.dark ? 0.25 : 0.2);
      border = Border.all(
        color: theme.colorScheme.primary.withOpacity(0.8),
        width: 2,
      );
      boxShadow = [
        BoxShadow(
          color: theme.colorScheme.primary.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
      textColor = theme.colorScheme.primary;
      fontWeight = FontWeight.w700;
    } else if (hasNote) {
      // Permanent style for words with notes
      backgroundColor = theme.colorScheme.primary.withOpacity(theme.brightness == Brightness.dark ? 0.15 : 0.08);
      border = Border(
        bottom: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.6),
          width: 2,
        ),
      );
      textColor = theme.colorScheme.primary;
      fontWeight = FontWeight.w600;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => _handleWordLongPress(context, word),
      onDoubleTap: () => _handleWordDoubleTap(context, word, verse, lineNumber),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 3 : 5,
          vertical: isSmallScreen ? 2 : 3,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: border,
          boxShadow: boxShadow,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Word text
            Text(
              word,
              style: TextStyle(
                fontFamily: 'JameelNooriNastaleeq',
                fontSize: isSmallScreen ? widget.fontSize : widget.fontSize * 1.1,
                height: 1.8,
                color: textColor,
                fontWeight: fontWeight,
                letterSpacing: 0.2,
                decoration: hasNote && !isTemporaryHighlighted ? TextDecoration.underline : TextDecoration.none,
                decorationColor: hasNote ? theme.colorScheme.primary : null,
                decorationThickness: hasNote ? 2 : null,
              ),
              textDirection: TextDirection.rtl,
            ),
            
            // Removed round dot indicators for a cleaner look
          ],
        ),
      ),
    );
  }

  // Word interaction handlers
  void _handleWordLongPress(BuildContext context, String word) async {
    debugPrint('🔍 Long press detected on word: $word - showing AI analysis');
    HapticFeedback.mediumImpact();
    
    try {
      final controller = Get.find<PoemController>();
      
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text('Analyzing "$word"...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      
      final analysis = await controller.analyzeWord(word);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: true,
          useSafeArea: true,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (_, scrollController) => WordAnalysisSheet(
              analysis: analysis,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to analyze word: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _handleWordDoubleTap(
    BuildContext context,
    String word,
    String verse,
    int lineNumber,
  ) {
    debugPrint('📝 Double tap detected on word: $word - opening note editor');
    HapticFeedback.lightImpact();
    
    // Show temporary highlight for feedback
    _temporaryHighlightWord(word);
    
    if (widget.poemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot add note: Poem ID not available'),
        ),
      );
      return;
    }
    
    // Brief feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening note editor for "$word"...'),
        duration: const Duration(milliseconds: 600),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
    
    Future.delayed(const Duration(milliseconds: 100), () {
      showDialog(
        context: context,
        builder: (context) => NoteDialog(
          poemId: widget.poemId!,
          word: word,
          position: _calculateWordPosition(word, verse, lineNumber),
          verse: verse,
        ),
      ).then((_) {
        // Refresh the widget to show updated note status
        if (mounted) {
          setState(() {
            // This will trigger a rebuild to show/hide permanent highlighting
            // based on whether the note was saved or deleted
          });
        }
      });
    });
  }

  // Helper methods
  bool _hasNoteForWord(String word, String verse, int lineNumber) {
    try {
      final controller = Get.find<PoemController>();
      return controller.hasNoteForWord(
        word, 
        _calculateWordPosition(word, verse, lineNumber),
      );
    } catch (e) {
      return false;
    }
  }

  int _calculateWordPosition(String word, String verse, int lineNumber) {
    // Create a unique position based on word, verse, and line number
    return (verse.hashCode + lineNumber + word.hashCode).abs();
  }
}
