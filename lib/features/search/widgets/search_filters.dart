import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchFilters extends StatelessWidget {
  final Map<String, bool> selectedFilters;
  final Function(String, bool) onFilterChanged;

  const SearchFilters({
    super.key,
    required this.selectedFilters,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(context, theme, 'Books', 'books'),
          SizedBox(width: 8.w),
          _buildFilterChip(context, theme, 'Poems', 'poems'),
          SizedBox(width: 8.w),
          _buildFilterChip(context, theme, 'Verses', 'verses'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    ThemeData theme,
    String label,
    String filter,
  ) {
    final isSelected = selectedFilters[filter] ?? false;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onFilterChanged(filter, !isSelected);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary
                : theme.dividerColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? theme.colorScheme.onPrimary
                : theme.textTheme.bodyMedium?.color,
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
