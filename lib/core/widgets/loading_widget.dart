import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../themes/app_decorations.dart';
import '../themes/text_styles.dart';

class LoadingWidget extends StatefulWidget {
  final String? message;
  final Color? color;
  final double? size;
  final bool showBackground;
  final EdgeInsets? padding;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
    this.size,
    this.showBackground = false,
    this.padding,
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
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
    final effectiveColor = widget.color ?? theme.colorScheme.primary;
    final effectiveSize = widget.size ?? 40.w;
    final effectivePadding = widget.padding ?? AppDecorations.defaultPadding;

    Widget loadingContent = FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: effectiveSize,
            height: effectiveSize,
            child: CircularProgressIndicator(
              color: effectiveColor,
              strokeWidth: 3.w,
              backgroundColor: effectiveColor.withOpacity(0.1),
            ),
          ),
          if (widget.message != null) ...[
            SizedBox(height: 16.h),
            AnimatedSwitcher(
              duration: AppDecorations.fastAnimation,
              child: Text(
                widget.message!,
                key: ValueKey(widget.message),
                style: AppTextStyles.getBodyStyle(context).copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );

    if (widget.showBackground) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.roundedContainerDecoration(context),
        padding: effectivePadding,
        child: Center(child: loadingContent),
      );
    }

    return Padding(
      padding: effectivePadding,
      child: Center(child: loadingContent),
    );
  }
}

// Enhanced loading indicator for smaller spaces
class CompactLoadingWidget extends StatelessWidget {
  final Color? color;
  final double? size;

  const CompactLoadingWidget({
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    final effectiveSize = size ?? 20.w;

    return SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: CircularProgressIndicator(
        color: effectiveColor,
        strokeWidth: 2.w,
        backgroundColor: effectiveColor.withOpacity(0.1),
      ),
    );
  }
}

// Loading overlay for full-screen loading
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: LoadingWidget(
                message: loadingMessage,
                showBackground: false,
              ),
            ),
          ),
      ],
    );
  }
}
