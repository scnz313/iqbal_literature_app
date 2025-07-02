import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'color_schemes.dart';

class AppDecorations {
  // Enhanced Card Decorations with responsive design
  static RoundedRectangleBorder get defaultCardShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16.r),
  );

  static RoundedRectangleBorder get largeCardShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20.r),
  );

  static RoundedRectangleBorder get smallCardShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.r),
  );

  static EdgeInsets get defaultCardMargin => EdgeInsets.symmetric(
    horizontal: 12.w,
    vertical: 8.h,
  );

  static EdgeInsets get largeCardMargin => EdgeInsets.symmetric(
    horizontal: 16.w,
    vertical: 12.h,
  );

  static EdgeInsets get compactCardMargin => EdgeInsets.symmetric(
    horizontal: 8.w,
    vertical: 6.h,
  );

  // Enhanced Card Decoration with theme awareness
  static BoxDecoration cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16.r),
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.12),
        width: 1,
      ),
      boxShadow: isDark ? [] : [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ],
    );
  }

  // Enhanced Button Styles
  static ButtonStyle get elevatedButtonStyle => ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    ),
    elevation: 2,
    minimumSize: Size(120.w, 44.h),
  );

  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.r),
    ),
    elevation: 4,
    minimumSize: Size(140.w, 52.h),
  );

  static ButtonStyle get compactButtonStyle => ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
    ),
    elevation: 1,
    minimumSize: Size(80.w, 36.h),
  );

  static ButtonStyle get outlinedButtonStyle => OutlinedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    ),
    side: const BorderSide(width: 1.5),
    minimumSize: Size(120.w, 44.h),
  );

  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
    ),
    minimumSize: Size(80.w, 36.h),
  );

  // Enhanced Input Decorations with theme awareness
  static InputDecoration textFieldDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isError = false,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: theme.colorScheme.error,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: theme.colorScheme.error,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: theme.colorScheme.surface,
    );
  }

  // Enhanced Container Decorations
  static BoxDecoration roundedContainerDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16.r),
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        width: 1,
      ),
      boxShadow: isDark ? [] : [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration elevatedContainerDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20.r),
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
        width: 1,
      ),
      boxShadow: isDark ? [] : [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 6),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ],
    );
  }

  // Enhanced Dialog and Modal Decorations
  static RoundedRectangleBorder get dialogShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24.r),
  );

  static RoundedRectangleBorder get bottomSheetShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(24.r),
    ),
  );

  static RoundedRectangleBorder get snackBarShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.r),
  );

  // Enhanced Bottom Sheet Decoration
  static BoxDecoration bottomSheetDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24.r),
      ),
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        width: 1,
      ),
      boxShadow: isDark ? [] : [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, -8),
          spreadRadius: 0,
        ),
      ],
    );
  }

  // Gradient Decorations
  static BoxDecoration gradientDecoration(BuildContext context, {
    required Color startColor,
    required Color endColor,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius.r),
      gradient: LinearGradient(
        begin: begin,
        end: end,
        colors: [
          startColor,
          endColor,
        ],
      ),
    );
  }

  // Icon Container Decorations
  static BoxDecoration iconContainerDecoration(BuildContext context, Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  static BoxDecoration circularIconDecoration(BuildContext context, Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.12),
      shape: BoxShape.circle,
    );
  }

  // List Item Decorations
  static BoxDecoration listItemDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(
        bottom: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
    );
  }

  // Enhanced Shimmer Decorations
  static BoxDecoration shimmerDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
      color: isDark ? AppColorSchemes.shimmerBaseDark : AppColorSchemes.shimmerBase,
    );
  }

  // Spacing Constants
  static EdgeInsets get defaultPadding => EdgeInsets.all(16.w);
  static EdgeInsets get largePadding => EdgeInsets.all(24.w);
  static EdgeInsets get compactPadding => EdgeInsets.all(12.w);
  static EdgeInsets get smallPadding => EdgeInsets.all(8.w);

  static EdgeInsets get horizontalPadding => EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get verticalPadding => EdgeInsets.symmetric(vertical: 16.h);

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
}
