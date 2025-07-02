import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
// Update import path
import '../../historical_context/widgets/historical_context_sheet.dart';
import '../../../features/poems/models/poem.dart';
import '../controllers/poem_controller.dart';
import '../../../core/themes/app_decorations.dart';
import '../../../core/themes/text_styles.dart';

class PoemCard extends StatefulWidget {
  final String title;
  final Poem poem;
  final bool isCompact;

  const PoemCard({
    super.key,
    required this.title,
    required this.poem,
    this.isCompact = false,
  });

  @override
  State<PoemCard> createState() => _PoemCardState();
}

class _PoemCardState extends State<PoemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDecorations.fastAnimation,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUrdu = widget.title.contains(RegExp(r'[\u0600-\u06FF]'));

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) => _onTapDown(),
          onTapUp: (_) => _onTapUp(),
          onTapCancel: () => _onTapUp(),
          onLongPressStart: (_) => _onTapDown(),
          onLongPressEnd: (_) => _onTapUp(),
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showOptions(context);
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 600;
              
              return AnimatedContainer(
                duration: AppDecorations.fastAnimation,
                curve: Curves.easeInOutCubic,
                transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
                margin: widget.isCompact 
                    ? AppDecorations.compactCardMargin.copyWith(top:3.h,bottom:3.h) 
                    : (isWideScreen 
                        ? AppDecorations.largeCardMargin.copyWith(top:6.h,bottom:6.h) 
                        : AppDecorations.defaultCardMargin.copyWith(top:6.h,bottom:6.h)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: _isPressed ? null : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    ],
                  ),
                  color: _isPressed ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5) : null,
                  border: Border.all(
                    color: _isPressed 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                        : Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    width: _isPressed ? 2 : 1,
                  ),
                  boxShadow: _isPressed ? [] : [
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
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20.r),
                          onTap: () => _navigateToPoem(context),
                          child: Padding(
                            padding: EdgeInsets.all(widget.isCompact 
                                ? 16.w 
                                : (isWideScreen ? 24.w : 20.w)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildEnhancedHeader(context, isWideScreen),
                                SizedBox(height: widget.isCompact ? 12.h : 16.h),
                                _buildEnhancedBookInfo(context, isWideScreen),
                                if (!widget.isCompact) ...[
                                  SizedBox(height: 16.h),
                                  _buildEnhancedActionChips(context),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader(BuildContext context, bool isWideScreen) {
    final isUrdu = widget.title.contains(RegExp(r'[\u0600-\u06FF]'));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTypeIcon(context),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStyledTitle(context, widget.title, isUrdu, isLarge: !widget.isCompact && isWideScreen, maxLines: widget.isCompact ? 1 : 2),
        ),
      ],
    );
  }

  Widget _buildTypeIcon(BuildContext context) {
    final theme = Theme.of(context);
    if (!_isPressed) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: AppDecorations.iconContainerDecoration(
        context, 
        theme.colorScheme.primary,
      ),
      child: Icon(
        Icons.auto_stories_outlined,
        size: widget.isCompact ? 16.w : 20.w,
        color: Colors.white,
      ),
    );
  }

  Widget _buildEnhancedBookInfo(BuildContext context, bool isWideScreen) {
    return FutureBuilder<String>(
      future: Get.find<PoemController>().getBookName(widget.poem.bookId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildShimmerBookInfo(context);
        }
        
        return Row(
          children: [
            Icon(
              Icons.book_outlined,
              size: 14.w,
              color: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                snapshot.data!,
                style: AppTextStyles.getBodyStyle(context).copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: widget.isCompact 
                      ? 12.sp 
                      : (isWideScreen ? 16.sp : 14.sp),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerBookInfo(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14.w,
          height: 14.w,
          decoration: AppDecorations.shimmerDecoration(context),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Container(
            height: 12.h,
            decoration: AppDecorations.shimmerDecoration(context),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedActionChips(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        _buildActionChip(
          context,
          icon: Icons.history_edu_rounded,
          label: 'Context',
          onTap: () => _showHistoricalContext(context),
        ),
        SizedBox(width: 8.w),
        _buildActionChip(
          context,
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: () => _sharePoem(context),
        ),
        const Spacer(),
        Text(
          '${widget.poem.data.split('\n').where((line) => line.trim().isNotEmpty).length} lines',
          style: AppTextStyles.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14.w,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: AppTextStyles.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapDown() {
    setState(() => _isPressed = true);
    _animationController.reverse();
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
    _animationController.forward();
  }

  void _navigateToPoem(BuildContext context) {
    HapticFeedback.lightImpact();
    Get.toNamed('/poem-detail', arguments: {
      'poem': widget.poem,
      'title': widget.title,
    });
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildOptionsBottomSheet(context),
    );
  }

  Widget _buildOptionsBottomSheet(BuildContext context) {
    return Container(
      decoration: AppDecorations.bottomSheetDecoration(context),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppDecorations.defaultPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),
                _buildOptionTile(
                  context,
                  icon: Icons.history_edu_rounded,
                  title: 'Historical Context',
                  subtitle: 'Learn about the background',
                  onTap: () {
                    Navigator.pop(context);
                    _showHistoricalContext(context);
                  },
                ),
                _buildOptionTile(
                  context,
                  icon: Icons.share_rounded,
                  title: 'Share Poem',
                  subtitle: 'Share with others',
                  onTap: () {
                    Navigator.pop(context);
                    _sharePoem(context);
                  },
                ),
                Obx(() {
                  final isFavorite = Get.find<PoemController>().isFavorite(widget.poem);
                  return _buildOptionTile(
                    context,
                    icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    title: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                    subtitle: isFavorite ? 'Remove from your collection' : 'Save to your collection',
                    onTap: () {
                      Navigator.pop(context);
                      Get.find<PoemController>().toggleFavorite(widget.poem);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: AppDecorations.iconContainerDecoration(
          context,
          theme.colorScheme.primary,
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20.w,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.getTitleStyle(context),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.getBodyStyle(context).copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }

  void _showHistoricalContext(BuildContext context) {
    debugPrint('📖 Requesting analysis for: ${widget.poem.title}');
    HistoricalContextSheet.show(context, widget.poem);
  }

  void _sharePoem(BuildContext context) {
    // Implement poem sharing functionality
    debugPrint('Sharing poem: ${widget.poem.title}');
  }

  Widget _buildStyledTitle(BuildContext context, String text, bool isUrdu, {bool isLarge = false, int maxLines = 2}) {
    final theme = Theme.of(context);
    final baseStyle = AppTextStyles.getTitleStyle(
      context,
      isUrdu: isUrdu,
      isLarge: isLarge,
    ).copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: isUrdu ? 0 : -0.2,
    );

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: baseStyle,
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
