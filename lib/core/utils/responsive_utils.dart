import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveUtils {
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;
  static const double _desktopBreakpoint = 1200;

  /// Get the current screen type
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < _tabletBreakpoint) {
      return ScreenType.tablet;
    } else if (width < _desktopBreakpoint) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    final type = getScreenType(context);
    return type == ScreenType.desktop || type == ScreenType.largeDesktop;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return EdgeInsets.all(16.w);
      case ScreenType.tablet:
        return EdgeInsets.all(24.w);
      case ScreenType.desktop:
        return EdgeInsets.all(32.w);
      case ScreenType.largeDesktop:
        return EdgeInsets.all(40.w);
    }
  }

  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return EdgeInsets.all(8.w);
      case ScreenType.tablet:
        return EdgeInsets.all(12.w);
      case ScreenType.desktop:
        return EdgeInsets.all(16.w);
      case ScreenType.largeDesktop:
        return EdgeInsets.all(20.w);
    }
  }

  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 1.0;
      case ScreenType.tablet:
        return 1.1;
      case ScreenType.desktop:
        return 1.2;
      case ScreenType.largeDesktop:
        return 1.3;
    }
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, {double baseSize = 24}) {
    final multiplier = getFontSizeMultiplier(context);
    return (baseSize * multiplier).w;
  }

  /// Get responsive border radius
  static BorderRadius getResponsiveBorderRadius(BuildContext context, {double baseRadius = 12}) {
    final screenType = getScreenType(context);
    double radius;
    switch (screenType) {
      case ScreenType.mobile:
        radius = baseRadius;
        break;
      case ScreenType.tablet:
        radius = baseRadius * 1.2;
        break;
      case ScreenType.desktop:
        radius = baseRadius * 1.4;
        break;
      case ScreenType.largeDesktop:
        radius = baseRadius * 1.6;
        break;
    }
    return BorderRadius.circular(radius.r);
  }

  /// Get responsive elevation
  static double getResponsiveElevation(BuildContext context, {double baseElevation = 4}) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseElevation;
      case ScreenType.tablet:
        return baseElevation * 1.2;
      case ScreenType.desktop:
        return baseElevation * 1.4;
      case ScreenType.largeDesktop:
        return baseElevation * 1.6;
    }
  }

  /// Get responsive grid column count
  static int getGridColumnCount(BuildContext context, {int mobileColumns = 1, int tabletColumns = 2, int desktopColumns = 3}) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return mobileColumns;
      case ScreenType.tablet:
        return tabletColumns;
      case ScreenType.desktop:
        return desktopColumns;
      case ScreenType.largeDesktop:
        return desktopColumns + 1;
    }
  }

  /// Get responsive container width
  static double getResponsiveWidth(BuildContext context, {double? maxWidth}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenType = getScreenType(context);
    
    if (maxWidth != null && screenWidth > maxWidth) {
      return maxWidth;
    }
    
    switch (screenType) {
      case ScreenType.mobile:
        return screenWidth;
      case ScreenType.tablet:
        return screenWidth * 0.9;
      case ScreenType.desktop:
        return screenWidth * 0.8;
      case ScreenType.largeDesktop:
        return screenWidth * 0.7;
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, {double baseSpacing = 16}) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseSpacing.h;
      case ScreenType.tablet:
        return (baseSpacing * 1.2).h;
      case ScreenType.desktop:
        return (baseSpacing * 1.4).h;
      case ScreenType.largeDesktop:
        return (baseSpacing * 1.6).h;
    }
  }

  /// Get responsive item size for selectors (like color picker, background picker)
  static double getResponsiveItemSize(BuildContext context, {double baseSize = 50}) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseSize.w;
      case ScreenType.tablet:
        return (baseSize * 1.2).w;
      case ScreenType.desktop:
        return (baseSize * 1.4).w;
      case ScreenType.largeDesktop:
        return (baseSize * 1.6).w;
    }
  }

  /// Get responsive preview height
  static double getResponsivePreviewHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return screenHeight < 700 ? 240.h : 280.h;
      case ScreenType.tablet:
        return screenHeight < 900 ? 320.h : 360.h;
      case ScreenType.desktop:
        return screenHeight < 1000 ? 400.h : 450.h;
      case ScreenType.largeDesktop:
        return 500.h;
    }
  }

  /// Get responsive dialog width
  static double getResponsiveDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return screenWidth * 0.9;
      case ScreenType.tablet:
        return screenWidth * 0.7;
      case ScreenType.desktop:
        return screenWidth * 0.5;
      case ScreenType.largeDesktop:
        return screenWidth * 0.4;
    }
  }

  /// Get responsive list item height
  static double getResponsiveListItemHeight(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 80.h;
      case ScreenType.tablet:
        return 90.h;
      case ScreenType.desktop:
        return 100.h;
      case ScreenType.largeDesktop:
        return 110.h;
    }
  }

  /// Get responsive card aspect ratio
  static double getResponsiveCardAspectRatio(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 1.5;
      case ScreenType.tablet:
        return 1.6;
      case ScreenType.desktop:
        return 1.7;
      case ScreenType.largeDesktop:
        return 1.8;
    }
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// Get responsive text scale factor
  static double getResponsiveTextScaleFactor(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 1.0;
      case ScreenType.tablet:
        return 1.1;
      case ScreenType.desktop:
        return 1.2;
      case ScreenType.largeDesktop:
        return 1.25;
    }
  }
}

enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Extension methods for responsive design
extension ResponsiveExtensions on BuildContext {
  ScreenType get screenType => ResponsiveUtils.getScreenType(this);
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  bool get isLandscape => ResponsiveUtils.isLandscape(this);
  
  EdgeInsets get responsivePadding => ResponsiveUtils.getResponsivePadding(this);
  EdgeInsets get responsiveMargin => ResponsiveUtils.getResponsiveMargin(this);
  double get fontSizeMultiplier => ResponsiveUtils.getFontSizeMultiplier(this);
  double get responsiveSpacing => ResponsiveUtils.getResponsiveSpacing(this);
  double get responsivePreviewHeight => ResponsiveUtils.getResponsivePreviewHeight(this);
  double get responsiveDialogWidth => ResponsiveUtils.getResponsiveDialogWidth(this);
  double get responsiveListItemHeight => ResponsiveUtils.getResponsiveListItemHeight(this);
  double get responsiveCardAspectRatio => ResponsiveUtils.getResponsiveCardAspectRatio(this);
  double get responsiveTextScaleFactor => ResponsiveUtils.getResponsiveTextScaleFactor(this);
} 