import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/search_result.dart';
import 'package:get/get.dart';
import '../../../data/repositories/poem_repository.dart';


class SearchResultTile extends StatelessWidget {
  final SearchResult result;

  const SearchResultTile({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Since app is 100% Urdu, always treat as Urdu content
    const isUrdu = true;
    const isUrduSubtitle = true;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => _navigateToDetails(),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end, // Align to right for Urdu
              children: [
                _buildHeader(context, theme, isUrdu),
                if (result.subtitle.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _buildContent(context, theme, isUrduSubtitle),
                ],
                SizedBox(height: 12.h),
                _buildFooter(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isUrdu) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl, // Always RTL for Urdu
      children: [
        Expanded(
          child: Text(
            result.title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'JameelNooriNastaleeq',
              color: theme.textTheme.titleLarge?.color,
              height: 1.6,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 12.w),
        _buildTypeIcon(theme),
      ],
    );
  }

  Widget _buildTypeIcon(ThemeData theme) {
    IconData iconData;
    Color iconColor;

    switch (result.type) {
      case SearchResultType.book:
        iconData = Icons.book_rounded;
        iconColor = theme.colorScheme.primary;
        break;
      case SearchResultType.poem:
        iconData = Icons.article_rounded;
        iconColor = theme.colorScheme.secondary;
        break;
      case SearchResultType.line:
        iconData = Icons.format_quote_rounded;
        iconColor = theme.colorScheme.tertiary;
        break;
    }

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 18.w,
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, bool isUrdu) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        result.subtitle,
        style: TextStyle(
          fontFamily: 'JameelNooriNastaleeq',
          fontSize: 16.sp,
          height: 1.8,
          color: theme.textTheme.bodyMedium?.color,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: TextDirection.rtl,
      children: [
        _buildActionButton(context, theme),
        _buildTypeChip(context, theme),
      ],
    );
  }

  Widget _buildTypeChip(BuildContext context, ThemeData theme) {
    String label;
    switch (result.type) {
      case SearchResultType.book:
        label = 'کتاب';
        break;
      case SearchResultType.poem:
        label = 'نظم';
        break;
      case SearchResultType.line:
        label = 'شعر';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
          fontFamily: 'JameelNooriNastaleeq',
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () => _navigateToDetails(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.rtl,
          children: [
            Text(
              'دیکھیں',
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontFamily: 'JameelNooriNastaleeq',
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.arrow_back_rounded, // Use back arrow for RTL
              size: 14.w,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails() async {
    HapticFeedback.lightImpact();
    switch (result.type) {
      case SearchResultType.book:
        Get.toNamed('/book-poems', arguments: {
          'book_id': result.id,
          'book_name': result.title,
          'view_type': 'book_specific'
        });
        break;
      case SearchResultType.poem:
      case SearchResultType.line:
        // For poems and lines, fetch the full poem data first
        try {
          final poemId = int.tryParse(result.id) ?? 0;
          if (poemId > 0) {
            // Show loading indicator
            Get.dialog(
              AlertDialog(
                content: Row(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 16),
                    Text('Loading poem...'),
                  ],
                ),
              ),
              barrierDismissible: false,
            );

            // Get the poem repository instance
            final poemRepository = Get.find<PoemRepository>();
            
            // Fetch all poems and find the specific one
            final allPoems = await poemRepository.getAllPoems();
            final fullPoem = allPoems.firstWhereOrNull((poem) => poem.id == poemId);
            
            // Close loading dialog
            if (Get.isDialogOpen ?? false) {
              Get.back();
            }
            
            if (fullPoem != null) {
              // Navigate with the full poem object
              Get.toNamed('/poem-detail', arguments: fullPoem);
            } else {
              // Fallback to the old method with limited data
              Get.snackbar(
                'Error',
                'Could not load full poem data',
                snackPosition: SnackPosition.BOTTOM,
              );
              Get.toNamed('/poem-detail', arguments: {
                'poem_id': result.id,
                'title': result.title,
                'content': result.subtitle,
                'type': result.type.toString(),
              });
            }
          } else {
            // Fallback to the old method
            Get.toNamed('/poem-detail', arguments: {
              'poem_id': result.id,
              'title': result.title,
              'content': result.subtitle,
              'type': result.type.toString(),
            });
          }
        } catch (e) {
          // Close loading dialog if it's open
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
          
          debugPrint('Error fetching full poem: $e');
          Get.snackbar(
            'Error',
            'Could not load poem. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        break;
    }
  }
}
