import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/poem_controller.dart';
import '../../../features/poems/models/poem.dart';

import '../../../widgets/analysis/word_analysis_sheet.dart';
import '../widgets/poem_stanza_widget.dart';
import '../widgets/poem_notes_sheet.dart';

class PoemDetailView extends GetView<PoemController> {
  const PoemDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    late final Poem poem;
    final ScrollController scrollController = ScrollController();
    
    // Improved FAB state management
    final RxDouble fabX = (MediaQuery.of(context).size.width - 80.0).obs; // Default right position
    final RxDouble fabY = (MediaQuery.of(context).size.height * 0.6).obs; // Default middle-right position
    final RxBool isDragging = false.obs;
    final RxBool isLongPressing = false.obs;
    final RxBool showFab = true.obs; // Always show for all poems
    final RxDouble dragScale = 1.0.obs;

    // Load saved FAB position
    _loadFabPosition(fabX, fabY, context);

    try {
      if (args is Poem) {
        poem = args;
      } else if (args is Map<String, dynamic>) {
        poem = Poem.fromSearchResult(args);
      } else {
        return const Scaffold(
          body: Center(child: Text('Invalid poem data')),
        );
      }

      // Load notes for this poem so highlighting is available
      controller.loadPoemNotes(poem.id);

      return Scaffold(
        appBar: AppBar(
          title: Obx(() => Row(
                children: [
                  // Beautiful poetry icon with gradient
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.auto_stories,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poem.title,
                          style: TextStyle(
                            fontFamily: 'JameelNooriNastaleeq',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Replace "From:" with a better indicator
                        Row(
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              controller.currentBookName.value,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              position: PopupMenuPosition.under,
              onSelected: (value) {
                switch (value) {
                  case 'favorites':
                    controller.toggleFavorite(poem);
                    break;
                  case 'share':
                    controller.sharePoem(poem);
                    break;
                  case 'copy':
                    final textToCopy = '${poem.title}\n\n${poem.cleanData}';
                    Clipboard.setData(ClipboardData(text: textToCopy));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Poem copied to clipboard')),
                    );
                    break;
                  case 'analyze':
                    controller.showPoemAnalysis(poem.cleanData);
                    break;
                  case 'notes':
                    _showNotesSheet();
                    break;
                }
              },
              itemBuilder: (context) => [
                // Add favorite as first item
                PopupMenuItem<String>(
                  value: 'favorites',
                  child: Row(
                    children: [
                      Obx(() => Icon(
                            controller.isFavorite(poem)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                controller.isFavorite(poem) ? Colors.red : null,
                            size: 20,
                          )),
                      const SizedBox(width: 12),
                      Obx(() => Text(
                            controller.isFavorite(poem)
                                ? 'Remove from Favorites'
                                : 'Add to Favorites',
                            style: Theme.of(context).textTheme.bodyMedium,
                          )),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                _buildMenuItem(
                  'notes',
                  Icons.note_alt_outlined,
                  'Saved Notes',
                  context,
                ),
                _buildMenuItem(
                  'share',
                  Icons.share,
                  'Share Poem',
                  context,
                ),
                _buildMenuItem(
                  'copy',
                  Icons.copy,
                  'Copy Text',
                  context,
                ),
                const PopupMenuDivider(),
                // Analyze option
                PopupMenuItem<String>(
                  value: 'analyze',
                  child: Row(
                    children: [
                      Obx(() => controller.isAnalyzing.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.analytics, size: 20)),
                      const SizedBox(width: 12),
                      Text(
                        'Analyze Poem',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Font size controls in app bar
            PopupMenuButton<String>(
              icon: const Icon(Icons.text_fields),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              position: PopupMenuPosition.under,
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Column(
                    children: [
                      Text(
                        'Font Size',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MaterialButton(
                            minWidth: 0,
                            padding: const EdgeInsets.all(8),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            shape: const CircleBorder(),
                            onPressed: controller.decreaseFontSize,
                            child: const Icon(Icons.remove, size: 20),
                          ),
                          const SizedBox(width: 4),
                          Obx(() => Text(
                                '${controller.fontSize.value.toInt()}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              )),
                          const SizedBox(width: 4),
                          MaterialButton(
                            minWidth: 0,
                            padding: const EdgeInsets.all(8),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            shape: const CircleBorder(),
                            onPressed: controller.increaseFontSize,
                            child: const Icon(Icons.add, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            Obx(() => SingleChildScrollView(
                  controller: scrollController,
                  child: SafeArea(
                    child: _buildPoemContent(
                        context, poem), // now rebuilds on fontSize update
                  ),
                )),

            // Improved Draggable Add notes button - always visible and smooth
            Obx(() => Positioned(
              left: fabX.value,
              top: fabY.value,
              child: Transform.scale(
                scale: dragScale.value,
                child: AnimatedOpacity(
                  opacity: showFab.value ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: () {
                      if (!isDragging.value) {
                        HapticFeedback.lightImpact();
                      _showNotesSheet();
                      }
                    },
                    onLongPressStart: (details) {
                      isLongPressing.value = true;
                      dragScale.value = 1.05;
                      HapticFeedback.mediumImpact();
                    },
                    onLongPressEnd: (details) {
                      if (!isDragging.value) {
                        isLongPressing.value = false;
                        dragScale.value = 1.0;
                      }
                    },
                    onLongPressMoveUpdate: (details) {
                      if (isLongPressing.value && !isDragging.value) {
                        isDragging.value = true;
                        dragScale.value = 1.15;
                        HapticFeedback.heavyImpact();
                      }
                      
                      if (isDragging.value) {
                        final screenSize = MediaQuery.of(context).size;
                        final renderBox = context.findRenderObject() as RenderBox?;
                        if (renderBox != null) {
                          final localPosition = renderBox.globalToLocal(details.globalPosition);
                          final newX = (localPosition.dx - 28).clamp(0.0, screenSize.width - 56.0);
                          final newY = (localPosition.dy - 28).clamp(kToolbarHeight, screenSize.height - 56.0 - MediaQuery.of(context).padding.bottom);
                          
                          fabX.value = newX;
                          fabY.value = newY;
                        }
                      }
                    },
                    onLongPressUp: () {
                      if (isDragging.value) {
                        isDragging.value = false;
                        isLongPressing.value = false;
                        dragScale.value = 1.0;
                        _saveFabPosition(fabX.value, fabY.value);
                        HapticFeedback.lightImpact();
                        
                        // Snap to edges for better UX
                        _snapToNearestEdge(fabX, fabY, context);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDragging.value 
                            ? [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ]
                            : [
                                Theme.of(context).colorScheme.primary.withOpacity(0.85),
                                Theme.of(context).colorScheme.primary.withOpacity(0.75),
                              ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(isDragging.value ? 18 : 16),
                        border: isDragging.value ? Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          width: 1.5,
                        ) : null,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(
                              isDragging.value ? 0.4 : 0.25
                            ),
                            blurRadius: isDragging.value ? 16 : 8,
                            offset: Offset(0, isDragging.value ? 4 : 2),
                            spreadRadius: isDragging.value ? 2 : 0,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(isDragging.value ? 18 : 16),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedRotation(
                              turns: isDragging.value ? 0.05 : 0.0,
                              duration: const Duration(milliseconds: 150),
                              child: Icon(
                                Icons.edit_note_rounded,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: isDragging.value ? 26 : 24,
                              ),
                            ),
                            if (isDragging.value)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ),
                ),
              )),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error loading poem: $e');
      return const Scaffold(
        body: Center(child: Text('Error loading poem')),
      );
    }
  }

  Widget _buildPoemContent(BuildContext context, Poem poem) {
    final stanzas = _splitIntoStanzas(poem.cleanData);
    var lineNumber = 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title with animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              poem.title,
              style: TextStyle(
                fontFamily: 'JameelNooriNastaleeq',
                fontSize: controller.fontSize.value + 8,
                height: 2.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),

          const SizedBox(height: 32),

          // Analysis Results Section
          Obx(() {
            if (controller.showAnalysis.value) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Analysis Results',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              controller.showAnalysis.value = false,
                        ),
                      ],
                    ),
                    const Divider(),
                    SelectableText(
                      controller.poemAnalysis.value,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Stanzas with line numbers
          for (final stanza in stanzas)
            Builder(builder: (context) {
              final currentLineNumber = lineNumber;
              lineNumber += stanza.length;
              return PoemStanzaWidget(
                verses: stanza,
                startLineNumber: currentLineNumber,
                fontSize: controller.fontSize.value,
                onWordTap: (word) => _showWordAnalysis(context, word),
                poemId: poem.id,
              );
            }),
        ],
      ),
    );
  }

  void _showWordAnalysis(BuildContext context, String word) async {
    try {
      // Show feedback to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analyzing word: "$word"...'),
          duration: const Duration(seconds: 1),
        ),
      );

      // Show loading indicator
      Get.dialog(
        AlertDialog(
          title: Text('Analyzing "$word"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text('Looking up meaning and examples for "$word"'),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      debugPrint('🔍 Analyzing word: $word');

      // Use controller's analyzeWord method which uses Gemini/DeepSeek
      final analysis = await controller.analyzeWord(word);

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (context.mounted) {
        // Show a more reliable bottom sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          enableDrag: true,
          useSafeArea: true,
          isDismissible: true,
          builder: (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Analysis of "$word"',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                // Content
                Expanded(
                  child: WordAnalysisSheet(analysis: analysis),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      debugPrint('❌ Error analyzing word: $e');

      if (context.mounted) {
        Get.snackbar(
          'Error',
          'Failed to analyze word. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          colorText: Theme.of(context).colorScheme.onErrorContainer,
        );
      }
    }
  }

  List<List<String>> _splitIntoStanzas(String text) {
    return text
        .split('\n\n')
        .map((stanza) =>
            stanza.split('\n').where((line) => line.trim().isNotEmpty).toList())
        .where((stanza) => stanza.isNotEmpty)
        .toList();
  }

  String _formatPoemText(String text) {
    // Split into lines and clean up
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    // Join with proper spacing
    return lines.join('\n\n');
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String text,
    BuildContext context,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _getOverlayColor(bool isDark) {
    return (isDark ? Colors.black : Colors.white)
        .withAlpha((0.7 * 255).round());
  }

  // Export this function to be used by PoemDetailView
  static void showPoemNotesSheet(BuildContext context, Poem poem) {


    // Provide feedback to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loading notes for "${poem.title}"...'),
        duration: const Duration(seconds: 1),
      ),
    );

    // Provide haptic feedback
    HapticFeedback.mediumImpact();

    debugPrint(
        '📝 Opening notes sheet for poem: ${poem.id} - ${poem.title} via shared method');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notes for "${poem.title}"',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Content
            Expanded(
              child: PoemNotesSheet(
                poemId: poem.id,
                poemTitle: poem.title,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper methods for FAB position persistence
  Future<void> _loadFabPosition(RxDouble fabX, RxDouble fabY, BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedX = prefs.getDouble('fab_position_x');
      final savedY = prefs.getDouble('fab_position_y');
      
      if (savedX != null && savedY != null) {
        fabX.value = savedX;
        fabY.value = savedY;
      } else {
        // Set default position if not saved
        final screenSize = MediaQuery.of(context).size;
        fabX.value = (screenSize.width - 80.0);
        fabY.value = (screenSize.height * 0.6);
      }
    } catch (e) {
      debugPrint('Error loading FAB position: $e');
    }
  }
  
  Future<void> _saveFabPosition(double x, double y) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('fab_position_x', x);
      await prefs.setDouble('fab_position_y', y);
    } catch (e) {
      debugPrint('Error saving FAB position: $e');
    }
  }

  // Snap FAB to nearest edge for better UX (like iOS Control Center)
  void _snapToNearestEdge(RxDouble fabX, RxDouble fabY, BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final centerX = screenSize.width / 2;
    
    // Animate to left or right edge based on current position
    final targetX = fabX.value < centerX ? 16.0 : screenSize.width - 72.0;
    
    // Animate the movement
    Future.delayed(const Duration(milliseconds: 100), () {
      fabX.value = targetX;
      _saveFabPosition(fabX.value, fabY.value);
    });
  }

  void _showNotesSheet() {
    final poem = Get.arguments is Poem
        ? Get.arguments as Poem
        : Get.arguments is Map<String, dynamic>
            ? Poem.fromSearchResult(Get.arguments)
            : null;

    if (poem != null) {
      // Use the static method to show notes
      showPoemNotesSheet(Get.context!, poem);
    } else {
      Get.snackbar(
        'Error',
        'Could not load poem information',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class StanzaWidget extends StatelessWidget {
  final String stanza;
  final int stanzaNumber;
  final int totalStanzas;

  const StanzaWidget({
    super.key,
    required this.stanza,
    required this.stanzaNumber,
    required this.totalStanzas,
  });

  @override
  Widget build(BuildContext context) {
    final lines = stanza.split('\n');
    final startLineNumber = _calculateStartLineNumber();

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < lines.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Line number with better visibility in all themes
                  Container(
                    width: 32,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${startLineNumber + i}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Vertical line separator with better visibility
                  Container(
                    width: 1,
                    height: 24,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 16),
                  // Poem line
                  Expanded(
                    child: SelectableText(
                      lines[i],
                      style: TextStyle(
                        fontFamily: 'JameelNooriNastaleeq',
                        fontSize: 24,
                        height: 2.2,
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  int _calculateStartLineNumber() {
    if (stanzaNumber == 1) return 1;

    // Calculate based on previous stanzas
    int lineCount = 0;
    for (int i = 0; i < stanzaNumber - 1; i++) {
      lineCount += stanza.split('\n').length;
    }
    return lineCount + 1;
  }
}
