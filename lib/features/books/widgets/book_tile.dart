import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/book_controller.dart';
import '../../../data/models/book/book.dart';
import '../../daily_verse/controllers/daily_verse_controller.dart';
import '../../../core/themes/app_decorations.dart';
import '../../../core/themes/text_styles.dart';

class BookTile extends StatefulWidget {
  final Book book;
  final VoidCallback? onTap;
  final bool isGridView;
  final bool showStats;

  const BookTile({
    super.key,
    required this.book,
    this.onTap,
    this.isGridView = false,
    this.showStats = true,
  });

  @override
  State<BookTile> createState() => _BookTileState();
}

class _BookTileState extends State<BookTile>
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
    return widget.isGridView
        ? _buildGridTile(context)
        : _buildListTile(context);
  }

  Widget _buildGridTile(BuildContext context) {
    final theme = Theme.of(context);
    final isUrdu = widget.book.name.contains(RegExp(r'[\u0600-\u06FF]'));

    return GestureDetector(
      onTap: () => _handleTap(context),
      onLongPress: () => _showBookOptions(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
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
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    // Enhanced book icon
                    _buildEnhancedBookIcon(context),
                    SizedBox(width: 20.w),
                    
                    // Book details with better typography
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isUrdu 
                            ? CrossAxisAlignment.end 
                            : CrossAxisAlignment.start,
                        children: [
                          // Title with enhanced styling
                          _buildEnhancedTitle(context, widget.book.name, isUrdu),
                          SizedBox(height: 12.h),
                          
                          // Metadata row
                          Row(
                            mainAxisAlignment: isUrdu 
                                ? MainAxisAlignment.end 
                                : MainAxisAlignment.start,
                            children: [
                              _buildEnhancedLanguageBadge(context),
                              if (widget.showStats) ...[
                                SizedBox(width: 12.w),
                                _buildEnhancedStatsChip(context),
                              ],
                            ],
                          ),
                          SizedBox(height: 12.h),
                          
                          // Description or excerpt
                          _buildBookDescription(context, isUrdu),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    
                    // Action button
                    _buildActionArrow(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context) {
    final theme = Theme.of(context);
    final isUrdu = widget.book.name.contains(RegExp(r'[\u0600-\u06FF]'));

    return GestureDetector(
      onTap: () => _handleTap(context),
      onLongPress: () => _showBookOptions(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
          color: Theme.of(context).colorScheme.surfaceVariant,
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
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    // Enhanced book icon
                    _buildEnhancedBookIcon(context),
                    SizedBox(width: 20.w),
                    
                    // Book details with better typography
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isUrdu 
                            ? CrossAxisAlignment.end 
                            : CrossAxisAlignment.start,
                        children: [
                          // Title with enhanced styling
                          _buildEnhancedTitle(context, widget.book.name, isUrdu),
                          SizedBox(height: 12.h),
                          
                          // Metadata row
                          Row(
                            mainAxisAlignment: isUrdu 
                                ? MainAxisAlignment.end 
                                : MainAxisAlignment.start,
                            children: [
                              _buildEnhancedLanguageBadge(context),
                              if (widget.showStats) ...[
                                SizedBox(width: 12.w),
                                _buildEnhancedStatsChip(context),
                              ],
                            ],
                          ),
                          SizedBox(height: 12.h),
                          
                          // Description or excerpt
                          _buildBookDescription(context, isUrdu),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    
                    // Action button
                    _buildActionArrow(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookIcon(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: widget.isGridView ? 40.w : 50.w,
      height: widget.isGridView ? 40.w : 50.w,
      decoration: AppDecorations.iconContainerDecoration(
        context,
        theme.colorScheme.primary.withOpacity(0.1),
      ),
            child: Icon(
        Icons.auto_stories_rounded,
        size: widget.isGridView ? 20.w : 24.w,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildLanguageBadge(BuildContext context) {
    final theme = Theme.of(context);
    final isUrdu = widget.book.language.contains(RegExp(r'[\u0600-\u06FF]'));
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        widget.book.language,
        style: AppTextStyles.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontFamily: isUrdu ? 'JameelNooriNastaleeq' : null,
          fontSize: isUrdu ? 11.sp : 10.sp,
          fontWeight: FontWeight.w600,
            ),
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
          ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.article_outlined,
          size: 14.w,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 4.w),
        Text(
          'Book',
          style: AppTextStyles.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: widget.isGridView ? 10.sp : 11.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (widget.isGridView) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => _handleTap(context),
          style: AppDecorations.outlinedButtonStyle.copyWith(
            padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(vertical: 8.h),
            ),
            minimumSize: MaterialStateProperty.all(Size.zero),
          ),
          child: Text(
            'Open',
            style: AppTextStyles.buttonTextSmall,
                ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _showBookOptions(context),
          icon: Icon(
            Icons.more_vert_rounded,
            size: 20.w,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.all(8.w),
          ),
        ),
      ],
    );
  }

  void _handleTap(BuildContext context) {
    HapticFeedback.lightImpact();
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      Get.toNamed('/book-poems', arguments: {
        'book': widget.book,
        'book_id': widget.book.id,
        'book_name': widget.book.name,
        'view_type': 'book_specific',
      });
    }
  }

  void _showBookOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.05),
      isScrollControlled: true,
      useRootNavigator: true,
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
                // Drag handle
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),
                
                // Book info header
                _buildBookInfoHeader(context),
                SizedBox(height: 20.h),
                
                // Options
                _buildOptionTile(
                  context,
                  icon: Icons.auto_awesome_outlined,
                  title: 'Daily Wisdom',
                  subtitle: 'Get insights from this book',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/daily-verse', arguments: {'book': widget.book});
                  },
                ),
                _buildOptionTile(
                  context,
                  icon: Icons.timeline_rounded,
                  title: 'Historical Timeline',
                  subtitle: 'Explore the historical timeline',
            onTap: () {
              Navigator.pop(context);
                    Get.toNamed('/timeline', arguments: {
                      'book_id': widget.book.id,
                      'book_name': widget.book.name,
                      'time_period': widget.book.timePeriod,
                    });
                  },
                ),
                Obx(() {
                  final isFav = Get.find<BookController>().isFavorite(widget.book);
                  return _buildOptionTile(
                    context,
                    icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    title: isFav ? 'Remove from Favorites' : 'Add to Favorites',
                    subtitle: isFav ? 'Remove this book from favorites' : 'Save this book to favorites',
                    onTap: () {
                      Navigator.pop(context);
                      Get.find<BookController>().toggleFavorite(widget.book);
                    },
                  );
                }),
                _buildOptionTile(
                  context,
                  icon: Icons.share_rounded,
                  title: 'Share Book',
                  subtitle: 'Share with others',
            onTap: () {
              Navigator.pop(context);
                    // Implement book sharing
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookInfoHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isUrdu = widget.book.name.contains(RegExp(r'[\u0600-\u06FF]'));
    
    return Row(
      children: [
        Container(
          width: 60.w,
          height: 60.w,
          decoration: AppDecorations.iconContainerDecoration(
            context,
            theme.colorScheme.primary,
          ),
          child: Icon(
            Icons.auto_stories_rounded,
            size: 30.w,
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
              _buildStyledTitle(context, widget.book.name, isUrdu, isLarge: true),
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: isUrdu 
                    ? MainAxisAlignment.end 
                    : MainAxisAlignment.start,
                children: [
                  _buildLanguageBadge(context),
                  if (widget.showStats) ...[
                    SizedBox(width: 12.w),
                    _buildStatsRow(context),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildStyledTitle(BuildContext context, String text, bool isUrdu, {bool isLarge = false}) {
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
        maxLines: isLarge ? 2 : 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEnhancedBookIcon(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.auto_stories_rounded,
        size: 28.w,
        color: Colors.white,
      ),
    );
  }

  Widget _buildEnhancedTitle(BuildContext context, String text, bool isUrdu) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: AppTextStyles.getTitleStyle(
        context,
        isUrdu: isUrdu,
        isLarge: true,
      ).copyWith(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        height: isUrdu ? 1.6 : 1.3,
        letterSpacing: isUrdu ? 0 : -0.3,
        color: theme.colorScheme.primary,
      ),
      textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildEnhancedLanguageBadge(BuildContext context) {
    final theme = Theme.of(context);
    final isUrdu = widget.book.language.contains(RegExp(r'[\u0600-\u06FF]'));
    
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
            isUrdu ? Icons.translate_rounded : Icons.language_rounded,
            size: 14.w,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 6.w),
          Text(
            widget.book.language,
            style: AppTextStyles.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFamily: isUrdu ? 'JameelNooriNastaleeq' : null,
              fontSize: isUrdu ? 12.sp : 11.sp,
              fontWeight: FontWeight.w600,
            ),
            textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatsChip(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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
            Icons.auto_stories_outlined,
            size: 12.w,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 4.w),
          Text(
            'کتاب',
            style: AppTextStyles.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10.sp,
              fontFamily: 'JameelNooriNastaleeq',
              fontWeight: FontWeight.w600,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

 Widget _buildBookDescription(BuildContext context, bool isUrdu) { 
    final theme = Theme.of(context);
    // You can customize this based on your book model
    String description = ''; // Removed hardcoded description
    
    return Text(
      description,
      style: AppTextStyles.getBodyStyle(context).copyWith(
        fontSize: 14.sp,
        color: theme.colorScheme.onSurface.withOpacity(0.6),
        height: 1.4,
        fontFamily: isUrdu ? 'JameelNooriNastaleeq' : null,
      ),
      textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionArrow(BuildContext context) {
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
}
