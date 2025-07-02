import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'color_schemes.dart';
import 'text_styles.dart';
import 'app_decorations.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: AppColorSchemes.lightColorScheme,
    textTheme: AppTextStyles.textTheme,
    scaffoldBackgroundColor: AppColorSchemes.lightColorScheme.surface,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColorSchemes.lightColorScheme.surfaceVariant,
      foregroundColor: AppColorSchemes.lightColorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleTextStyle: AppTextStyles.textTheme.titleLarge?.copyWith(
        color: AppColorSchemes.lightColorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: AppDecorations.defaultCardShape,
      margin: AppDecorations.defaultCardMargin,
      color: AppColorSchemes.lightColorScheme.surface,
      surfaceTintColor: AppColorSchemes.lightColorScheme.surface,
      shadowColor: Colors.black.withOpacity(0.1),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppDecorations.elevatedButtonStyle.copyWith(
        backgroundColor: MaterialStateProperty.all(AppColorSchemes.lightColorScheme.primary),
        foregroundColor: MaterialStateProperty.all(AppColorSchemes.lightColorScheme.onPrimary),
        textStyle: MaterialStateProperty.all(AppTextStyles.buttonText),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppDecorations.outlinedButtonStyle.copyWith(
        foregroundColor: MaterialStateProperty.all(AppColorSchemes.lightColorScheme.primary),
        side: MaterialStateProperty.all(BorderSide(
          color: AppColorSchemes.lightColorScheme.outline,
          width: 1.5,
        )),
        textStyle: MaterialStateProperty.all(AppTextStyles.buttonText),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: AppDecorations.textButtonStyle.copyWith(
        foregroundColor: MaterialStateProperty.all(AppColorSchemes.lightColorScheme.primary),
        textStyle: MaterialStateProperty.all(AppTextStyles.buttonText),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: AppDecorations.snackBarShape,
      backgroundColor: AppColorSchemes.lightColorScheme.inverseSurface,
      contentTextStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
        color: AppColorSchemes.lightColorScheme.onInverseSurface,
      ),
      actionTextColor: AppColorSchemes.lightColorScheme.inversePrimary,
      elevation: 4,
    ),
    dividerColor: AppColorSchemes.dividerColor,
    dividerTheme: DividerThemeData(
      color: AppColorSchemes.dividerColor,
      thickness: 1,
      space: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColorSchemes.lightColorScheme.surface,
      indicatorColor: AppColorSchemes.lightColorScheme.primary.withOpacity(0.12),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppTextStyles.textTheme.labelMedium?.copyWith(
            fontFamily: 'JameelNooriNastaleeq',
            color: AppColorSchemes.lightColorScheme.onSurface,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTextStyles.textTheme.labelMedium?.copyWith(
          fontFamily: 'JameelNooriNastaleeq',
          color: AppColorSchemes.lightColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(
            color: AppColorSchemes.lightColorScheme.primary,
            size: 24.sp,
          );
        }
        return IconThemeData(
          color: AppColorSchemes.lightColorScheme.onSurfaceVariant,
          size: 24.sp,
        );
      }),
      elevation: 0,
      height: 80.h,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColorSchemes.lightColorScheme.surface,
      shape: AppDecorations.bottomSheetShape,
      elevation: 8,
      modalElevation: 16,
      showDragHandle: true,
      dragHandleColor: AppColorSchemes.lightColorScheme.onSurfaceVariant.withOpacity(0.4),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColorSchemes.lightColorScheme.surface,
      shape: AppDecorations.dialogShape,
      elevation: 24,
      titleTextStyle: AppTextStyles.textTheme.headlineSmall?.copyWith(
        color: AppColorSchemes.lightColorScheme.onSurface,
      ),
      contentTextStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
        color: AppColorSchemes.lightColorScheme.onSurface,
      ),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      horizontalTitleGap: 16.w,
      minVerticalPadding: 8.h,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: AppColorSchemes.darkColorScheme,
    textTheme: AppTextStyles.textTheme.apply(
      bodyColor: AppColorSchemes.darkColorScheme.onSurface,
      displayColor: AppColorSchemes.darkColorScheme.onSurface,
    ),
    scaffoldBackgroundColor: AppColorSchemes.darkColorScheme.background,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColorSchemes.darkColorScheme.surface,
      foregroundColor: AppColorSchemes.darkColorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleTextStyle: AppTextStyles.textTheme.titleLarge?.copyWith(
        color: AppColorSchemes.darkColorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: AppDecorations.defaultCardShape,
      margin: AppDecorations.defaultCardMargin,
      color: AppColorSchemes.darkColorScheme.surface,
      surfaceTintColor: AppColorSchemes.darkColorScheme.surface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppDecorations.elevatedButtonStyle.copyWith(
        backgroundColor: MaterialStateProperty.all(AppColorSchemes.darkColorScheme.primary),
        foregroundColor: MaterialStateProperty.all(AppColorSchemes.darkColorScheme.onPrimary),
        textStyle: MaterialStateProperty.all(AppTextStyles.buttonText.copyWith(
          color: AppColorSchemes.darkColorScheme.onPrimary,
        )),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppDecorations.outlinedButtonStyle.copyWith(
        foregroundColor: MaterialStateProperty.all(AppColorSchemes.darkColorScheme.primary),
        side: MaterialStateProperty.all(BorderSide(
          color: AppColorSchemes.darkColorScheme.outline,
          width: 1.5,
        )),
        textStyle: MaterialStateProperty.all(AppTextStyles.buttonText.copyWith(
          color: AppColorSchemes.darkColorScheme.primary,
        )),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: AppDecorations.textButtonStyle.copyWith(
        foregroundColor: MaterialStateProperty.all(AppColorSchemes.darkColorScheme.primary),
        textStyle: MaterialStateProperty.all(AppTextStyles.buttonText.copyWith(
          color: AppColorSchemes.darkColorScheme.primary,
        )),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: AppDecorations.snackBarShape,
      backgroundColor: AppColorSchemes.darkColorScheme.inverseSurface,
      contentTextStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
        color: AppColorSchemes.darkColorScheme.onInverseSurface,
      ),
      actionTextColor: AppColorSchemes.darkColorScheme.inversePrimary,
      elevation: 4,
    ),
    dividerColor: AppColorSchemes.dividerColorDark,
    dividerTheme: DividerThemeData(
      color: AppColorSchemes.dividerColorDark,
      thickness: 1,
      space: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColorSchemes.darkColorScheme.surface,
      indicatorColor: AppColorSchemes.darkColorScheme.primary.withOpacity(0.2),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppTextStyles.textTheme.labelMedium?.copyWith(
            fontFamily: 'JameelNooriNastaleeq',
            color: AppColorSchemes.darkColorScheme.onSurface,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTextStyles.textTheme.labelMedium?.copyWith(
          fontFamily: 'JameelNooriNastaleeq',
          color: AppColorSchemes.darkColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(
            color: AppColorSchemes.darkColorScheme.primary,
            size: 24.sp,
          );
        }
        return IconThemeData(
          color: AppColorSchemes.darkColorScheme.onSurfaceVariant,
          size: 24.sp,
        );
      }),
      elevation: 0,
      height: 80.h,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColorSchemes.darkColorScheme.surface,
      shape: AppDecorations.bottomSheetShape,
      elevation: 8,
      modalElevation: 16,
      showDragHandle: true,
      dragHandleColor: AppColorSchemes.darkColorScheme.onSurfaceVariant.withOpacity(0.4),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColorSchemes.darkColorScheme.surface,
      shape: AppDecorations.dialogShape,
      elevation: 24,
      titleTextStyle: AppTextStyles.textTheme.headlineSmall?.copyWith(
        color: AppColorSchemes.darkColorScheme.onSurface,
      ),
      contentTextStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
        color: AppColorSchemes.darkColorScheme.onSurface,
      ),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      horizontalTitleGap: 16.w,
      minVerticalPadding: 8.h,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
    ),
  );

  static ThemeData get sepiaTheme => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: AppColorSchemes.sepiaColorScheme,
    textTheme: AppTextStyles.textTheme.apply(
      bodyColor: AppColorSchemes.sepiaColorScheme.onSurface,
      displayColor: AppColorSchemes.sepiaColorScheme.onSurface,
    ),
    scaffoldBackgroundColor: AppColorSchemes.sepiaColorScheme.background,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColorSchemes.sepiaColorScheme.surface,
      foregroundColor: AppColorSchemes.sepiaColorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleTextStyle: AppTextStyles.textTheme.titleLarge?.copyWith(
        color: AppColorSchemes.sepiaColorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: AppDecorations.defaultCardShape,
      margin: AppDecorations.defaultCardMargin,
      color: AppColorSchemes.sepiaColorScheme.surface,
      shadowColor: AppColorSchemes.sepiaColorScheme.primary.withOpacity(0.2),
      surfaceTintColor: AppColorSchemes.sepiaColorScheme.surface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppDecorations.elevatedButtonStyle.copyWith(
        backgroundColor: MaterialStateProperty.all(AppColorSchemes.sepiaColorScheme.primary),
        foregroundColor: MaterialStateProperty.all(AppColorSchemes.sepiaColorScheme.onPrimary),
        textStyle: MaterialStateProperty.all(AppTextStyles.buttonText.copyWith(
          color: AppColorSchemes.sepiaColorScheme.onPrimary,
        )),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppDecorations.outlinedButtonStyle.copyWith(
        foregroundColor: MaterialStateProperty.all(AppColorSchemes.sepiaColorScheme.primary),
        side: MaterialStateProperty.all(BorderSide(
          color: AppColorSchemes.sepiaColorScheme.outline,
          width: 1.5,
        )),
        textStyle: MaterialStateProperty.all(AppTextStyles.buttonText.copyWith(
          color: AppColorSchemes.sepiaColorScheme.primary,
        )),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: AppDecorations.textButtonStyle.copyWith(
        foregroundColor: MaterialStateProperty.all(AppColorSchemes.sepiaColorScheme.primary),
        textStyle: MaterialStateProperty.all(AppTextStyles.buttonText.copyWith(
          color: AppColorSchemes.sepiaColorScheme.primary,
        )),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: AppDecorations.snackBarShape,
      backgroundColor: AppColorSchemes.sepiaColorScheme.onSurface,
      contentTextStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
        color: AppColorSchemes.sepiaColorScheme.surface,
      ),
      actionTextColor: AppColorSchemes.sepiaColorScheme.primary,
      elevation: 4,
    ),
    dividerColor: AppColorSchemes.dividerColor,
    dividerTheme: DividerThemeData(
      color: AppColorSchemes.dividerColor,
      thickness: 1,
      space: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColorSchemes.sepiaColorScheme.surface,
      indicatorColor: AppColorSchemes.sepiaColorScheme.primary.withOpacity(0.15),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppTextStyles.textTheme.labelMedium?.copyWith(
            fontFamily: 'JameelNooriNastaleeq',
            color: AppColorSchemes.sepiaColorScheme.onSurface,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTextStyles.textTheme.labelMedium?.copyWith(
          fontFamily: 'JameelNooriNastaleeq',
          color: AppColorSchemes.sepiaColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(
            color: AppColorSchemes.sepiaColorScheme.primary,
            size: 24.sp,
          );
        }
        return IconThemeData(
          color: AppColorSchemes.sepiaColorScheme.onSurfaceVariant,
          size: 24.sp,
        );
      }),
      elevation: 0,
      height: 80.h,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColorSchemes.sepiaColorScheme.surface,
      shape: AppDecorations.bottomSheetShape,
      elevation: 8,
      modalElevation: 16,
      showDragHandle: true,
      dragHandleColor: AppColorSchemes.sepiaColorScheme.onSurfaceVariant.withOpacity(0.4),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColorSchemes.sepiaColorScheme.surface,
      shape: AppDecorations.dialogShape,
      elevation: 24,
      titleTextStyle: AppTextStyles.textTheme.headlineSmall?.copyWith(
        color: AppColorSchemes.sepiaColorScheme.onSurface,
      ),
      contentTextStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
        color: AppColorSchemes.sepiaColorScheme.onSurface,
      ),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      horizontalTitleGap: 16.w,
      minVerticalPadding: 8.h,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
    ),
  );
}
