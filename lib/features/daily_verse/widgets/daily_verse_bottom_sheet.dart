import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/themes/app_decorations.dart';
import '../../../core/themes/text_styles.dart';
import '../controllers/daily_verse_controller.dart';
import 'daily_verse_card.dart';

class DailyVerseBottomSheet extends StatelessWidget {
  const DailyVerseBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: AppDecorations.bottomSheetDecoration(context),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppDecorations.defaultPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),

                // Header
                _buildHeader(context),
                SizedBox(height: 20.h),

                // Daily Verse Card
                const DailyVerseCard(),

                // Bottom padding
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: AppDecorations.iconContainerDecoration(
            context,
            theme.colorScheme.primary,
          ),
          child: Icon(
            Icons.auto_awesome_outlined,
            size: 24.w,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Wisdom',
                style: AppTextStyles.getTitleStyle(context).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Your daily dose of inspiration from Iqbal',
                style: AppTextStyles.getBodyStyle(context).copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            padding: EdgeInsets.all(8.w),
          ),
        ),
      ],
    );
  }
}
