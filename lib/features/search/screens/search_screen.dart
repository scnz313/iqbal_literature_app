import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart' as app_search;
import '../widgets/search_result_tile.dart';
import '../widgets/search_result.dart';

class SearchScreen extends GetView<app_search.SearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(context, theme),
            Expanded(
              child: GetBuilder<app_search.SearchController>(
                builder: (ctrl) => _buildContentArea(context, theme),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GetBuilder<app_search.SearchController>(
        builder: (ctrl) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: ctrl.showScrollToTop.value && ctrl.searchResults.isNotEmpty
              ? _buildScrollToTopButton(context, theme)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildScrollToTopButton(BuildContext context, ThemeData theme) {
    return FloatingActionButton.small(
      heroTag: "searchScrollToTop",
      onPressed: () {
        HapticFeedback.lightImpact();
        controller.scrollToTop();
      },
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 4,
      child: Icon(
        Icons.keyboard_arrow_up_rounded,
        size: 24.w,
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSearchBar(context, theme),
          SizedBox(height: 20.h),
          _buildFilterChips(context, theme),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme) {
    return Container(
      height: 58.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.cardColor,
            theme.cardColor.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 20.w),
          GetBuilder<app_search.SearchController>(
            builder: (ctrl) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: ctrl.searchQuery.isEmpty
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                color: ctrl.searchQuery.isEmpty
                    ? theme.colorScheme.primary.withOpacity(0.7)
                    : theme.colorScheme.primary,
                size: 20.w,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: GetBuilder<app_search.SearchController>(
              builder: (ctrl) => TextField(
                controller: ctrl.urduSearchController,
                onChanged: ctrl.onSearchChanged,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontFamily: 'JameelNooriNastaleeq',
                  color: theme.textTheme.bodyLarge?.color,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'اردو میں تلاش کریں...',
                  hintStyle: TextStyle(
                    color: theme.hintColor.withOpacity(0.7),
                    fontFamily: 'JameelNooriNastaleeq',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  hintTextDirection: TextDirection.rtl,
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          GetBuilder<app_search.SearchController>(
            builder: (ctrl) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: ctrl.searchQuery.isNotEmpty
                  ? _buildClearButton(context, theme)
                  : _buildMicButton(context, theme),
            ),
          ),
          SizedBox(width: 12.w),
        ],
      ),
    );
  }

  Widget _buildClearButton(BuildContext context, ThemeData theme) {
    return Container(
      key: const ValueKey('clear'),
      margin: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          controller.clearSearch();
        },
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            color: theme.colorScheme.error.withOpacity(0.8),
            size: 18.w,
          ),
        ),
      ),
    );
  }

  Widget _buildMicButton(BuildContext context, ThemeData theme) {
    return Container(
      key: const ValueKey('mic'),
      margin: EdgeInsets.only(right: 8.w),
      child: GetBuilder<app_search.SearchController>(
        builder: (ctrl) => GestureDetector(
          onTap: () async {
            HapticFeedback.mediumImpact();
            await ctrl.startVoiceSearch();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: ctrl.isListening.value
                  ? theme.colorScheme.primary.withOpacity(0.2)
                  : theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              ctrl.isListening.value
                  ? Icons.mic_rounded
                  : Icons.mic_none_rounded,
              color: ctrl.isListening.value
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withOpacity(0.7),
              size: 18.w,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, ThemeData theme) {
    return GetBuilder<app_search.SearchController>(
      builder: (ctrl) => Container(
        height: 42.h,
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12.w,
            children: [
              _buildFilterChip(context, theme, 'تمام', null),
              _buildFilterChip(context, theme, 'کتابیں', SearchResultType.book),
              _buildFilterChip(context, theme, 'نظمیں', SearchResultType.poem),
              _buildFilterChip(context, theme, 'اشعار', SearchResultType.line),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, ThemeData theme, String label, SearchResultType? type) {
    final isSelected = controller.selectedFilter.value == type;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        controller.setFilter(type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withOpacity(0.15)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? theme.colorScheme.primary
                : theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontFamily: 'JameelNooriNastaleeq',
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Widget _buildContentArea(BuildContext context, ThemeData theme) {
    final query = controller.searchQuery;
    final isLoading = controller.isLoading.value;
    final hasResults = controller.searchResults.isNotEmpty;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: LayoutBuilder(
        key: ValueKey('$query-$isLoading-$hasResults'),
        builder: (context, constraints) {
          if (query.isEmpty) {
            return _buildEmptySearchState(context, theme);
          } else if (isLoading) {
            return _buildLoadingState(context, theme);
          } else if (!hasResults) {
            return _buildNoResultsState(context, theme);
          } else {
            return _buildSearchResults(context, theme);
          }
        },
      ),
    );
  }

  Widget _buildEmptySearchState(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          SizedBox(height: 60.h),
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.2),
                  theme.colorScheme.primary.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.search_rounded,
              size: 60.w,
              color: theme.colorScheme.primary.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'ابتدائی تلاش',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: theme.textTheme.titleLarge?.color,
              fontFamily: 'JameelNooriNastaleeq',
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 12.h),
          Text(
            'کتابیں، نظمیں اور اشعار تلاش کریں',
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.hintColor.withOpacity(0.9),
              fontFamily: 'JameelNooriNastaleeq',
              height: 1.4,
            ),
            textDirection: TextDirection.rtl,
          ),
          if (controller.recentSearches.isNotEmpty) ...[
            SizedBox(height: 40.h),
            _buildRecentSearches(context, theme),
          ],
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.cardColor,
            theme.cardColor.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await controller.clearRecentSearches();
                },
                icon: Icon(
                  Icons.clear_all_rounded,
                  size: 16.w,
                  color: theme.colorScheme.error.withOpacity(0.7),
                ),
                label: Text(
                  'صاف کریں',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: 'JameelNooriNastaleeq',
                    color: theme.colorScheme.error.withOpacity(0.7),
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    'حالیہ تلاش',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color,
                      fontFamily: 'JameelNooriNastaleeq',
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      size: 16.w,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 10.w,
            runSpacing: 10.h,
            children: controller.recentSearches.take(4).map((search) {
              final displaySearch = search.length > 20 ? '${search.substring(0, 17)}...' : search;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.applyRecentSearch(search);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 14.w,
                        color: theme.hintColor,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        displaySearch,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: 'JameelNooriNastaleeq',
                          color: theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w500,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.2),
                    theme.colorScheme.primary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'تلاش جاری ہے...',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleMedium?.color,
                fontFamily: 'JameelNooriNastaleeq',
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 8.h),
            Text(
              'براہ کرم انتظار کریں',
              style: TextStyle(
                fontSize: 14.sp,
                color: theme.hintColor,
                fontFamily: 'JameelNooriNastaleeq',
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 60.h),
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.error.withOpacity(0.2),
                  theme.colorScheme.error.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.error.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 50.w,
              color: theme.colorScheme.error.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'کوئی نتیجہ نہیں ملا',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: theme.textTheme.titleLarge?.color,
              fontFamily: 'JameelNooriNastaleeq',
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'مختلف الفاظ آزمائیں یا فلٹرز تبدیل کریں',
              style: TextStyle(
                fontSize: 15.sp,
                color: theme.hintColor,
                fontFamily: 'JameelNooriNastaleeq',
                height: 1.4,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              controller.clearSearch();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              elevation: 4,
            ),
            icon: Icon(
              Icons.refresh_rounded, 
              size: 18.w,
            ),
            label: Text(
              'صاف کریں',
              style: TextStyle(
                fontSize: 15.sp,
                fontFamily: 'JameelNooriNastaleeq',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, ThemeData theme) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          controller.showScrollToTop.value = notification.metrics.pixels > 500;
        }
        return false;
      },
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Results summary
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_rounded,
                        size: 16.w,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'نتائج',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'JameelNooriNastaleeq',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${controller.searchResults.length}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Books section
          if (controller.bookResults.isNotEmpty)
            _buildResultSection(
              context, 
              theme,
              'کتابیں', 
              controller.bookResults, 
              Icons.book_rounded,
            ),

          // Poems section
          if (controller.poemResults.isNotEmpty)
            _buildResultSection(
              context, 
              theme,
              'نظمیں', 
              controller.poemResults, 
              Icons.article_rounded,
            ),

          // Lines section
          if (controller.verseResults.isNotEmpty)
            _buildResultSection(
              context, 
              theme,
              'اشعار', 
              controller.verseResults, 
              Icons.format_quote_rounded,
            ),

          // Bottom padding
          SliverToBoxAdapter(
            child: SizedBox(height: 100.h),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(
    BuildContext context,
    ThemeData theme,
    String title,
    List<SearchResult> results,
    IconData icon,
  ) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.cardColor,
                  theme.cardColor.withOpacity(0.95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${results.length}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.titleMedium?.color,
                        fontFamily: 'JameelNooriNastaleeq',
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.2),
                            theme.colorScheme.primary.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        icon,
                        color: theme.colorScheme.primary,
                        size: 18.w,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ...results.map((result) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: SearchResultTile(result: result),
          )),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
