import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../poems/controllers/poem_controller.dart';


class RandomPoemButton extends StatefulWidget {
  const RandomPoemButton({super.key});

  @override
  State<RandomPoemButton> createState() => _RandomPoemButtonState();
}

class _RandomPoemButtonState extends State<RandomPoemButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _pressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _pressAnimation;
  late Animation<double> _iconRotation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for ambient effect
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Press animation for interaction feedback
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
    
    // Icon rotation animation
    _iconRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.elasticOut,
    ));
    
    // Start ambient pulse
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Press animation
    setState(() => _isPressed = true);
    await _pressController.forward();
    
    // Get controller and open random poem
    try {
      final poemController = Get.find<PoemController>();
      await poemController.openRandomPoem();
    } catch (e) {
      debugPrint('❌ Error accessing PoemController: $e');
      Get.snackbar(
        'Error',
        'Please wait for the app to finish loading',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
    
    // Reset animation
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      await _pressController.reverse();
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _pressAnimation, _iconRotation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value * _pressAnimation.value,
          child: GestureDetector(
            onTap: _handleTap,
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _pressController.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _pressController.reverse();
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _pressController.reverse();
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.42,
              height: 120.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isPressed 
                    ? [
                        theme.colorScheme.primary.withOpacity(0.8),
                        theme.colorScheme.primary.withOpacity(0.6),
                      ]
                    : [
                        theme.colorScheme.primary.withOpacity(0.1),
                        theme.colorScheme.primary.withOpacity(0.05),
                      ],
                ),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  // Ambient shadow
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  // Inner glow effect
                  BoxShadow(
                    color: _isPressed
                        ? theme.colorScheme.primary.withOpacity(0.3)
                        : Colors.white.withOpacity(isDark ? 0.05 : 0.8),
                    blurRadius: _isPressed ? 8 : 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: Stack(
                  children: [
                    // Glassmorphism backdrop
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(isDark ? 0.1 : 0.7),
                              Colors.white.withOpacity(isDark ? 0.05 : 0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Content
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated icon
                            Transform.rotate(
                              angle: _iconRotation.value * 0.1,
                              child: Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withOpacity(0.7),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.shuffle_rounded,
                                  color: Colors.white,
                                  size: 20.w,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 12.h),
                            
                            // Text
                            Text(
                              'Random\nPoem',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                                letterSpacing: 0.5,
                              ),
                            ),
                            
                            SizedBox(height: 4.h),
                            
                            // Subtitle
                            Text(
                              'Discover poetry',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 11.sp,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Shine effect
                    if (_isPressed)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.r),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 