import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/Get.dart';
import '../controllers/poem_controller.dart';
import '../../../features/poems/models/poem.dart';

import '../../historical_context/widgets/historical_context_sheet.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/themes/text_styles.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

class PoemsScreen extends StatefulWidget {
  const PoemsScreen({super.key});

  @override
  State<PoemsScreen> createState() => _PoemsScreenState();
}

class _PoemsScreenState extends State<PoemsScreen> {
  final PoemController controller = Get.find<PoemController>();
  late ScrollController _scrollController;
  bool _isFabVisible = true;

  int? _bookId;
  String? _bookName;
  bool _isBookSpecific = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null && args['book_id'] != null && args['view_type'] == 'book_specific') {
      _bookId = args['book_id'] as int?;
      _bookName = args['book_name'] as String?;
      _isBookSpecific = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isBookSpecific && _bookId != null) {
        debugPrint('📚 Loading poems for book: $_bookId');
        controller.loadPoemsByBookId(_bookId);
      } else {
        debugPrint('📚 Loading all poems (direct access)');
        controller.loadAllPoems();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    final args = Get.arguments as Map<String, dynamic>?;
    final bookId = args?['book_id'];
    debugPrint('Error widget args: $args');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'خرابی ہوئی',
              style: TextStyle(
                fontFamily: 'JameelNooriNastaleeq',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.4,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          Text(
            error,
              style: TextStyle(
                fontFamily: 'JameelNooriNastaleeq',
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
              textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
            const SizedBox(height: 24),
          if (bookId != null)
              ElevatedButton(
              onPressed: () => controller.loadPoemsByBookId(bookId),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'دوبارہ کوشش کریں',
                  style: TextStyle(
                    fontFamily: 'JameelNooriNastaleeq',
                    fontSize: 16,
                    height: 1.2,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.auto_stories_outlined,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ابھی کوئی شعر دستیاب نہیں',
              style: TextStyle(
                fontFamily: 'JameelNooriNastaleeq',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.4,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'اشعار کا ذخیرہ جلد ہی اپ ڈیٹ ہوگا',
              style: TextStyle(
                fontFamily: 'JameelNooriNastaleeq',
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildRandomPoemFab(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isFabVisible ? 1.0 : 0.0,
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h, right: 4.w), // Extra margin to avoid text overlap
          child: FloatingActionButton(
            onPressed: () async {
              HapticFeedback.lightImpact();
              try {
                await controller.openRandomPoem();
              } catch (e) {
                debugPrint('❌ Error opening random poem: $e');
              }
            },
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            foregroundColor: Colors.white,
            elevation: 6,
            tooltip: 'Random Poem',
            child: const Icon(Icons.shuffle_rounded, size: 24),
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final bool isStandalone = _isBookSpecific;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: isStandalone
          ? CustomAppBar(
              title: '',
              centerTitle: true,
              flexibleSpace: Obx(() {
                final count = controller.poems.length;
                final name = _bookName ?? 'نظم';
                return Padding(
                  padding: const EdgeInsets.only(top: kToolbarHeight - 20),
                  child: Center(
                    child: Text(
                      "$name ($count)",
                      style: AppTextStyles.getTitleStyle(
                        context,
                        isUrdu: _bookName?.contains(RegExp(r'[\u0600-\u06FF]')) ?? false,
                        isLarge: true,
                      ),
                    ),
                  ),
                );
              }),
            )
          : null,
      floatingActionButton: !_isBookSpecific ? _buildRandomPoemFab(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return _buildErrorWidget(context, controller.error.value);
        }

        if (controller.poems.isEmpty) {
          return _buildEmptyState(context);
        }

        return NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            final ScrollDirection direction = notification.direction;
            setState(() {
              if (direction == ScrollDirection.reverse) {
                _isFabVisible = false;
              } else {
                _isFabVisible = true;
              }
            });
            return false;
          },
          child: RefreshIndicator(
          onRefresh: () async {
            if (_isBookSpecific && _bookId != null) {
              await controller.loadPoemsByBookId(_bookId);
            } else {
              await controller.loadAllPoems();
            }
          },
          child: CustomScrollView(
              controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Poems list
              SliverPadding(
                padding: EdgeInsets.zero,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
            final poem = controller.poems[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == controller.poems.length - 1 ? 60 : 8,
                        ),
                        child: PoemCard(poem: poem),
                      );
          },
                    childCount: controller.poems.length,
                  ),
                ),
              ),
            ],
            ),
          ),
        );
      }),
    );
  }
}

class PoemCard extends StatelessWidget {
  final Poem poem;

  const PoemCard({
    super.key,
    required this.poem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUrdu = poem.title.contains(RegExp(r'[\u0600-\u06FF]'));

    return GestureDetector(
      onTap: () => Get.find<PoemController>().onPoemTap(poem),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showOptions(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Simple poem icon
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.article_outlined,
                color: theme.colorScheme.secondary,
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            
            // Poem details
            Expanded(
              child: Column(
                crossAxisAlignment: isUrdu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    poem.title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      fontFamily: isUrdu ? 'JameelNooriNastaleeq' : null,
                      height: isUrdu ? 1.8 : 1.4,
                    ),
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  
                  // Book info
                  Row(
                    mainAxisAlignment: isUrdu ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 14.w,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: FutureBuilder<String>(
                          future: Get.find<PoemController>().getBookName(poem.bookId),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Loading...',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                      // Year (if available)
                      if (poem.year != null) ...[
                        SizedBox(width: 8.w),
                        Text(
                          '• ${poem.year}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Simple arrow
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    debugPrint('Showing options for poem: ${poem.title}');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
      ),
        child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              // Modern handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 24.h),
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              
              // Poem info header with modern design
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52.w,
                      height: 52.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                        size: 26.w,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                        poem.title,
                        style: TextStyle(
                          fontFamily: 'JameelNooriNastaleeq',
                              fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.4,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          FutureBuilder<String>(
                            future: Get.find<PoemController>().getBookName(poem.bookId),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? '',
                                style: TextStyle(
                                  fontFamily: 'JameelNooriNastaleeq',
                                  fontSize: 14.sp,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  height: 1.3,
                                ),
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Modern option tiles
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    _buildModernOptionTile(
                context,
                      icon: Icons.timeline_rounded,
                      urduTitle: 'تاریخی پس منظر',
                      englishTitle: 'Historical Context',
                      urduSubtitle: 'اس نظم کا تاریخی پس منظر دیکھیں',
                      englishSubtitle: 'Explore the historical background',
                      onTap: () {
                Navigator.pop(context);
                _showHistoricalContext(context);
              },
            ),
                    
                    SizedBox(height: 8.h),
                    
              Obx(() {
                final controller = Get.find<PoemController>();
                      final isFavorite = controller.isFavorite(poem);
                      return _buildModernOptionTile(
                  context,
                        icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                        urduTitle: isFavorite ? 'پسندیدگی سے ہٹائیں' : 'پسندیدہ میں شامل کریں',
                        englishTitle: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                        urduSubtitle: isFavorite ? 'اپنی پسندیدگی سے نظم ہٹائیں' : 'اپنی پسندیدگی میں محفوظ کریں',
                        englishSubtitle: isFavorite ? 'Remove from your favorites' : 'Save to your favorites',
                        iconColor: isFavorite ? Colors.red : null,
                        onTap: () {
                    controller.toggleFavorite(poem);
                    Navigator.pop(context);
                  },
                );
              }),
                    
                    SizedBox(height: 8.h),
                    
                    _buildModernOptionTile(
                context,
                      icon: Icons.share_rounded,
                      urduTitle: 'شیئر کریں',
                      englishTitle: 'Share Poem',
                      urduSubtitle: 'دوسروں کے ساتھ اس نظم کو شیئر کریں',
                      englishSubtitle: 'Share this poem with others',
                      onTap: () {
                Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    Get.find<PoemController>().sharePoem(poem);
                  });
                },
              ),
                  ],
                ),
              ),
              
              SizedBox(height: MediaQuery.of(context).padding.bottom + 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernOptionTile(
    BuildContext context, {
    required IconData icon,
    required String urduTitle,
    required String englishTitle,
    required String urduSubtitle,
    required String englishSubtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 22.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      englishTitle,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      urduSubtitle,
                      style: TextStyle(
                        fontFamily: 'JameelNooriNastaleeq',
                        fontSize: 13.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                        height: 1.4,
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.w,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _showHistoricalContext(BuildContext context) {
    debugPrint('📖 Requesting historical context for: ${poem.title}');
    HistoricalContextSheet.show(context, poem);
  }
}
