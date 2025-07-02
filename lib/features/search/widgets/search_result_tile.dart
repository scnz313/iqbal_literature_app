import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/search_result.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_decorations.dart';
import '../../../core/themes/text_styles.dart';

class SearchResultTile extends StatefulWidget {
  final SearchResult result;

  const SearchResultTile({Key? key, required this.result}) : super(key: key);

  @override
  State<SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<SearchResultTile>
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
    final isUrdu = widget.result.title.contains(RegExp(r'[\u0600-\u06FF]'));
    final isUrduSubtitle = widget.result.subtitle.contains(RegExp(r'[\u0600-\u06FF]'));

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) => _onTapDown(),
          onTapUp: (_) => _onTapUp(),
          onTapCancel: () => _onTapUp(),
          onTap: () => _navigateToDetails(),
          onLongPress: () => _showOptions(context),
          child: AnimatedContainer(
            duration: AppDecorations.fastAnimation,
            margin: AppDecorations.defaultCardMargin,
            decoration: AppDecorations.cardDecoration(context).copyWith(
              boxShadow: _isPressed ? [] : AppDecorations.cardDecoration(context).boxShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: () => _navigateToDetails(),
                child: Padding(
                  padding: AppDecorations.defaultPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, theme, isUrdu),
                      if (widget.result.subtitle.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        _buildContent(context, theme, isUrduSubtitle),
                      ],
                      SizedBox(height: 12.h),
                      _buildFooter(context, theme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isUrdu) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
      children: [
        _buildTypeIcon(theme),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            widget.result.title,
            style: AppTextStyles.getTitleStyle(
              context,
              isUrdu: isUrdu,
              isLarge: true,
            ),
            textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildSearchIcon(context, theme),
      ],
    );
  }

  Widget _buildTypeIcon(ThemeData theme) {
    IconData iconData;
    Color iconColor;

    switch (widget.result.type) {
      case SearchResultType.book:
        iconData = Icons.book_outlined;
        iconColor = theme.colorScheme.primary;
        break;
      case SearchResultType.poem:
        iconData = Icons.article_outlined;
        iconColor = theme.colorScheme.secondary;
        break;
      case SearchResultType.line:
        iconData = Icons.format_quote_outlined;
        iconColor = theme.colorScheme.tertiary;
        break;
    }

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: AppDecorations.iconContainerDecoration(context, iconColor),
      child: Icon(
        iconData,
        color: iconColor,
        size: 18.w,
      ),
    );
  }

  Widget _buildSearchIcon(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        Icons.search_rounded,
        size: 16.w,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, bool isUrdu) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Text(
        widget.result.subtitle,
        style: AppTextStyles.getBodyStyle(context).copyWith(
          fontFamily: isUrdu ? 'JameelNooriNastaleeq' : null,
          fontSize: isUrdu ? 16.sp : 14.sp,
          height: isUrdu ? 1.8 : 1.5,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        textAlign: isUrdu ? TextAlign.right : TextAlign.left,
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        _buildActionChip(
          context,
          icon: Icons.visibility_rounded,
          label: 'View',
          onTap: () => _navigateToDetails(),
        ),
        const Spacer(),
        _buildTypeChip(context, theme),
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
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14.w,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: AppTextStyles.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, ThemeData theme) {
    String label;
    switch (widget.result.type) {
      case SearchResultType.book:
        label = 'Book';
        break;
      case SearchResultType.poem:
        label = 'Poem';
        break;
      case SearchResultType.line:
        label = 'Line';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
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

  void _showOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOptionsBottomSheet(context),
    );
  }

  Widget _buildOptionsBottomSheet(BuildContext context) {
    return Container(
      decoration: AppDecorations.bottomSheetDecoration(context),
      child: SafeArea(
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
                icon: Icons.visibility_rounded,
                title: 'View ${widget.result.type.name}',
                subtitle: 'Open the ${widget.result.type.name.toLowerCase()}',
                onTap: () {
                  Navigator.pop(context);
                  _navigateToDetails();
                },
              ),
              _buildOptionTile(
                context,
                icon: Icons.share_rounded,
                title: 'Share',
                subtitle: 'Share this ${widget.result.type.name.toLowerCase()}',
                onTap: () {
                  Navigator.pop(context);
                  _shareResult(context);
                },
              ),
            ],
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

  void _shareResult(BuildContext context) {
    // Implement sharing functionality
    debugPrint('Sharing result: ${widget.result.title}');
  }

  void _navigateToDetails() {
    HapticFeedback.lightImpact();
    switch (widget.result.type) {
      case SearchResultType.book:
        Get.toNamed('/book-poems', arguments: {
          'book_id': widget.result.id,
          'book_name': widget.result.title,
          'view_type': 'book_specific'
        });
        break;
      case SearchResultType.poem:
      case SearchResultType.line:
        Get.toNamed('/poem-detail', arguments: {
          'poem_id': widget.result.id,
          'title': widget.result.title,
          'content': widget.result.subtitle,
          'type': widget.result.type.toString(),
        });
        break;
    }
  }
}
