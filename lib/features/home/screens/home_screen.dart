import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../books/screens/books_screen.dart';
import '../../poems/screens/poems_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../settings/screens/settings_screen.dart';

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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.bookmark_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      onPressed: () => Get.toNamed('/favorites'),
                      tooltip: 'Bookmarks',
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(width: 12),
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
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            height: 1.5,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'علامہ محمد اقبال کا ادبی خزانہ',
                          style: TextStyle(
                            fontFamily: 'JameelNooriNastaleeq',
                            fontSize: 24,
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
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Obx(() => NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 70,
              selectedIndex: controller.currentIndex.value,
              onDestinationSelected: controller.changePage,
              indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              destinations: [
                NavigationDestination(
                  icon: Icon(
                    Icons.book_outlined,
                    size: 24,
                    color: controller.currentIndex.value == 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  selectedIcon: Icon(
                    Icons.book,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: 'کتابیں',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.auto_stories_outlined,
                    size: 24,
                    color: controller.currentIndex.value == 1
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  selectedIcon: Icon(
                    Icons.auto_stories,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: 'نظم',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.search_outlined,
                    size: 24,
                    color: controller.currentIndex.value == 2
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  selectedIcon: Icon(
                    Icons.search,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: 'تلاش',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.settings_outlined,
                    size: 24,
                    color: controller.currentIndex.value == 3
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  selectedIcon: Icon(
                    Icons.settings,
                    size: 24,
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
