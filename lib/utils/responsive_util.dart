import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ResponsiveUtil {
  // Standard design size for mobile (iPhone 13/14 size)
  static const double designWidth = 390;
  static const double designHeight = 844;

  // Tablet breakpoint
  static const double tabletBreakpoint = 600;
  static const double largeTabletBreakpoint = 900;

  /// Check if ScreenUtil is properly initialized
  static bool get isScreenUtilInitialized {
    try {
      final testValue = 1.0.sp;
      return testValue.isFinite && !testValue.isNaN;
    } catch (e) {
      return false;
    }
  }

  /// Safe ScreenUtil method with fallback
  static double _safeScreenUtil(double Function() screenUtilMethod, double fallback) {
    if (!isScreenUtilInitialized) {
      return fallback;
    }
    try {
      final result = screenUtilMethod();
      return result.isFinite && !result.isNaN ? result : fallback;
    } catch (e) {
      return fallback;
    }
  }

  /// Check if the current device is a tablet
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.shortestSide >= tabletBreakpoint;
  }

  /// Check if the current device is a large tablet
  static bool isLargeTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.shortestSide >= largeTabletBreakpoint;
  }

  /// Get the appropriate font size based on screen type
  static double getFontSize(double size) {
    // Use ScreenUtil to scale font sizes properly with safety check
    return _safeScreenUtil(() => size.sp, size);
  }

  /// Get appropriate width based on screen type
  static double getWidth(double width) {
    return _safeScreenUtil(() => width.w, width);
  }

  /// Get appropriate height based on screen type
  static double getHeight(double height) {
    return _safeScreenUtil(() => height.h, height);
  }

  /// Get appropriate padding/margin based on screen type
  static EdgeInsets getPadding(
      {double left = 0, double top = 0, double right = 0, double bottom = 0}) {
    return EdgeInsets.only(
      left: _safeScreenUtil(() => left.w, left),
      top: _safeScreenUtil(() => top.h, top),
      right: _safeScreenUtil(() => right.w, right),
      bottom: _safeScreenUtil(() => bottom.h, bottom),
    );
  }

  /// Get symmetric padding/margin based on screen type
  static EdgeInsets getSymmetricPadding({
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: _safeScreenUtil(() => horizontal.w, horizontal),
      vertical: _safeScreenUtil(() => vertical.h, vertical),
    );
  }

  /// Get all-sides padding/margin based on screen type
  static EdgeInsets getAllPadding(double padding) {
    return EdgeInsets.all(_safeScreenUtil(() => padding.r, padding));
  }

  /// Get responsive radius for shapes
  static BorderRadius getBorderRadius(double radius) {
    return BorderRadius.circular(_safeScreenUtil(() => radius.r, radius));
  }

  /// Get appropriate scaling factor for icons and other elements
  static double getScaleFactor(BuildContext context) {
    if (isLargeTablet(context)) {
      return 1.3;
    } else if (isTablet(context)) {
      return 1.15;
    } else {
      return 1.0;
    }
  }
}
