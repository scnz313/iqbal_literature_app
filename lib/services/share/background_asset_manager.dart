import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for lazy loading and caching background images
/// This reduces initial app bundle size by loading assets only when needed
class BackgroundAssetManager {
  static final BackgroundAssetManager _instance = BackgroundAssetManager._internal();
  factory BackgroundAssetManager() => _instance;
  BackgroundAssetManager._internal();

  // Cache for loaded images
  final Map<String, ui.Image> _imageCache = {};
  final Map<String, Future<ui.Image>> _loadingFutures = {};

  /// Background asset paths (now smaller, optimized versions)
  static const Map<String, String> _backgroundAssets = {
    'notebook_lines': 'assets/images/notebook_lines.png',
    'paper_texture_1': 'assets/images/backgrounds/paper_texture_1.png',
    'paper_texture_2': 'assets/images/backgrounds/paper_texture_2.png', 
    'paper_texture_3': 'assets/images/backgrounds/paper_texture_3.png',
    'geometric_pattern_2': 'assets/images/backgrounds/geometric_pattern_2.png',
    'islamic_pattern_2': 'assets/images/backgrounds/islamic_pattern_2.png',
    'gradient_1': 'assets/images/backgrounds/gradient_1.png',
  };

  /// Get available background options for UI
  static List<String?> get backgroundOptions => [
    null, // No background
    ...BackgroundAssetManager._backgroundAssets.keys,
  ];

  /// Get asset path from background key
  static String? getAssetPath(String? backgroundKey) {
    if (backgroundKey == null || backgroundKey.isEmpty) return null;
    return _backgroundAssets[backgroundKey];
  }

  /// Lazy load a background image
  Future<ui.Image?> loadBackgroundImage(String? backgroundKey) async {
    if (backgroundKey == null || backgroundKey.isEmpty) return null;
    
    final assetPath = _backgroundAssets[backgroundKey];
    if (assetPath == null) {
      debugPrint('⚠️ Background asset not found: $backgroundKey');
      return null;
    }

    // Return cached image if available
    if (_imageCache.containsKey(backgroundKey)) {
      return _imageCache[backgroundKey];
    }

    // Return ongoing future if already loading
    if (_loadingFutures.containsKey(backgroundKey)) {
      return _loadingFutures[backgroundKey];
    }

    // Start loading
    final loadingFuture = _loadImage(assetPath);
    _loadingFutures[backgroundKey] = loadingFuture;

    try {
      final image = await loadingFuture;
      _imageCache[backgroundKey] = image;
      _loadingFutures.remove(backgroundKey);
      debugPrint('✅ Background loaded: $backgroundKey');
      return image;
    } catch (e) {
      _loadingFutures.remove(backgroundKey);
      debugPrint('❌ Failed to load background $backgroundKey: $e');
      return null;
    }
  }

  /// Load image from asset path
  Future<ui.Image> _loadImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  /// Preload commonly used backgrounds
  Future<void> preloadCommonBackgrounds() async {
    final commonBackgrounds = ['paper_texture_1', 'notebook_lines'];
    
    for (final background in commonBackgrounds) {
      try {
        await loadBackgroundImage(background);
      } catch (e) {
        debugPrint('⚠️ Failed to preload $background: $e');
      }
    }
  }

  /// Clear cache to free memory
  void clearCache() {
    for (final image in _imageCache.values) {
      image.dispose();
    }
    _imageCache.clear();
    _loadingFutures.clear();
    debugPrint('🧹 Background image cache cleared');
  }

  /// Get memory usage of cached images
  int getCacheMemoryUsage() {
    int totalBytes = 0;
    for (final image in _imageCache.values) {
      totalBytes += image.width * image.height * 4; // 4 bytes per pixel (RGBA)
    }
    return totalBytes;
  }
} 