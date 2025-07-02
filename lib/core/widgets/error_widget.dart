import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/asset_constants.dart';
import '../themes/app_decorations.dart';
import '../themes/text_styles.dart';

enum ErrorType {
  network,
  general,
  notFound,
  permission,
  timeout,
}

class CustomErrorWidget extends StatefulWidget {
  final String? message;
  final VoidCallback? onRetry;
  final ErrorType errorType;
  final IconData? customIcon;
  final bool showBackground;
  final EdgeInsets? padding;

  const CustomErrorWidget({
    super.key,
    this.message,
    this.onRetry,
    this.errorType = ErrorType.general,
    this.customIcon,
    this.showBackground = false,
    this.padding,
  });

  @override
  State<CustomErrorWidget> createState() => _CustomErrorWidgetState();
}

class _CustomErrorWidgetState extends State<CustomErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
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
    final effectivePadding = widget.padding ?? AppDecorations.largePadding;

    Widget errorContent = FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildErrorIcon(context),
            SizedBox(height: 24.h),
            _buildErrorTitle(context),
            SizedBox(height: 12.h),
            _buildErrorMessage(context),
            if (widget.onRetry != null) ...[
              SizedBox(height: 32.h),
              _buildRetryButton(context),
            ],
          ],
        ),
      ),
    );

    if (widget.showBackground) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.roundedContainerDecoration(context),
        padding: effectivePadding,
        child: Center(child: errorContent),
      );
    }

    return Padding(
      padding: effectivePadding,
      child: Center(child: errorContent),
    );
  }

  Widget _buildErrorIcon(BuildContext context) {
    final theme = Theme.of(context);
    IconData iconData;
    Color iconColor;

    switch (widget.errorType) {
      case ErrorType.network:
        iconData = Icons.wifi_off_rounded;
        iconColor = Colors.orange;
        break;
      case ErrorType.notFound:
        iconData = Icons.search_off_rounded;
        iconColor = Colors.blue;
        break;
      case ErrorType.permission:
        iconData = Icons.lock_outline_rounded;
        iconColor = Colors.amber;
        break;
      case ErrorType.timeout:
        iconData = Icons.access_time_rounded;
        iconColor = Colors.purple;
        break;
      case ErrorType.general:
      default:
        iconData = Icons.error_outline_rounded;
        iconColor = theme.colorScheme.error;
        break;
    }

    return Container(
      width: 80.w,
      height: 80.w,
      decoration: AppDecorations.circularIconDecoration(context, iconColor),
      child: Icon(
        widget.customIcon ?? iconData,
        size: 40.w,
        color: iconColor,
      ),
    );
  }

  Widget _buildErrorTitle(BuildContext context) {
    String title;
    switch (widget.errorType) {
      case ErrorType.network:
        title = 'No Internet Connection';
        break;
      case ErrorType.notFound:
        title = 'Not Found';
        break;
      case ErrorType.permission:
        title = 'Permission Denied';
        break;
      case ErrorType.timeout:
        title = 'Request Timeout';
        break;
      case ErrorType.general:
      default:
        title = 'Something went wrong';
        break;
    }

    return Text(
      title,
      style: AppTextStyles.getTitleStyle(context, isLarge: true).copyWith(
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    String defaultMessage;
    switch (widget.errorType) {
      case ErrorType.network:
        defaultMessage = 'Please check your internet connection and try again.';
        break;
      case ErrorType.notFound:
        defaultMessage = 'The requested content could not be found.';
        break;
      case ErrorType.permission:
        defaultMessage = 'You don\'t have permission to access this resource.';
        break;
      case ErrorType.timeout:
        defaultMessage = 'The request took too long to complete.';
        break;
      case ErrorType.general:
      default:
        defaultMessage = 'An unexpected error occurred. Please try again.';
        break;
    }

    return Text(
      widget.message ?? defaultMessage,
      style: AppTextStyles.getBodyStyle(context).copyWith(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        _animationController.reverse().then((_) {
          widget.onRetry?.call();
          _animationController.forward();
        });
      },
      style: AppDecorations.elevatedButtonStyle,
      icon: Icon(Icons.refresh_rounded, size: 18.w),
      label: Text(
        'Try Again',
        style: AppTextStyles.buttonText,
      ),
    );
  }
}

// Compact error widget for smaller spaces
class CompactErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final ErrorType errorType;

  const CompactErrorWidget({
    super.key,
    this.message,
    this.onRetry,
    this.errorType = ErrorType.general,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: AppDecorations.compactPadding,
      decoration: AppDecorations.roundedContainerDecoration(context).copyWith(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: theme.colorScheme.error,
            size: 20.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message ?? 'An error occurred',
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(width: 8.w),
            TextButton(
              onPressed: onRetry,
              style: AppDecorations.textButtonStyle.copyWith(
                padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                ),
                minimumSize: MaterialStateProperty.all(Size.zero),
              ),
              child: Text(
                'Retry',
                style: AppTextStyles.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
