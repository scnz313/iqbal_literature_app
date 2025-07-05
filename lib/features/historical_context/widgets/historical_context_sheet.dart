import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../features/poems/controllers/poem_controller.dart';
import '../../../features/poems/models/poem.dart';
import '../../../core/themes/app_decorations.dart';
import '../../../core/themes/text_styles.dart';
import '../models/historical_context.dart';
import '../../../utils/markdown_clean.dart';

class HistoricalContextSheet extends StatelessWidget {
  final Poem poem;

  const HistoricalContextSheet({
    super.key, 
    required this.poem,
  });

  static void show(BuildContext context, Poem poem) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.05),
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => HistoricalContextSheet(poem: poem),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PoemController>();
    final theme = Theme.of(context);
    final isUrdu = poem.title.contains(RegExp(r'[\u0600-\u06FF]'));

    return Container(
      decoration: AppDecorations.bottomSheetDecoration(context),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              
              // Header
              _buildHeader(context),
              
              // Content
              Expanded(
                child: FutureBuilder<Map<String, dynamic>?>(
                  future: controller.getHistoricalContext(poem.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingState();
                    }

                    if (snapshot.hasError) {
                      return _buildErrorState(snapshot.error.toString());
                    }

                    final data = snapshot.data;
                    if (data == null || data.isEmpty) {
                      return _buildErrorState('No historical context available');
                    }

                    final historicalContext = HistoricalContext.fromMap(data);
                    return _buildContent(context, historicalContext);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isUrdu = poem.title.contains(RegExp(r'[\u0600-\u06FF]'));
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: AppDecorations.iconContainerDecoration(
              context,
              theme.colorScheme.primary,
            ),
            child: Icon(
              Icons.history_edu,
              size: 24.w,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: isUrdu 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  'Historical Context',
                  style: AppTextStyles.getTitleStyle(context).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  poem.title,
                  style: AppTextStyles.getBodyStyle(context).copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: isUrdu ? 'JameelNooriNastaleeq' : null,
                    fontSize: isUrdu ? 14.sp : 12.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
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
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: AppDecorations.iconContainerDecoration(
              context,
              Theme.of(context).colorScheme.primary,
            ),
            child: Icon(
              Icons.history_edu,
              size: 40.w,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Loading historical context...',
            style: AppTextStyles.getTitleStyle(context).copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 16.h),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: AppDecorations.iconContainerDecoration(
              context,
              Theme.of(context).colorScheme.error,
            ),
            child: Icon(
              Icons.error_outline,
              size: 40.w,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Context Available',
            style: AppTextStyles.getTitleStyle(context).copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: AppTextStyles.getBodyStyle(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, HistoricalContext data) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // Basic sections
        _buildSection(context, 'Year', data.year),
        SizedBox(height: 20.h),
        _buildExpandableSection(
          context,
          'Historical Context',
          data.historicalContext.cleaned(),
        ),
        SizedBox(height: 16.h),
        _buildExpandableSection(
          context,
          'Significance',
          data.significance.cleaned(),
        ),
        SizedBox(height: 16.h),

        // Additional sections from API
        if (data.culturalImportance?.isNotEmpty ?? false)
          _buildExpandableSection(
            context,
            'Cultural Importance',
            data.culturalImportance!.cleaned(),
          ),
        if (data.religiousThemes?.isNotEmpty ?? false)
          _buildExpandableSection(
            context,
            'Religious Themes',
            data.religiousThemes!.cleaned(),
          ),
        if (data.politicalMessages?.isNotEmpty ?? false)
          _buildExpandableSection(
            context,
            'Political Messages',
            data.politicalMessages!.cleaned(),
          ),
        if (data.imagery?.isNotEmpty ?? false)
          _buildExpandableSection(
            context,
            'Imagery',
            data.imagery!.cleaned(),
          ),
        if (data.metaphor?.isNotEmpty ?? false)
          _buildExpandableSection(
            context,
            'Metaphor',
            data.metaphor!.cleaned(),
          ),
        if (data.symbolism?.isNotEmpty ?? false)
          _buildExpandableSection(
            context,
            'Symbolism',
            data.symbolism!.cleaned(),
          ),
        if (data.theme?.isNotEmpty ?? false)
          _buildExpandableSection(
            context,
            'Theme',
            data.theme!.cleaned(),
          ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    if (content.isEmpty || content == 'Not available') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: AppDecorations.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event,
                size: 20.w,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: AppTextStyles.getTitleStyle(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            content.cleaned(),
            style: AppTextStyles.getBodyStyle(context).copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(BuildContext context, String title, String content) {
    if (content.isEmpty || content == 'Not available') {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: AppDecorations.cardDecoration(context),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        childrenPadding: EdgeInsets.all(16.w),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: AppDecorations.iconContainerDecoration(
            context,
            Theme.of(context).colorScheme.primary,
          ),
          child: Icon(
            _getSectionIcon(title),
            color: Theme.of(context).colorScheme.primary,
            size: 20.w,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.getTitleStyle(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Text(
            content.cleaned(),
            style: AppTextStyles.getBodyStyle(context).copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSectionIcon(String title) {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('cultural')) {
      return Icons.groups;
    } else if (lowerTitle.contains('religious')) {
      return Icons.auto_stories;
    } else if (lowerTitle.contains('political')) {
      return Icons.gavel;
    } else if (lowerTitle.contains('imagery')) {
      return Icons.image;
    } else if (lowerTitle.contains('metaphor')) {
      return Icons.psychology;
    } else if (lowerTitle.contains('symbolism')) {
      return Icons.star;
    } else if (lowerTitle.contains('theme')) {
      return Icons.lightbulb_outline;
    } else if (lowerTitle.contains('significance')) {
      return Icons.emoji_events;
    } else {
      return Icons.history_edu;
    }
  }
}
