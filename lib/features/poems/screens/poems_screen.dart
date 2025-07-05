import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/poem_controller.dart';
import '../../../features/poems/models/poem.dart';
import '../../../services/api/gemini_api.dart';
import '../../historical_context/widgets/historical_context_sheet.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/themes/text_styles.dart';
import 'package:flutter/services.dart';
import '../../../core/themes/app_decorations.dart';

class PoemsScreen extends StatefulWidget {
  const PoemsScreen({super.key});

  @override
  State<PoemsScreen> createState() => _PoemsScreenState();
}

class _PoemsScreenState extends State<PoemsScreen> {
  final PoemController controller = Get.find<PoemController>();

  int? _bookId;
  String? _bookName;
  bool _isBookSpecific = false;

  @override
  void initState() {
    super.initState();
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
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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

  String _getTitle() {
    final args = Get.arguments as Map<String, dynamic>?;
    final viewType = args?['view_type'];
    final bookName = args?['book_name'];

    if (_isBookSpecific && _bookName != null) {
      return _bookName!;
    }
    return 'all_poems'.tr;
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

        return RefreshIndicator(
          onRefresh: () async {
            if (_isBookSpecific && _bookId != null) {
              await controller.loadPoemsByBookId(_bookId);
            } else {
              await controller.loadAllPoems();
            }
          },
          child: CustomScrollView(
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
    return GestureDetector(
        onTap: () => Get.find<PoemController>().onPoemTap(poem),
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showOptions(context);
        },
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, animationValue, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - animationValue)),
            child: Opacity(
              opacity: animationValue,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    ],
                  ),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Stack(
                    children: [
                      // Subtle pattern overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                Theme.of(context).colorScheme.primary.withOpacity(0.02),
                                Colors.transparent,
                                Theme.of(context).colorScheme.secondary.withOpacity(0.01),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Main content
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          children: [
                            // Enhanced poem icon
                            _buildEnhancedPoemIcon(context),
                            SizedBox(width: 20.w),
                            
                            // Poem details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Title with gradient effect
                                  _buildEnhancedTitle(context),
                                  SizedBox(height: 12.h),
                                  
                                  // Book info with icon
                                  _buildBookInfoChip(context),
                                  SizedBox(height: 8.h),
                                  
                                  // Poem excerpt or metadata
                                  _buildPoemExcerpt(context),
                                ],
                              ),
                            ),
                            SizedBox(width: 16.w),
                            
                            // Action arrow
                            _buildActionButton(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedPoemIcon(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.menu_book_rounded,
        color: Colors.white,
        size: 24.w,
      ),
    );
  }

  Widget _buildEnhancedTitle(BuildContext context) {
    final theme = Theme.of(context);
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          theme.colorScheme.onSurface,
          theme.colorScheme.onSurface.withOpacity(0.8),
        ],
      ).createShader(bounds),
      child: Text(
        poem.title,
        style: TextStyle(
          fontFamily: 'JameelNooriNastaleeq',
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.6,
          letterSpacing: 0,
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildBookInfoChip(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<String>(
      future: Get.find<PoemController>().getBookName(poem.bookId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildShimmerBookChip(context);
        }
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 14.w,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  snapshot.data!,
                  style: TextStyle(
                    fontFamily: 'JameelNooriNastaleeq',
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerBookChip(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 100.w,
      height: 24.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }

  Widget _buildPoemExcerpt(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      '',
      style: TextStyle(
        fontFamily: 'JameelNooriNastaleeq',
        fontSize: 14.sp,
        color: theme.colorScheme.onSurface.withOpacity(0.6),
        height: 1.4,
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16.w,
        color: theme.colorScheme.onSurfaceVariant,
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
        decoration: AppDecorations.bottomSheetDecoration(context),
        child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Poem info header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.auto_stories,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        poem.title,
                        style: TextStyle(
                          fontFamily: 'JameelNooriNastaleeq',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.4,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Options
              _buildOptionTile(
                context,
                Icons.history_edu_outlined,
                'Historical Context',
                'تاریخی پس منظر',
                'Explore the historical background',
                () {
                Navigator.pop(context);
                _showHistoricalContext(context);
              },
            ),
              Obx(() {
                final controller = Get.find<PoemController>();
                return _buildOptionTile(
                  context,
                  controller.isFavorite(poem)
                      ? Icons.favorite
                      : Icons.favorite_outline,
                  controller.isFavorite(poem)
                      ? 'Remove from Favorites'
                      : 'Add to Favorites',
                  controller.isFavorite(poem)
                      ? 'پسندیدگی سے ہٹائیں'
                      : 'پسندیدگی میں شامل کریں',
                  controller.isFavorite(poem)
                      ? 'Remove from your favorites'
                      : 'Save to your favorites',
                  () {
                    controller.toggleFavorite(poem);
                    Navigator.pop(context);
                  },
                  iconColor: controller.isFavorite(poem) ? Colors.red : null,
                );
              }),
              _buildOptionTile(
                context,
                Icons.share_outlined,
                'Share',
                'شیئر کریں',
                'Share this poem with others',
                () {
                Navigator.pop(context);
                  // Give the sheet time to close before opening share sheet
                  Future.delayed(const Duration(milliseconds: 200), () {
                    Get.find<PoemController>().sharePoem(poem);
                  });
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    IconData icon,
    String title,
    String urduTitle,
    String subtitle,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? Theme.of(context).colorScheme.primary)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    urduTitle,
                    style: TextStyle(
                      fontFamily: 'JameelNooriNastaleeq',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.3,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoricalContext(BuildContext context) {
    debugPrint('📖 Requesting historical context for: ${poem.title}');
    HistoricalContextSheet.show(context, poem);
  }
}
