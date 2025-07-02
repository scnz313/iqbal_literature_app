import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../themes/app_decorations.dart';
import '../themes/text_styles.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final void Function()? onBackPressed;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;
  final double toolbarOpacity;
  final double bottomOpacity;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool forceMaterialTransparency;
  final Clip? clipBehavior;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.flexibleSpace,
    this.bottom,
    this.automaticallyImplyLeading = true,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    this.systemOverlayStyle,
    this.forceMaterialTransparency = false,
    this.clipBehavior,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDecorations.normalAnimation,
      vsync: this,
    );
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
    final isUrdu = Get.locale?.languageCode == 'ur';
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AppBar(
        title: AnimatedSwitcher(
          duration: AppDecorations.fastAnimation,
          child: Text(
            widget.title.tr,
            key: ValueKey(widget.title),
            style: _getTitleStyle(context, isUrdu),
          ),
        ),
        centerTitle: widget.centerTitle,
        automaticallyImplyLeading: widget.automaticallyImplyLeading && widget.showBackButton,
        leading: _buildLeading(context),
        actions: _buildActions(context),
        elevation: widget.elevation ?? 0,
        backgroundColor: widget.backgroundColor ?? theme.appBarTheme.backgroundColor,
        foregroundColor: widget.foregroundColor ?? theme.appBarTheme.foregroundColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        flexibleSpace: widget.flexibleSpace,
        bottom: widget.bottom,
        toolbarOpacity: widget.toolbarOpacity,
        bottomOpacity: widget.bottomOpacity,
        systemOverlayStyle: widget.systemOverlayStyle ?? _getSystemOverlayStyle(context),
        forceMaterialTransparency: widget.forceMaterialTransparency,
        clipBehavior: widget.clipBehavior,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (!widget.showBackButton) {
      return widget.leading;
    }

    if (widget.leading != null) {
      return widget.leading;
    }

    final canPop = ModalRoute.of(context)?.canPop ?? false;
    if (!canPop) {
      return null;
    }

    return _buildBackButton(context);
  }

  Widget _buildBackButton(BuildContext context) {
    final theme = Theme.of(context);
    
    return IconButton(
      icon: AnimatedSwitcher(
        duration: AppDecorations.fastAnimation,
        child: Icon(
          Icons.arrow_back_ios_rounded,
          key: const ValueKey('back_icon'),
          size: 20.w,
        ),
      ),
      onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: theme.appBarTheme.foregroundColor,
        padding: EdgeInsets.all(8.w),
      ),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (widget.actions == null || widget.actions!.isEmpty) {
      return null;
    }

    return widget.actions!.map((action) {
      return Padding(
        padding: EdgeInsets.only(right: 4.w),
        child: AnimatedSwitcher(
          duration: AppDecorations.fastAnimation,
          child: action,
        ),
      );
    }).toList();
  }

  TextStyle _getTitleStyle(BuildContext context, bool isUrdu) {
    final theme = Theme.of(context);
    final baseStyle = theme.appBarTheme.titleTextStyle ?? 
                     AppTextStyles.textTheme.titleLarge!;
    
    return baseStyle.copyWith(
      color: widget.foregroundColor ?? 
             theme.appBarTheme.foregroundColor ?? 
             theme.colorScheme.onSurface,
      fontFamily: isUrdu ? 'JameelNooriNastaleeq' : baseStyle.fontFamily,
      fontSize: isUrdu ? 20.sp : 18.sp,
      fontWeight: FontWeight.w600,
      height: isUrdu ? 1.5 : 1.2,
    );
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? 
                           theme.appBarTheme.backgroundColor ?? 
                           theme.colorScheme.surface;
    
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    
    return brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
  }
}
