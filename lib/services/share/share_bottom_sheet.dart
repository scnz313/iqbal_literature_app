import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/poems/models/poem.dart';
import '../../core/themes/app_decorations.dart';
import '../../core/themes/text_styles.dart';
import '../../core/utils/responsive_utils.dart';
import 'share_service.dart';
import 'pdf_service.dart';

class ShareBottomSheet extends StatelessWidget {
  final Poem poem;
  const ShareBottomSheet({super.key, required this.poem});

  static void show(BuildContext context, Poem poem) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.3),
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => ShareBottomSheet(poem: poem),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ShareBottomSheetContent(poem: poem);
  }
}

class _ShareBottomSheetContent extends StatefulWidget {
  final Poem poem;
  final ScrollController? scrollController;

  const _ShareBottomSheetContent({
    required this.poem,
    this.scrollController,
  });

  @override
  State<_ShareBottomSheetContent> createState() =>
      _ShareBottomSheetContentState();
}

class _ShareBottomSheetContentState extends State<_ShareBottomSheetContent>
    with TickerProviderStateMixin {
  final GlobalKey _previewKey = GlobalKey();
  String? selectedBackground;
  Color selectedColor = Colors.white;
  Color textColor = Colors.black;
  double fontSize = 18.0;
  bool isLoading = false;
  String? errorMessage;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      setState(() {
        selectedColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
        textColor = isDark ? Colors.white : Colors.black;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleError(Object e) {
    setState(() {
      isLoading = false;
      errorMessage = e.toString();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Failed to share: ${e.toString()}',
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  final List<String?> backgroundOptions = [
    null, // No background
    'assets/images/notebook_lines.png',
    'assets/images/backgrounds/paper_texture_1.png',
    'assets/images/backgrounds/paper_texture_2.png',
    'assets/images/backgrounds/paper_texture_3.png',
    'assets/images/backgrounds/geometric_pattern_2.png',
    'assets/images/backgrounds/islamic_pattern_2.png',
    'assets/images/backgrounds/gradient_1.png',
  ];

  final List<Color> colorOptions = [
    Colors.white,
    const Color(0xFFFAFAFA),
    const Color(0xFFF5F5F5),
    Colors.amber.shade50,
    Colors.blue.shade50,
    Colors.green.shade50,
    Colors.pink.shade50,
    Colors.purple.shade50,
    const Color(0xFF2C2C2C),
    const Color(0xFF1F1F1F),
    const Color(0xFF3A3A3A),
    Colors.grey.shade800,
    const Color(0xFF253238),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDragHandle(context),
                  Flexible(
                    child: SingleChildScrollView(
                      controller: widget.scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        context.responsivePadding.left,
                        0,
                        context.responsivePadding.right,
                        context.responsivePadding.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          SizedBox(height: context.responsiveSpacing),
                          _buildPreviewSection(context),
                          SizedBox(height: context.responsiveSpacing),
                          _buildCustomizationSection(context),
                          SizedBox(height: context.responsiveSpacing),
                          _buildShareOptions(context),
                          // Add extra bottom padding for better scrolling
                          SizedBox(height: context.responsiveSpacing * 1.5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Container(
      width: 48.w,
      height: 4.h,
      margin: EdgeInsets.only(top: 16.h, bottom: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.share_rounded,
                size: 28.w,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share Poem',
                    style: AppTextStyles.getTitleStyle(context).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 22.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    widget.poem.title,
                    style: AppTextStyles.getBodyStyle(context).copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'JameelNooriNastaleeq',
                      fontSize: 16.sp,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: AppTextStyles.getTitleStyle(context).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: (18 * context.fontSizeMultiplier).sp,
          ),
        ),
        SizedBox(height: context.responsiveSpacing),
        Container(
          height: context.responsivePreviewHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: ResponsiveUtils.getResponsiveElevation(context, baseElevation: 20),
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 20),
            child: RepaintBoundary(
              key: _previewKey,
              child: _buildPreviewWidget(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewWidget() {
    bool needsDarkText = selectedColor.computeLuminance() > 0.5;
    Color adaptiveTextColor = needsDarkText ? Colors.black : Colors.white;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: selectedColor,
      ),
      child: Stack(
        children: [
          // Background image if selected
          if (selectedBackground != null && selectedBackground!.isNotEmpty)
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  selectedBackground!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(); // Return empty container on error
                  },
                ),
              ),
            ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.poem.title,
                style: TextStyle(
                  fontFamily: 'JameelNooriNastaleeq',
                  fontSize: fontSize + 6,
                  height: 1.6,
                  fontWeight: FontWeight.bold,
                  color: adaptiveTextColor,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    widget.poem.cleanData,
                    style: TextStyle(
                      fontFamily: 'JameelNooriNastaleeq',
                      fontSize: fontSize,
                      height: 1.8,
                      color: adaptiveTextColor,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Iqbal Literature',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: adaptiveTextColor.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customize',
          style: AppTextStyles.getTitleStyle(context).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        SizedBox(height: 20.h),
        _buildBackgroundSelector(),
        SizedBox(height: 24.h),
        _buildColorSelector(),
        SizedBox(height: 24.h),
        _buildFontSizeSelector(),
      ],
    );
  }

  Widget _buildBackgroundSelector() {
    final itemSize = ResponsiveUtils.getResponsiveItemSize(context, baseSize: 65);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Background Pattern',
          style: AppTextStyles.getBodyStyle(context).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: (16 * context.fontSizeMultiplier).sp,
          ),
        ),
        SizedBox(height: context.responsiveSpacing * 0.75),
        Container(
          height: (itemSize + context.responsiveSpacing).h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: context.responsiveMargin,
            itemCount: backgroundOptions.length,
            itemBuilder: (context, index) {
              final bg = backgroundOptions[index];
              final isSelected = selectedBackground == bg;
              
              return Container(
                margin: EdgeInsets.only(right: context.responsiveSpacing * 0.75),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedBackground = bg;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: itemSize.w,
                    height: itemSize.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 16),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        width: isSelected ? 3 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                blurRadius: ResponsiveUtils.getResponsiveElevation(context, baseElevation: 12),
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: ResponsiveUtils.getResponsiveElevation(context, baseElevation: 8),
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: bg == null 
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.block,
                                size: ResponsiveUtils.getIconSize(context, baseSize: itemSize * 0.35),
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'None',
                                style: TextStyle(
                                  fontSize: (itemSize * 0.14 * context.fontSizeMultiplier).sp,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 14),
                            child: Image.asset(
                              bg,
                              fit: BoxFit.cover,
                              width: itemSize.w,
                              height: itemSize.w,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('Error loading background image: $bg - $error');
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        color: Colors.grey.shade400,
                                        size: ResponsiveUtils.getIconSize(context, baseSize: itemSize * 0.4),
                                      ),
                                      Text(
                                        'Error',
                                        style: TextStyle(
                                          fontSize: (itemSize * 0.12 * context.fontSizeMultiplier).sp,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    final colorSize = ResponsiveUtils.getResponsiveItemSize(context, baseSize: 50);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Background Color',
          style: AppTextStyles.getBodyStyle(context).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: (16 * context.fontSizeMultiplier).sp,
          ),
        ),
        SizedBox(height: context.responsiveSpacing * 0.75),
        Container(
          height: (colorSize + context.responsiveSpacing).h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: context.responsiveMargin,
            itemCount: colorOptions.length,
            itemBuilder: (context, index) {
              final color = colorOptions[index];
              final isSelected = selectedColor == color;
              
              return Container(
                margin: EdgeInsets.only(right: context.responsiveSpacing * 0.75),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                      // Update text color based on background
                      textColor = color.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: colorSize.w,
                    height: colorSize.w,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        width: isSelected ? 3 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                blurRadius: ResponsiveUtils.getResponsiveElevation(context, baseElevation: 12),
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: ResponsiveUtils.getResponsiveElevation(context, baseElevation: 8),
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: color.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                            size: ResponsiveUtils.getIconSize(context, baseSize: colorSize * 0.48),
                          )
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFontSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Font Size',
              style: AppTextStyles.getBodyStyle(context).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${fontSize.round()}sp',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.text_decrease, size: 24.w),
                onPressed: fontSize > 14.0
                    ? () {
                        setState(() {
                          fontSize = (fontSize - 2.0).clamp(14.0, 26.0);
                        });
                      }
                    : null,
                style: IconButton.styleFrom(
                  backgroundColor: fontSize > 14.0
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Theme.of(context).colorScheme.primary,
                    inactiveTrackColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    thumbColor: Theme.of(context).colorScheme.primary,
                    overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.r),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 24.r),
                  ),
                  child: Slider(
                    value: fontSize,
                    min: 14.0,
                    max: 26.0,
                    divisions: 6,
                    onChanged: (value) {
                      setState(() {
                        fontSize = value;
                      });
                    },
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.text_increase, size: 24.w),
                onPressed: fontSize < 26.0
                    ? () {
                        setState(() {
                          fontSize = (fontSize + 2.0).clamp(14.0, 26.0);
                        });
                      }
                    : null,
                style: IconButton.styleFrom(
                  backgroundColor: fontSize < 26.0
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShareOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share Options',
          style: AppTextStyles.getTitleStyle(context).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        SizedBox(height: 16.h),
        _buildShareOptionCard(
          context,
          icon: Icons.text_fields_rounded,
          title: 'Share as Text',
          subtitle: 'Copy or share the poem text',
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
          ),
          onTap: () => _shareAsText(context),
        ),
        SizedBox(height: 12.h),
        _buildShareOptionCard(
          context,
          icon: Icons.image_rounded,
          title: 'Share as Image',
          subtitle: 'Create and share a beautiful image',
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
          ),
          onTap: () => _shareAsImage(context),
        ),
        SizedBox(height: 12.h),
        _buildShareOptionCard(
          context,
          icon: Icons.picture_as_pdf_rounded,
          title: 'Share as PDF',
          subtitle: 'Generate a professional PDF document',
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.orange.shade600],
          ),
          onTap: () => _shareAsPdf(context),
        ),
      ],
    );
  }

  Widget _buildShareOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    final iconSize = ResponsiveUtils.getResponsiveItemSize(context, baseSize: 56);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: ResponsiveUtils.getResponsiveElevation(context, baseElevation: 10),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 16),
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 16),
          child: Container(
            padding: context.responsivePadding,
            child: Row(
              children: [
                Container(
                  width: iconSize.w,
                  height: iconSize.w,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.3),
                        blurRadius: ResponsiveUtils.getResponsiveElevation(context, baseElevation: 12),
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: ResponsiveUtils.getIconSize(context, baseSize: iconSize * 0.5),
                  ),
                ),
                SizedBox(width: context.responsiveSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.getTitleStyle(context).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: (16 * context.fontSizeMultiplier).sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: AppTextStyles.getBodyStyle(context).copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: (14 * context.fontSizeMultiplier).sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    width: ResponsiveUtils.getIconSize(context, baseSize: 24),
                    height: ResponsiveUtils.getIconSize(context, baseSize: 24),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: ResponsiveUtils.getIconSize(context, baseSize: 18),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _shareAsText(BuildContext context) {
    final text = '${widget.poem.title}\n\n${widget.poem.cleanData}\n\n— Shared via Iqbal Literature';
    Share.share(text);
    Navigator.pop(context);
  }

  void _shareAsImage(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Use full content image sharing for better results with large poems
      await ShareService.shareFullContentAsImage(
        context: context,
        title: widget.poem.title.trim(),
        content: widget.poem.cleanData.trim(),
        filename: 'iqbal_poem',
        backgroundColor: selectedColor,
        textColor: textColor,
        backgroundImage: selectedBackground,
      );
    } catch (e) {
      _handleError(e);
      return;
    } finally {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  void _shareAsPdf(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Validate content before generating PDF
      final title = widget.poem.title.trim();
      final content = widget.poem.cleanData.trim();
      
      if (title.isEmpty && content.isEmpty) {
        throw Exception('No content available to generate PDF');
      }

      // Use the new PDF service for robust generation
      await PdfService.generateAndSharePdf(
        title: title,
        content: content,
        context: context,
      );
      
    } catch (e) {
      debugPrint('[PDF] Error in _shareAsPdf: $e');
      _handleError(e);
      return;
    } finally {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }
  }
}
