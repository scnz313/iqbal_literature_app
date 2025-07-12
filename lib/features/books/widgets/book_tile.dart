import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/book_controller.dart';
import '../../../data/models/book/book.dart';


class BookTile extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final bool isGridView;
  final bool showStats;

  const BookTile({
    super.key,
    required this.book,
    this.onTap,
    this.isGridView = false,
    this.showStats = true,
  });

  @override
  Widget build(BuildContext context) {
    return isGridView ? _buildGridTile(context) : _buildListTile(context);
  }

  Widget _buildListTile(BuildContext context) {
    final theme = Theme.of(context);
    final isUrdu = book.name.contains(RegExp(r'[\u0600-\u06FF]'));

    return GestureDetector(
      onTap: () => _handleTap(context),
      onLongPress: () => _showBookOptions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Simple book icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.book_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Book info
            Expanded(
              child: Column(
                crossAxisAlignment: isUrdu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Book name
                  Text(
                    book.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      fontFamily: isUrdu ? 'JameelNooriNastaleeq' : null,
                      height: isUrdu ? 1.8 : 1.4,
                    ),
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Language and time period
                  Row(
                    mainAxisAlignment: isUrdu ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      // Language badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          book.language,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      // Time period (if available)
                      if (book.timePeriod != null && book.timePeriod!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${book.timePeriod}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Simple arrow
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridTile(BuildContext context) {
    final theme = Theme.of(context);
    final isUrdu = book.name.contains(RegExp(r'[\u0600-\u06FF]'));

    return GestureDetector(
      onTap: () => _handleTap(context),
      onLongPress: () => _showBookOptions(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Book icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.book_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            
            // Book name
            Text(
              book.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                fontFamily: isUrdu ? 'JameelNooriNastaleeq' : null,
                height: isUrdu ? 1.8 : 1.4,
              ),
              textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            
            // Language
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                book.language,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    HapticFeedback.lightImpact();
    if (onTap != null) {
      onTap!();
    } else {
      Get.toNamed('/book-poems', arguments: {
        'book': book,
        'book_id': book.id,
        'book_name': book.name,
        'view_type': 'book_specific',
      });
    }
  }

  void _showBookOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
      ),
      child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modern handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 24.h),
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              
              // Book info header with modern design
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                children: [
                  Container(
                      width: 52.w,
                      height: 52.w,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                    ),
                    child: Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                        size: 26.w,
                    ),
                  ),
                    SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          book.name,
                          style: TextStyle(
                              fontFamily: 'JameelNooriNastaleeq',
                              fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.4,
                          ),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                        ),
                          SizedBox(height: 4.h),
                        Text(
                          book.language,
                          style: TextStyle(
                              fontFamily: 'JameelNooriNastaleeq',
                              fontSize: 14.sp,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              height: 1.3,
                          ),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ),
              
              SizedBox(height: 24.h),
              
              // Modern option tiles
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Obx(() {
                      final bookController = Get.find<BookController>();
                      final isFavorite = bookController.isFavorite(book);
                      return _buildModernOptionTile(
                        context,
                        icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                        urduTitle: isFavorite ? 'پسندیدگی سے ہٹائیں' : 'پسندیدہ میں شامل کریں',
                        englishTitle: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                        urduSubtitle: isFavorite ? 'اپنی پسندیدگی سے کتاب ہٹائیں' : 'اپنی پسندیدگی میں محفوظ کریں',
                        englishSubtitle: isFavorite ? 'Remove from your favorites' : 'Save to your favorites',
                        iconColor: isFavorite ? Colors.red : null,
                        onTap: () {
                          Navigator.pop(context);
                          bookController.toggleFavorite(book);
                        },
                      );
                    }),
                    
                    SizedBox(height: 8.h),
                    
                    _buildModernOptionTile(
                context,
                      icon: Icons.auto_awesome_rounded,
                      urduTitle: 'روزانہ حکمت',
                      englishTitle: 'Daily Wisdom',
                      urduSubtitle: 'اس کتاب سے روزانہ کی حکمت حاصل کریں',
                      englishSubtitle: 'Get daily wisdom from this book',
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/daily-verse', arguments: {'book': book});
                },
              ),
                    
                    SizedBox(height: 8.h),
                    
                    _buildModernOptionTile(
                context,
                icon: Icons.timeline_rounded,
                      urduTitle: 'تاریخی ٹائم لائن',
                      englishTitle: 'Historical Timeline',
                      urduSubtitle: 'اس کتاب کا تاریخی پس منظر دیکھیں',
                      englishSubtitle: 'Explore the historical background',
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('/timeline', arguments: {
                    'book_name': book.name,
                    'book_id': book.id,
                    'time_period': null,
                  });
                },
              ),
                    
                    SizedBox(height: 8.h),
                    
                    _buildModernOptionTile(
                context,
                      icon: Icons.share_rounded,
                      urduTitle: 'شیئر کریں',
                      englishTitle: 'Share Book',
                      urduSubtitle: 'دوسروں کے ساتھ اس کتاب کو شیئر کریں',
                      englishSubtitle: 'Share this book with others',
                onTap: () {
                  Navigator.pop(context);
                        try {
                          final bookController = Get.find<BookController>();
                          bookController.shareBook(book);
                        } catch (e) {
                          final shareText = 'Check out this amazing book: "${book.name}" from Iqbal Literature App\n\nDownload the app to explore more of Allama Iqbal\'s timeless poetry and wisdom.';
                          Share.share(shareText, subject: book.name);
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: MediaQuery.of(context).padding.bottom + 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernOptionTile(
    BuildContext context, {
    required IconData icon,
    required String urduTitle,
    required String englishTitle,
    required String urduSubtitle,
    required String englishSubtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 22.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      englishTitle,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      urduSubtitle,
                      style: TextStyle(
                        fontFamily: 'JameelNooriNastaleeq',
                        fontSize: 13.sp,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                        height: 1.4,
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.w,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
