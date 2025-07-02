import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/book_controller.dart';
import '../widgets/book_tile.dart';
import '../../../data/models/book/book.dart';
import '../../../core/themes/app_decorations.dart';
import '../../../core/themes/text_styles.dart';

class BooksScreen extends GetView<BookController> {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value && controller.books.isEmpty) {
          return _buildLoadingState(context);
        }

        if (controller.books.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadBooks(),
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Books Grid/List
              _buildBooksSection(context),
              
              // Bottom Padding
              SliverToBoxAdapter(
                child: SizedBox(height: 100.h),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBooksSection(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final book = controller.books[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: index == controller.books.length - 1 ? 60 : 8.h,
                      ),
                      child: BookTile(
                        book: book,
                        isGridView: false,
                        showStats: true,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          childCount: controller.books.length,
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'کتابیں لوڈ ہو رہی ہیں...',
            style: AppTextStyles.getBodyStyle(context).copyWith(
              fontSize: 16.sp,
              fontFamily: 'JameelNooriNastaleeq',
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(60.r),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.auto_stories_outlined,
                size: 60.w,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'ابھی کوئی کتاب دستیاب نہیں',
              style: AppTextStyles.getTitleStyle(
                context,
                isUrdu: true,
                isLarge: true,
              ).copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'کتابوں کا ذخیرہ جلد ہی اپ ڈیٹ ہوگا\nاس وقت تک انتظار کریں',
              style: AppTextStyles.getBodyStyle(context).copyWith(
                fontSize: 16.sp,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                height: 1.6,
                fontFamily: 'JameelNooriNastaleeq',
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () => controller.loadBooks(),
              icon: Icon(Icons.refresh_rounded, size: 20.w),
              label: Text(
                'دوبارہ کوشش کریں',
                style: TextStyle(
                  fontFamily: 'JameelNooriNastaleeq',
                  fontSize: 16.sp,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
