import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/asset_constants.dart';

class AppTextStyles {
  // Enhanced responsive text theme
  static TextTheme get textTheme => TextTheme(
    displayLarge: TextStyle(
      fontSize: 36.sp,
      fontWeight: FontWeight.bold,
      letterSpacing: -1.5,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 32.sp,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    displaySmall: TextStyle(
      fontSize: 28.sp,
      fontWeight: FontWeight.bold,
      height: 1.3,
    ),
    headlineLarge: TextStyle(
      fontSize: 24.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 22.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.25,
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleLarge: TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.sp,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14.sp,
      letterSpacing: 0.25,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12.sp,
      letterSpacing: 0.4,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      height: 1.3,
    ),
    labelMedium: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.3,
    ),
    labelSmall: TextStyle(
      fontSize: 10.sp,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.2,
    ),
  );

  // Enhanced Urdu Text Styles with responsive sizing
  static TextStyle get urduDisplayLarge => TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 40.sp,
    fontWeight: FontWeight.bold,
    height: 1.8,
    letterSpacing: 1.5,
  );

  static TextStyle get urduDisplayMedium => TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 36.sp,
    fontWeight: FontWeight.bold,
    height: 1.8,
    letterSpacing: 1.2,
  );

  static TextStyle get urduDisplaySmall => TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    height: 1.8,
    letterSpacing: 1.0,
  );

  static TextStyle get urduHeadlineLarge => TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 28.sp,
    fontWeight: FontWeight.w600,
    height: 1.8,
    letterSpacing: 0.8,
  );

  static TextStyle get urduHeadlineMedium => TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 26.sp,
    fontWeight: FontWeight.w600,
    height: 1.8,
    letterSpacing: 0.6,
  );

  static TextStyle get urduHeadlineSmall => TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    height: 1.8,
    letterSpacing: 0.4,
  );

  static TextStyle get urduTitleLarge => TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 22.sp,
    fontWeight: FontWeight.w500,
    height: 1.8,
    letterSpacing: 0.3,
  );

  static TextStyle get urduTitleMedium => TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 20.sp,
    fontWeight: FontWeight.w500,
    height: 1.8,
    letterSpacing: 0.2,
  );

  static TextStyle get urduTitleSmall => TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    height: 1.8,
    letterSpacing: 0.1,
  );

  static TextStyle get urduBodyLarge => TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 18.sp,
    height: 2.0,
    letterSpacing: 0.5,
  );

  static TextStyle get urduBodyMedium => TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 16.sp,
    height: 1.9,
    letterSpacing: 0.3,
  );

  static TextStyle get urduBodySmall => TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 14.sp,
    height: 1.8,
    letterSpacing: 0.2,
  );

  static TextStyle get urduPoetryLarge => TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 24.sp,
    height: 2.2,
    letterSpacing: 1.0,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get urduPoetryMedium => TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 20.sp,
    height: 2.0,
    letterSpacing: 0.8,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get urduPoetrySmall => TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 18.sp,
    height: 1.9,
    letterSpacing: 0.6,
    fontWeight: FontWeight.w400,
  );

  // Legacy Urdu styles (for compatibility)
  static TextStyle urduTitle = TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    height: 1.8,
  );

  static TextStyle urduBody = TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 18.sp,
    height: 1.8,
  );

  static TextStyle urduPoetry = TextStyle(
    fontFamily: AssetConstants.urduFontFamily,
    fontSize: 20.sp,
    height: 2.0,
    letterSpacing: 1.0,
  );

  // Enhanced Custom Styles with responsive design
  static TextStyle get cardTitleLarge => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static TextStyle get cardTitle => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static TextStyle get cardTitleSmall => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle get cardSubtitle => TextStyle(
    fontSize: 14.sp,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle get cardSubtitleSmall => TextStyle(
    fontSize: 12.sp,
    letterSpacing: 0.1,
    height: 1.3,
  );

  static TextStyle get buttonTextLarge => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
    height: 1.2,
  );

  static TextStyle get buttonText => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
    height: 1.2,
  );

  static TextStyle get buttonTextSmall => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
    height: 1.2,
  );

  static TextStyle get captionBold => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.3,
  );

  static TextStyle get overline => TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.2,
  );

  // Themed text styles that adapt to context
  static TextStyle getThemeAwareTextStyle(BuildContext context, TextStyle baseStyle) {
    final theme = Theme.of(context);
    return baseStyle.copyWith(
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle getThemeAwareUrduTextStyle(BuildContext context, TextStyle baseStyle) {
    final theme = Theme.of(context);
    return baseStyle.copyWith(
      color: theme.colorScheme.onSurface,
      fontFamily: AssetConstants.urduFontFamily,
    );
  }

  // Context-aware utility methods
  static TextStyle getTitleStyle(BuildContext context, {bool isUrdu = false, bool isLarge = false}) {
    final theme = Theme.of(context);
    final baseStyle = isLarge ? cardTitleLarge : cardTitle;
    
    return baseStyle.copyWith(
      color: theme.colorScheme.onSurface,
      fontFamily: isUrdu ? AssetConstants.urduFontFamily : null,
      fontSize: isUrdu ? (isLarge ? 22.sp : 18.sp) : baseStyle.fontSize,
      height: isUrdu ? 1.8 : baseStyle.height,
    );
  }

  static TextStyle getBodyStyle(BuildContext context, {bool isUrdu = false, bool isLarge = false}) {
    final theme = Theme.of(context);
    final baseStyle = isLarge ? textTheme.bodyLarge! : textTheme.bodyMedium!;
    
    return baseStyle.copyWith(
      color: theme.colorScheme.onSurface,
      fontFamily: isUrdu ? AssetConstants.urduFontFamily : null,
      fontSize: isUrdu ? (isLarge ? 18.sp : 16.sp) : baseStyle.fontSize,
      height: isUrdu ? 1.9 : baseStyle.height,
    );
  }

  static TextStyle getPoetryStyle(BuildContext context, {bool isLarge = false}) {
    final theme = Theme.of(context);
    final fontSize = isLarge ? 24.sp : 20.sp;
    
    return TextStyle(
      fontFamily: AssetConstants.urduFontFamily,
      fontSize: fontSize,
      height: 2.0,
      letterSpacing: 0.8,
      color: theme.colorScheme.onSurface,
    );
  }
}
