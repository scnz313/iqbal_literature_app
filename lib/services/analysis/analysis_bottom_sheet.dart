import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../api/gemini_api.dart';
import '../api/openrouter_service.dart';
import '../../core/widgets/scaled_text.dart';

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
      barrierColor: Colors.black.withOpacity(0.4),
      isScrollControlled: true,
      useRootNavigator: true,
      enableDrag: true,
      isDismissible: true,
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
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _slideController;
  
  // State management
  final ScrollController _scrollController = ScrollController();
  final RxBool showScrollToTop = false.obs;
  final RxBool isTranslating = false.obs;
  final RxBool showingTranslation = false.obs;
  
  // Data
  String originalContent = '';
  String translatedContent = '';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupListeners();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
  }

  void _setupListeners() {
    _scrollController.addListener(() {
      showScrollToTop.value = _scrollController.offset > 250;
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutQuart,
      )),
      child: FadeTransition(
        opacity: _slideController,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withOpacity(0.85),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.9,
                child: Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: FutureBuilder<String>(
                        future: widget.analysisData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return _buildLoadingState(context);
                          }
                          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                            return _buildErrorState(context, snapshot.error);
                          }
                          originalContent = _formatAnalysisContent(snapshot.data!);
                          return _buildContent(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaledText(
                      'AI-Powered Analysis',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    ScaledText(
                      'Poem Analysis',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded, size: 24.w),
                color: theme.colorScheme.onSurfaceVariant,
                splashRadius: 20.r,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (originalContent.isEmpty) {
      return _buildEmptyState(context);
    }

    final theme = Theme.of(context);
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 40.h),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: theme.colorScheme.onSurface.withOpacity(0.04),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: theme.colorScheme.primary,
                        size: 20.w,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ScaledText(
                          'Comprehensive Analysis',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      // Translate button
                      Obx(() => IconButton(
                        icon: isTranslating.value
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                Icons.translate_rounded,
                                size: 18.w,
                                color: showingTranslation.value
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                        onPressed: isTranslating.value ? null : _handleTranslate,
                        splashRadius: 18.r,
                      )),
                      // Copy button
                      IconButton(
                        icon: Icon(Icons.copy_rounded, size: 18.w),
                        onPressed: _copyToClipboard,
                        color: theme.colorScheme.onSurfaceVariant,
                        splashRadius: 18.r,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Obx(() {
                    final raw = showingTranslation.value && translatedContent.isNotEmpty
                        ? translatedContent
                        : originalContent;
                    final lines = raw.split('\n');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: lines.map((line) {
                        final isHeader = line.trim().endsWith(':');
                        final isBullet = RegExp(r'^\s*[•\-]').hasMatch(line);
                        final isUrdu = _containsUrdu(line);

                        // Base text style
                        final textStyle = TextStyle(
                          fontSize: isHeader ? 15.sp : 13.sp,
                          fontWeight: isHeader ? FontWeight.w700 : FontWeight.normal,
                          height: 1.55,
                          color: isHeader
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.9),
                          fontFamily: isUrdu ? 'JameelNooriNastaleeq' : null,
                        );

                        // Build the text widget with directionality
                        final textWidget = Directionality(
                          textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                          child: ScaledText(
                            line.trim(),
                            style: textStyle,
                            textAlign: isUrdu ? TextAlign.right : TextAlign.left,
                          ),
                        );

                        return Padding(
                          padding: EdgeInsets.only(
                            left: (!isUrdu && isBullet) ? 8.w : 0,
                            right: (isUrdu && isBullet) ? 8.w : 0,
                            top: isHeader ? 12.h : 0,
                            bottom: 4.h,
                          ),
                          child: textWidget,
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        Obx(() => showScrollToTop.value
            ? Positioned(
                bottom: 24.h,
                right: 24.w,
                child: _buildScrollToTopButton(context),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildScrollToTopButton(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton.small(
      onPressed: () {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      },
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      child: const Icon(Icons.keyboard_arrow_up_rounded),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40.w,
            height: 40.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          SizedBox(height: 24.h),
          ScaledText(
            'Analyzing poem...',
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object? error) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 50.w,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: 16.h),
            ScaledText(
              'Connection Issue',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            ScaledText(
              'Unable to connect to analysis service. Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.refresh_rounded, size: 18.w),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 50.w,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            ScaledText(
              'No Analysis Available',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            ScaledText(
              'The analysis could not be loaded.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAnalysisContent(String rawContent) {
    if (rawContent.isEmpty) return '';

    // 1. Normalise new-lines
    String txt = rawContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // 2. Strip triple back-tick code fences (```)
    txt = txt.replaceAll(RegExp(r'```[a-zA-Z]*'), '').replaceAll('```', '');

    // 3. Remove markdown block-quote markers and leading hashes
    txt = txt.replaceAll(RegExp(r'^[>#]+\s*', multiLine: true), '');

    // 4. Convert bold section headers (**HEADER:**) into their own line
    txt = txt.replaceAllMapped(
      RegExp(r'\*\*([^*]+?):\*\*'),
      (m) => '\n${m.group(1)!.trim()}:\n',
    );

    // 5. Remove any remaining inline bold/italic markers (**text**, *text*)
    txt = txt.replaceAll('**', '').replaceAll('*', '');

    // 6. Standardise bullet points ("- " or "* " at line start → "• ")
    txt = txt.replaceAll(RegExp(r'^\s*[\-*]\s+', multiLine: true), '• ');

    // 7. Collapse multiple spaces / tabs
    txt = txt.replaceAll(RegExp(r'[ \t]{2,}'), ' ');

    // 8. Collapse 3+ consecutive new-lines into 2
    txt = txt.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return txt.trim();
  }

  Future<void> _handleTranslate() async {
    if (showingTranslation.value) {
      showingTranslation.value = false;
      return;
    }

    if (translatedContent.isNotEmpty) {
      showingTranslation.value = true;
      return;
    }

    isTranslating.value = true;

    try {
      final targetIsUrdu = !_containsUrdu(originalContent);
      translatedContent = await _translateText(originalContent, targetIsUrdu);
      showingTranslation.value = true;
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Translation Failed',
          'Unable to translate the analysis. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.errorContainer,
          colorText: Get.theme.colorScheme.onErrorContainer,
          margin: EdgeInsets.all(12.w),
          borderRadius: 12.r,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      isTranslating.value = false;
    }
  }

  bool _containsUrdu(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  Future<String> _translateText(String text, bool toUrdu) async {
    final targetLang = toUrdu ? 'Urdu' : 'English';
    final prompt = 'Translate the following literary analysis to $targetLang. If the text is already in $targetLang simply return it unchanged. When translating to Urdu, avoid English loanwords where a standard Urdu equivalent exists, use formal literary Urdu, and keep bullet points & section headings intact. Provide only translated text:\n\n$text';

    try {
      if (GeminiAPI.isConfigured) {
        return await GeminiAPI.generateContent(
          prompt: prompt,
          temperature: 0.3,
          maxTokens: 8000,
        );
      }
      return await OpenRouterService.getCompletion(prompt);
    } catch (e) {
      rethrow;
    }
  }

  void _copyToClipboard() {
    final contentToCopy = showingTranslation.value && translatedContent.isNotEmpty
        ? translatedContent
        : originalContent;
    
    Clipboard.setData(ClipboardData(text: contentToCopy));
    HapticFeedback.lightImpact();
    
    Get.snackbar(
      'Copied to Clipboard',
      'The analysis has been copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.inverseSurface,
      colorText: Get.theme.colorScheme.onInverseSurface,
      margin: EdgeInsets.all(12.w),
      borderRadius: 12.r,
      duration: const Duration(seconds: 2),
    );
  }
}

