import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              SizedBox(height: 8.h),
              
              // Header
              _buildHeader(context, theme),
              SizedBox(height: 24.h),

              // Theme Settings
              _buildThemeSection(context, theme),
              SizedBox(height: 16.h),

              // Language Settings
              _buildLanguageSection(context, theme),
              SizedBox(height: 16.h),

              // About & Info
              _buildAboutSection(context, theme),
              SizedBox(height: 16.h),

              // Developer Info
              _buildDeveloperSection(context, theme),
              SizedBox(height: 24.h),
              
              // Made with love in Kashmir - moved to bottom
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Text(
                    'Made with ❤️ in Kashmir',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontFamily: 'Georgia', // Better serif font
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
                  children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.settings_rounded,
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
                'Settings',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Customize your experience',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
                      ),
                    ],
                  );
  }

  Widget _buildThemeSection(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                size: 20.w,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 12.w),
                Text(
                'Theme',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Choose your preferred appearance',
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.hintColor,
            ),
          ),
          SizedBox(height: 16.h),
          Obx(() => Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _buildThemeChip(context, theme, 'System', 'system', Icons.phone_android_rounded),
                  _buildThemeChip(context, theme, 'Light', 'light', Icons.wb_sunny_rounded),
                  _buildThemeChip(context, theme, 'Dark', 'dark', Icons.nights_stay_rounded),
                  _buildThemeChip(context, theme, 'Sepia', 'sepia', Icons.auto_stories_rounded),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildThemeChip(BuildContext context, ThemeData theme, String label, String value, IconData icon) {
    final isSelected = controller.currentTheme.value == value;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        controller.changeTheme(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary
                : theme.dividerColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
            Icon(
              icon,
              size: 16.w,
              color: isSelected 
                  ? theme.colorScheme.onPrimary
                  : theme.textTheme.bodyMedium?.color,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? theme.colorScheme.onPrimary
                    : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.language_rounded,
                size: 20.w,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 12.w),
              Text(
                'Language',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Select your preferred language',
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.hintColor,
            ),
          ),
          SizedBox(height: 16.h),
          Obx(() => Column(
                children: [
                  _buildLanguageOption(context, theme, '🇺🇸', 'English', 'en'),
                  SizedBox(height: 8.h),
                  _buildLanguageOption(context, theme, '🇵🇰', 'اردو', 'ur'),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, ThemeData theme, String flag, String name, String code) {
    final isSelected = controller.currentLanguage.value == code;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        controller.changeLanguage(code);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodyMedium?.color,
                  fontFamily: code == 'ur' ? 'JameelNooriNastaleeq' : null,
                ),
                textDirection: code == 'ur' ? TextDirection.rtl : TextDirection.ltr,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: 20.w,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20.w,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 12.w),
              Text(
                'About',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'App information and details',
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.hintColor,
            ),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(context, theme, 'Version', '${controller.appVersion}'),
          SizedBox(height: 12.h),
          _buildActionButton(
            context, 
            theme, 
            'View Details', 
            Icons.arrow_forward_ios_rounded,
            () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: theme.hintColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: theme.textTheme.bodyMedium?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, ThemeData theme, String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            Icon(
              icon,
              size: 16.w,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperSection(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 20.w,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 12.w),
              Text(
                'Developer',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.titleMedium?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 24.w,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hashim Hameem',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.titleSmall?.color,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Full Stack Developer',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Contact Links Section
          Text(
            'Connect & Support',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.titleSmall?.color,
            ),
          ),
          SizedBox(height: 12.h),
          
          // Contact Links Row
          Row(
            children: [
              Expanded(
                child: _buildContactChip(context, theme, Icons.code_rounded, 'GitHub', () {
                  _launchURL('https://github.com/HASHIM-HAMEEM');
                }),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildContactChip(context, theme, Icons.alternate_email_rounded, 'Twitter', () {
                  _launchURL('https://twitter.com/HashimScnz');
                }),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildContactChip(context, theme, Icons.support_agent_rounded, 'Support', () {
                  _launchURL('mailto:hashimdar141@yahoo.com?subject=Iqbal Literature App Support&body=Hi Hashim,\n\nI need support with the Iqbal Literature app:\n\n');
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactChip(BuildContext context, ThemeData theme, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.w,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreButton(BuildContext context, ThemeData theme, String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14.w,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 400.w,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      size: 32.w,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Iqbal Literature',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                          Text(
                            'Version ${controller.appVersion}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        size: 24.w,
                        color: theme.hintColor,
                      ),
          ),
        ],
      ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                      // Quote
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'آج کیوں سینے ہمارے شرر آباد نہیں\nہم وہی سوختہ سامان ہیں، تجھے یاد نہیں؟',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'JameelNooriNastaleeq',
                            color: theme.textTheme.bodyLarge?.color,
                            height: 1.8,
                          ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      
                      // About Text
                      Text(
                        'About This App',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'This app is a digital tribute to Allama Iqbal\'s wisdom, designed to make his revolutionary teachings accessible to modern seekers. Explore his poetry, reflect on his philosophical insights, and discover how to embody his ideals in today\'s world.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: theme.textTheme.bodyMedium?.color,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      
                      // Features
                      Text(
                        'Features',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '• Complete collection of Iqbal\'s poetry\n'
                        '• AI-powered text analysis\n'
                        '• Historical context and commentary\n'
                        '• Search and favorites functionality\n'
                        '• Multiple themes and languages',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: theme.textTheme.bodyMedium?.color,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // Rate & Review Section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 16.w,
                                  color: theme.colorScheme.primary,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Rate & Review',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                            SizedBox(height: 8.h),
                            Text(
                              'Help others discover this app by leaving a review on the Play Store',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: theme.hintColor,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            _buildStoreButton(
                              context, 
                              theme, 
                              'Rate on Play Store', 
                              Icons.android_rounded,
                              () {
                                _launchURL('https://play.google.com/store/apps/details?id=com.iqbalbook.iqbal_literature');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    try {
      if (await canLaunchUrlString(urlString)) {
        await launchUrlString(urlString);
      } else {
        Get.snackbar(
          'Error',
          'Could not open link',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open link',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
