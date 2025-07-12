import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../historical_context/widgets/historical_context_sheet.dart';
import '../../../features/poems/models/poem.dart';
import '../controllers/poem_controller.dart';

class PoemCard extends StatelessWidget {
  final String title;
  final Poem poem;
  final bool isCompact;

  const PoemCard({
    super.key,
    required this.title,
    required this.poem,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUrdu = title.contains(RegExp(r'[\u0600-\u06FF]'));

    return GestureDetector(
      onTap: () => _navigateToPoem(context),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showOptions(context);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isCompact ? 8 : 12),
        padding: EdgeInsets.all(isCompact ? 16 : 20),
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
            // Simple poem icon
            Container(
              width: isCompact ? 40 : 48,
              height: isCompact ? 40 : 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.article_outlined,
                color: theme.colorScheme.secondary,
                size: isCompact ? 20 : 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Poem info
            Expanded(
              child: Column(
                crossAxisAlignment: isUrdu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Poem title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isCompact ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      fontFamily: isUrdu ? 'JameelNooriNastaleeq' : null,
                      height: isUrdu ? 1.8 : 1.4,
                    ),
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    maxLines: isCompact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Book info and metadata
                  Row(
                    mainAxisAlignment: isUrdu ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      // Book indicator
                      Icon(
                        Icons.book_outlined,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      
                      // Book name
                      Expanded(
                        child: FutureBuilder<String>(
                          future: Get.find<PoemController>().getBookName(poem.bookId),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? 'Loading...',
                              style: TextStyle(
                                fontSize: isCompact ? 11 : 12,
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                      
                      // Year (if available)
                      if (poem.year != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${poem.year}',
                          style: TextStyle(
                            fontSize: isCompact ? 10 : 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Historical context indicator (if available)
                  if (!isCompact && poem.historicalContext != null && poem.historicalContext!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: isUrdu ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.history_edu_outlined,
                          size: 12,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Historical context available',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
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

  void _navigateToPoem(BuildContext context) {
    HapticFeedback.lightImpact();
    Get.toNamed('/poem-detail', arguments: {
      'poem': poem,
      'title': title,
      'view_type': 'detail',
    });
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildOptionsBottomSheet(context),
    );
  }

  Widget _buildOptionsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isUrdu = title.contains(RegExp(r'[\u0600-\u06FF]'));
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Poem info
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.article_outlined,
                      color: theme.colorScheme.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: isUrdu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
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
                        const SizedBox(height: 4),
                        if (poem.year != null)
                          Text(
                            'Year: ${poem.year}',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Options
              _buildOptionTile(
                context,
                icon: Icons.auto_awesome_outlined,
                title: 'Analyze Poem',
                onTap: () {
                  Navigator.pop(context);
                  Get.find<PoemController>().showPoemAnalysis(poem.data);
                },
              ),
              
              if (poem.historicalContext != null && poem.historicalContext!.isNotEmpty)
                _buildOptionTile(
                  context,
                  icon: Icons.history_edu_outlined,
                  title: 'Historical Context',
                  onTap: () {
                    Navigator.pop(context);
                    _showHistoricalContext(context);
                  },
                ),
              
              if (poem.wikipediaUrl != null && poem.wikipediaUrl!.isNotEmpty)
                _buildOptionTile(
                  context,
                  icon: Icons.open_in_new_outlined,
                  title: 'Wikipedia',
                  onTap: () {
                    Navigator.pop(context);
                    _launchWikipedia();
                  },
                ),
              
              _buildOptionTile(
                context,
                icon: Icons.share_outlined,
                title: 'Share Poem',
                onTap: () {
                  Navigator.pop(context);
                  // Implement sharing
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _showHistoricalContext(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HistoricalContextSheet(
        poem: poem,
      ),
    );
  }

  void _launchWikipedia() async {
    final url = Uri.parse(poem.wikipediaUrl!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
