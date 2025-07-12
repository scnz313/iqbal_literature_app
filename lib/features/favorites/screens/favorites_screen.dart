import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../books/controllers/book_controller.dart';
import '../../poems/controllers/poem_controller.dart';
import '../../books/widgets/book_tile.dart';
import '../../poems/widgets/poem_card.dart';
import '../../../core/themes/text_styles.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookController = Get.find<BookController>();
    final poemController = Get.find<PoemController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                floating: true,
                pinned: true,
                snap: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                elevation: 0,
                title: Text(
                  'پسندیدہ',
                  style: AppTextStyles.getTitleStyle(
                    context,
                    isUrdu: true,
                    isLarge: true,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                centerTitle: true,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(48.h),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      ),
                      indicatorPadding: EdgeInsets.all(2.w),
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      labelStyle: TextStyle(
                        fontFamily: 'JameelNooriNastaleeq',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontFamily: 'JameelNooriNastaleeq',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(
                          child: Text(
                            'کتابیں',
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                        Tab(
                          child: Text(
                            'نظمیں',
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
          children: [
              _buildBooksTab(context, bookController),
              _buildPoemsTab(context, poemController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBooksTab(BuildContext context, BookController bookController) {
    return Obx(() {
      if (bookController.isLoading.value) {
        return _buildLoadingState(context, 'کتابیں لوڈ ہو رہی ہیں...');
      }

              if (bookController.favoriteBooks.isEmpty) {
        return _buildEmptyState(
          context,
          icon: Icons.book_outlined,
          title: 'کوئی پسندیدہ کتاب نہیں',
          subtitle: 'کتابوں کو پسندیدہ میں شامل کرنے کے لیے\nانہیں لمبے دبائے دبائیں',
        );
              }

      return RefreshIndicator(
        onRefresh: () async {
          await bookController.loadBooks();
          await bookController.loadFavorites();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                  final book = bookController.favoriteBooks[index];
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
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
                  childCount: bookController.favoriteBooks.length,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPoemsTab(BuildContext context, PoemController poemController) {
    return Obx(() {
      if (poemController.isLoading.value) {
        return _buildLoadingState(context, 'نظمیں لوڈ ہو رہی ہیں...');
      }

      final favoritePoems = poemController.poems.where((poem) => poemController.isFavorite(poem)).toList();

      if (favoritePoems.isEmpty) {
        return _buildEmptyState(
                context,
          icon: Icons.favorite_outline,
          title: 'کوئی پسندیدہ نظم نہیں',
          subtitle: 'نظموں کو پسندیدہ میں شامل کرنے کے لیے\nانہیں لمبے دبائے دبائیں',
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await poemController.loadAllPoems();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final poem = favoritePoems[index];
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                      child: PoemCard(
                        title: poem.title,
                        poem: poem,
                               ),
                      ),
                    ),
                  );
                },
              );
                  },
                  childCount: favoritePoems.length,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingState(BuildContext context, String message) {
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
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                  theme.colorScheme.secondary.withValues(alpha: 0.6),
                ],
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
            message,
            style: AppTextStyles.getBodyStyle(context).copyWith(
              fontSize: 16.sp,
              fontFamily: 'JameelNooriNastaleeq',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(60.r),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 60.w,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
            ),
            SizedBox(height: 32.h),
            Text(
              title,
              style: AppTextStyles.getTitleStyle(
                context,
                isUrdu: true,
                isLarge: true,
              ).copyWith(
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              subtitle,
              style: AppTextStyles.getBodyStyle(context).copyWith(
                fontSize: 16.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.6,
                fontFamily: 'JameelNooriNastaleeq',
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16.w,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'مدد: لمبا دبانا = پسندیدہ میں شامل',
                    style: TextStyle(
                      fontFamily: 'JameelNooriNastaleeq',
                      fontSize: 13.sp,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
