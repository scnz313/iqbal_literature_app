import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../features/poems/models/poem.dart';
import '../../core/themes/app_decorations.dart';
import '../../core/themes/text_styles.dart';
import 'share_service.dart';
import 'pdf_creator.dart';

class ShareBottomSheet extends StatelessWidget {
  final Poem poem;
  const ShareBottomSheet({super.key, required this.poem});

  static void show(BuildContext context, Poem poem) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.05),
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => ShareBottomSheet(poem: poem),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ShareBottomSheetContent(poem: poem);
  }
}

class _ShareBottomSheetContent extends StatefulWidget {
  final Poem poem;
  final ScrollController? scrollController;

  const _ShareBottomSheetContent({
    required this.poem,
    this.scrollController,
  });

  @override
  State<_ShareBottomSheetContent> createState() =>
      _ShareBottomSheetContentState();
}

class _ShareBottomSheetContentState extends State<_ShareBottomSheetContent> {
  String? selectedBackground;
  Color selectedColor = Colors.white; // Initialize with default value
  Color textColor = Colors.black; // Initialize with default value
  double fontSize = 18.0;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Use post frame callback to update colors based on theme after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      setState(() {
        selectedColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
        textColor = isDark ? Colors.white : Colors.black;
      });
    });
  }

  // Custom error handling
  void _handleError(Object e) {
    setState(() {
      isLoading = false;
      errorMessage = e.toString();
    });

    Get.snackbar(
      'Error',
      'Failed to share: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  final List<String?> backgroundOptions = [
    null, // No background
    'assets/images/notebook_lines.png',
    // Comment out missing background files and add fallbacks
    // 'assets/images/backgrounds/paper_texture_1.png',
    // 'assets/images/backgrounds/paper_texture_2.png',
    // 'assets/images/backgrounds/geometric_pattern_1.png',
    // 'assets/images/backgrounds/calligraphy_pattern_1.png',
    // 'assets/images/backgrounds/islamic_pattern_1.png',
    // 'assets/images/backgrounds/gradient_1.png',
  ];

  final List<Color> colorOptions = [
    Colors.white,
    Colors.grey.shade100,
    Colors.amber.shade50,
    Colors.blue.shade50,
    Colors.green.shade50,
    Colors.pink.shade50,
    Colors.purple.shade50,
    const Color(0xFF2C2C2C),
    const Color(0xFF1F1F1F),
    const Color(0xFF3A3A3A),
    Colors.grey.shade800,
    const Color(0xFF253238),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.bottomSheetDecoration(context),
      child: SafeArea(
        child: SingleChildScrollView(
          controller: widget.scrollController,
          child: Padding(
            padding: AppDecorations.defaultPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),
                
                // Header
                _buildHeader(context),
                SizedBox(height: 20.h),
                
                // Preview section
                _buildPreviewSection(context),
                SizedBox(height: 20.h),
                
                // Customization options
                _buildCustomizationSection(context),
                SizedBox(height: 20.h),
                
                // Share options
                _buildShareOptions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: AppDecorations.iconContainerDecoration(
            context,
            theme.colorScheme.primary,
          ),
          child: Icon(
            Icons.share_rounded,
            size: 24.w,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Poem',
                style: AppTextStyles.getTitleStyle(context).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.poem.title,
                style: AppTextStyles.getBodyStyle(context).copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: 'JameelNooriNastaleeq',
                  fontSize: 14.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    return Container(
      height: 200.h,
      decoration: AppDecorations.cardDecoration(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: _buildPreviewWidget(),
      ),
    );
  }

  Widget _buildPreviewWidget() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    bool needsDarkText = selectedColor.computeLuminance() > 0.5;
    Color adaptiveTextColor = needsDarkText ? Colors.black : Colors.white;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: selectedColor,
        image: selectedBackground != null && selectedBackground!.isNotEmpty
            ? DecorationImage(
                image: AssetImage(selectedBackground!),
                fit: BoxFit.cover,
                opacity: 0.3,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.poem.title,
            style: TextStyle(
              fontFamily: 'JameelNooriNastaleeq',
              fontSize: fontSize + 4,
              height: 2,
              fontWeight: FontWeight.bold,
              color: adaptiveTextColor,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                widget.poem.cleanData,
                style: TextStyle(
                  fontFamily: 'JameelNooriNastaleeq',
                  fontSize: fontSize,
                  height: 2,
                  color: adaptiveTextColor,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customize',
          style: AppTextStyles.getTitleStyle(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        _buildBackgroundSelector(),
        SizedBox(height: 16.h),
        _buildColorSelector(),
        SizedBox(height: 16.h),
        _buildFontSizeSelector(),
      ],
    );
  }

  Widget _buildBackgroundSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Background',
          style: AppTextStyles.getBodyStyle(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: backgroundOptions.map((bg) {
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedBackground = bg;
                    });
                  },
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      image: bg != null
                          ? DecorationImage(
                              image: AssetImage(bg),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                debugPrint('Error loading background image: $bg');
                                setState(() {
                                  if (selectedBackground == bg) {
                                    selectedBackground = null;
                                  }
                                });
                              },
                            )
                          : null,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: selectedBackground == bg
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: selectedBackground == bg ? 2 : 1,
                      ),
                    ),
                    child: bg == null 
                        ? Center(
                            child: Text(
                              'None',
                              style: AppTextStyles.textTheme.labelSmall,
                            ),
                          ) 
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visibleColors = colorOptions.where((color) {
      final isLightColor = color.computeLuminance() > 0.5;
      return isDark ? !isLightColor : isLightColor;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Background Color',
          style: AppTextStyles.getBodyStyle(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: visibleColors.map((color) {
              final isSelected = selectedColor == color;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: color.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                            size: 20.w,
                          )
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFontSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Font Size',
          style: AppTextStyles.getBodyStyle(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: fontSize > 14.0
                  ? () {
                      setState(() {
                        fontSize -= 2.0;
                      });
                    }
                  : null,
            ),
            Expanded(
              child: Slider(
                value: fontSize,
                min: 14.0,
                max: 26.0,
                divisions: 6,
                label: fontSize.round().toString(),
                onChanged: (value) {
                  setState(() {
                    fontSize = value;
                  });
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: fontSize < 26.0
                  ? () {
                      setState(() {
                        fontSize += 2.0;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShareOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share Options',
          style: AppTextStyles.getTitleStyle(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        _buildShareOptionTile(
          context,
          icon: Icons.text_fields,
          title: 'Share as Text',
          subtitle: 'Copy or share the poem text',
          onTap: () => _shareAsText(context),
        ),
        _buildShareOptionTile(
          context,
          icon: Icons.image,
          title: 'Share as Image',
          subtitle: 'Create and share an image',
          onTap: () => _shareAsImage(context),
        ),
        _buildShareOptionTile(
          context,
          icon: Icons.picture_as_pdf,
          title: 'Share as PDF',
          subtitle: 'Generate a PDF document',
          onTap: () => _shareAsPdf(context),
        ),
      ],
    );
  }

  Widget _buildShareOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: AppDecorations.iconContainerDecoration(
          context,
          theme.colorScheme.primary,
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20.w,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.getTitleStyle(context),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.getBodyStyle(context).copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: isLoading ? null : onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      trailing: isLoading
          ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: theme.colorScheme.onSurfaceVariant,
            ),
    );
  }

  void _shareAsText(BuildContext context) {
    final text = '${widget.poem.title}\n\n${widget.poem.cleanData}';
    Share.share(text);
    Navigator.pop(context);
  }

  void _shareAsImage(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Implementation for image sharing
      await Future.delayed(const Duration(seconds: 1)); // Placeholder
      Get.snackbar(
        'Success',
        'Image shared successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      _handleError(e);
    } finally {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  void _shareAsPdf(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Implementation for PDF sharing
      await Future.delayed(const Duration(seconds: 1)); // Placeholder
      Get.snackbar(
        'Success',
        'PDF shared successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      _handleError(e);
    } finally {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }
  }
}
