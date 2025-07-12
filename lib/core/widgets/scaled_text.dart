import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/font_controller.dart';
import '../../utils/responsive_util.dart';

class ScaledText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool responsive;

  const ScaledText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.maxLines,
    this.overflow,
    this.responsive = true,
  });

  @override
  Widget build(BuildContext context) {
    try {
      // Check if FontController is registered before using it
      if (Get.isRegistered<FontController>()) {
    return GetX<FontController>(
      builder: (controller) {
        final baseSize = style?.fontSize ??
            Theme.of(context).textTheme.bodyMedium?.fontSize ??
            14.0;

        // Apply both font controller scaling and responsive scaling if enabled
        final double scaledSize = baseSize * controller.scaleFactor.value;
        final double finalFontSize = responsive
            ? ResponsiveUtil.getFontSize(scaledSize)
            : scaledSize;

        final scaledStyle = style?.copyWith(
          fontSize: finalFontSize,
        );

        return Text(
          text,
          style: scaledStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
      } else {
        // Fallback to regular Text widget if FontController is not available
        final baseSize = style?.fontSize ??
            Theme.of(context).textTheme.bodyMedium?.fontSize ??
            14.0;
        
        final double finalFontSize = responsive
            ? ResponsiveUtil.getFontSize(baseSize)
            : baseSize;

        final scaledStyle = style?.copyWith(
          fontSize: finalFontSize,
        );

        return Text(
          text,
          style: scaledStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          maxLines: maxLines,
          overflow: overflow,
        );
      }
    } catch (e) {
      // Ultimate fallback - just return a basic Text widget
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        textDirection: textDirection,
        maxLines: maxLines,
        overflow: overflow,
      );
    }
  }
}
