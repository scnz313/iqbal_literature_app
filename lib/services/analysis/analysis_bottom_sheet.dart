import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/themes/app_decorations.dart';
import '../../core/themes/text_styles.dart';
import 'dart:math';

// Add this class at the top, outside of any other class
// Helper class for content sections
class ContentSection {
  final String title;
  final String content;

  ContentSection({required this.title, required this.content});
}

class AnalysisBottomSheet extends StatefulWidget {
  final String poemTitle;
  final Future<String> analysisData;

  const AnalysisBottomSheet({
    super.key,
    required this.poemTitle,
    required this.analysisData,
  });

  static Future<void> show(
      BuildContext context, String poemTitle, Future<String> analysisData) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.05),
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => AnalysisBottomSheet(
        poemTitle: poemTitle,
        analysisData: analysisData,
      ),
    );
  }

  @override
  State<AnalysisBottomSheet> createState() => _AnalysisBottomSheetState();
}

class _AnalysisBottomSheetState extends State<AnalysisBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: AppDecorations.bottomSheetDecoration(context),
            child: SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    
                    // Header
                    _buildHeader(context),
                    
                    // Content
                    Expanded(
                      child: FutureBuilder<String>(
                        future: widget.analysisData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return _buildLoadingState();
                          }
                          if (snapshot.hasError) {
                            return _buildErrorState(snapshot.error!);
                          }
                          return _buildContent(snapshot.data!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isUrdu = widget.poemTitle.contains(RegExp(r'[\u0600-\u06FF]'));
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: AppDecorations.iconContainerDecoration(
              context,
              theme.colorScheme.primary,
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 24.w,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: isUrdu 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis',
                  style: AppTextStyles.getTitleStyle(context).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.poemTitle,
                  style: AppTextStyles.getBodyStyle(context).copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: isUrdu ? 'JameelNooriNastaleeq' : null,
                    fontSize: isUrdu ? 14.sp : 12.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              padding: EdgeInsets.all(8.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: child,
            ),
            child: Column(
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: AppDecorations.iconContainerDecoration(
                    context,
                    Theme.of(context).colorScheme.primary,
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    size: 40.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Analyzing poem',
                      style: AppTextStyles.getTitleStyle(context).copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _buildLoadingDots(),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          ..._buildLoadingSteps(),
        ],
      ),
    );
  }

  List<Widget> _buildLoadingSteps() {
    final steps = [
      'Analyzing poem structure',
      'Extracting themes',
      'Identifying metaphors',
      'Generating insights',
      'Finalizing analysis',
    ];
    
    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      return TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 800 + (index * 200)),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: child,
          ),
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: AppDecorations.cardDecoration(context),
          child: Row(
            children: [
              Icon(
                Icons.arrow_right,
                size: 20.w,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                step,
                style: AppTextStyles.getBodyStyle(context),
              ),
              if (index == steps.length - 1) ...[
                SizedBox(width: 8.w),
                Text(
                  'fin.',
                  style: AppTextStyles.getBodyStyle(context).copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLoadingDots() {
    return SizedBox(
      width: 24.w,
      child: TweenAnimationBuilder<int>(
        duration: const Duration(milliseconds: 1500),
        tween: IntTween(begin: 0, end: 3),
        builder: (context, value, child) {
          return Text(
            '.' * value,
            style: AppTextStyles.getTitleStyle(context).copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: AppDecorations.iconContainerDecoration(
              context,
              Theme.of(context).colorScheme.error,
            ),
            child: Icon(
              Icons.error_outline,
              size: 40.w,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Analysis Failed',
            style: AppTextStyles.getTitleStyle(context).copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error.toString(),
            style: AppTextStyles.getBodyStyle(context),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry Analysis'),
            style: AppDecorations.elevatedButtonStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String content) {
    debugPrint('🧩 Displaying analysis content: ${content.substring(0, min(content.length, 100))}...');

    // First check if content has markdown headers
    final bool hasMarkdownHeaders = content.contains('#');

    if (hasMarkdownHeaders) {
      // If it contains markdown headers, use Flutter Markdown
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Markdown(
          data: content,
          physics: const BouncingScrollPhysics(),
          styleSheet: MarkdownStyleSheet(
            h1: AppTextStyles.getTitleStyle(context).copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            h2: AppTextStyles.getTitleStyle(context).copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18.sp,
            ),
            p: AppTextStyles.getBodyStyle(context),
          ),
        ),
      );
    } else {
      // Otherwise, parse our own custom format (Section: content)
      final sections = _parseContentSections(content);

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        physics: const BouncingScrollPhysics(),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: AppDecorations.cardDecoration(context),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              childrenPadding: EdgeInsets.all(16.w),
              leading: Container(
                padding: EdgeInsets.all(8.w),
                decoration: AppDecorations.iconContainerDecoration(
                  context,
                  Theme.of(context).colorScheme.primary,
                ),
                child: Icon(
                  _getSectionIcon(section.title),
                  color: Theme.of(context).colorScheme.primary,
                  size: 20.w,
                ),
              ),
              title: Text(
                _formatSectionTitle(section.title),
                style: AppTextStyles.getTitleStyle(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                Text(
                  section.content,
                  style: AppTextStyles.getBodyStyle(context).copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  // Helper method to get an appropriate icon for each section
  IconData _getSectionIcon(String title) {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('summary')) {
      return Icons.subject;
    } else if (lowerTitle.contains('theme')) {
      return Icons.lightbulb_outline;
    } else if (lowerTitle.contains('context') ||
        lowerTitle.contains('historical')) {
      return Icons.history_edu;
    } else if (lowerTitle.contains('analysis') ||
        lowerTitle.contains('literary')) {
      return Icons.analytics_outlined;
    } else {
      return Icons.article;
    }
  }

  // Helper method to format section title for display
  String _formatSectionTitle(String title) {
    // Remove the colon from the end
    String formatted =
        title.endsWith(':') ? title.substring(0, title.length - 1) : title;

    // Capitalize the first letter of each word
    formatted = formatted.split(' ').map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return word;
    }).join(' ');

    return formatted;
  }

  List<ContentSection> _parseContentSections(String content) {
    final List<ContentSection> sections = [];
    final lines = content.split('\n');

    String currentTitle = '';
    StringBuffer currentContent = StringBuffer();

    // Check if it's a simple string with no sections
    bool hasSections = false;
    for (final line in lines) {
      if (line.endsWith(':') && line.length < 50) {
        hasSections = true;
        break;
      }
    }

    // If no sections found, treat the whole thing as one analysis section
    if (!hasSections) {
      return [ContentSection(title: 'Analysis:', content: content)];
    }

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // If line is empty and we're at the end, add current section
      if (line.isEmpty && i == lines.length - 1 && currentTitle.isNotEmpty) {
        sections.add(ContentSection(
          title: currentTitle,
          content: currentContent.toString().trim(),
        ));
        continue;
      }

      // Skip empty lines at the beginning
      if (line.isEmpty && currentTitle.isEmpty) {
        continue;
      }

      // Check if this line is a section title (ends with colon)
      // Make sure it's not too long to be a title
      if (line.endsWith(':') &&
          line.length < 50 &&
          (currentTitle.isEmpty ||
              currentContent.toString().trim().isNotEmpty)) {
        // Save previous section if we have one
        if (currentTitle.isNotEmpty) {
          sections.add(ContentSection(
            title: currentTitle,
            content: currentContent.toString().trim(),
          ));
        }

        // Start new section
        currentTitle = line;
        currentContent = StringBuffer();
      } else {
        // Add to current section content
        if (currentTitle.isNotEmpty) {
          if (currentContent.isNotEmpty) {
            currentContent.writeln();
          }
          currentContent.write(line);
        }
      }
    }

    // Add the last section if we have one
    if (currentTitle.isNotEmpty) {
      sections.add(ContentSection(
        title: currentTitle,
        content: currentContent.toString().trim(),
      ));
    }

    return sections;
  }
}
