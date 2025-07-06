import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/home_controller.dart';
import '../../books/screens/books_screen.dart';
import '../../poems/screens/poems_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../core/utils/responsive_utils.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header with search and bookmark
            _buildCustomHeader(context),
            // Tab Content
            Expanded(
              child: Obx(() => IndexedStack(
                    index: controller.currentIndex.value,
                    children: const [
                      BooksScreen(),
                      PoemsScreen(),
                      SearchScreen(),
                      SettingsScreen(),
                    ],
                  )),
            ),
          ],
        ),
      ),
      // Modern floating bottom navigation
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.responsivePadding.left,
        context.responsiveSpacing,
        context.responsivePadding.right,
        context.responsiveSpacing * 1.25,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: ResponsiveUtils.getResponsiveElevation(context, baseElevation: 10),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with greeting and bookmark
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bookmark button (left side)
              Obx(() {
                final currentIndex = controller.currentIndex.value;
                if (currentIndex == 0 || currentIndex == 1) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.bookmark_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: ResponsiveUtils.getIconSize(context, baseSize: 24),
                      ),
                      onPressed: () => Get.toNamed('/favorites'),
                      tooltip: 'Bookmarks',
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              SizedBox(width: context.responsiveSpacing * 0.75),
              // Greeting and title
              Expanded(
                child: Obx(() {
                  final idx = controller.currentIndex.value;
                  if (idx == 0) {
                    // Greeting already handled above
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'خوش آمدید',
                          style: TextStyle(
                            fontFamily: 'JameelNooriNastaleeq',
                            fontSize: (16 * context.fontSizeMultiplier).sp,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            height: 1.5,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'علامہ محمد اقبال کا ادبی خزانہ',
                          style: TextStyle(
                            fontFamily: 'JameelNooriNastaleeq',
                            fontSize: (24 * context.fontSizeMultiplier).sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.4,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    );
                  }

                  String title;
                  switch (idx) {
                    case 1:
                      title = 'تمام نظمیں (${controller.poems.length})';
                      break;
                    case 2:
                      title = 'تلاش';
                      break;
                    case 3:
                    default:
                      title = 'Settings';
                  }

                  return Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: idx == 3 ? null : 'JameelNooriNastaleeq',
                        fontSize: (20 * context.fontSizeMultiplier).sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: context.responsiveSpacing * 0.5),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final navHeight = context.responsiveListItemHeight * 0.9;
    
    return Container(
      margin: EdgeInsets.fromLTRB(
        context.responsiveSpacing * 1.25,
        0,
        context.responsiveSpacing * 1.25,
        context.responsiveSpacing * 1.25,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: ResponsiveUtils.getResponsiveElevation(context, baseElevation: 20),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 24),
        child: Obx(() => NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: navHeight,
              selectedIndex: controller.currentIndex.value,
              onDestinationSelected: controller.changePage,
              indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              destinations: [
                NavigationDestination(
                  icon: Icon(
                    Icons.book_outlined,
                    size: ResponsiveUtils.getIconSize(context, baseSize: 24),
                    color: controller.currentIndex.value == 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  selectedIcon: Icon(
                    Icons.book,
                    size: ResponsiveUtils.getIconSize(context, baseSize: 24),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: 'کتابیں',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.auto_stories_outlined,
                    size: ResponsiveUtils.getIconSize(context, baseSize: 24),
                    color: controller.currentIndex.value == 1
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  selectedIcon: Icon(
                    Icons.auto_stories,
                    size: ResponsiveUtils.getIconSize(context, baseSize: 24),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: 'نظم',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.search_outlined,
                    size: ResponsiveUtils.getIconSize(context, baseSize: 24),
                    color: controller.currentIndex.value == 2
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  selectedIcon: Icon(
                    Icons.search,
                    size: ResponsiveUtils.getIconSize(context, baseSize: 24),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: 'تلاش',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.settings_outlined,
                    size: ResponsiveUtils.getIconSize(context, baseSize: 24),
                    color: controller.currentIndex.value == 3
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  selectedIcon: Icon(
                    Icons.settings,
                    size: ResponsiveUtils.getIconSize(context, baseSize: 24),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: 'ترتیبات',
                ),
              ],
            )),
      ),
    );
  }
}
