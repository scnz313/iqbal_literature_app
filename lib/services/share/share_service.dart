import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import '../../utils/screenshot_util.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:url_launcher/url_launcher.dart';


/// Helper class to find RenderRepaintBoundary in the render tree
class FindRenderObjectVisitor {
  RenderObject? foundObject;
}

class ShareService {
  static Future<void> shareAsText(String title, String content) async {
    try {
      final text = '$title\n\n$content\n\nShared via Iqbal Literature';
      await Share.share(text);
    } catch (e) {
      debugPrint('Error sharing text: $e');
      rethrow;
    }
  }

  static Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        final photos = await Permission.photos.status;
        if (photos.isDenied) {
          final result = await Permission.photos.request();
          if (!result.isGranted) {
            // Try requesting manage external storage as fallback
            final manageStorage = await Permission.manageExternalStorage.status;
            if (manageStorage.isDenied) {
              final manageResult =
                  await Permission.manageExternalStorage.request();
              return manageResult.isGranted;
            }
            return manageStorage.isGranted;
          }
          return result.isGranted;
        }
        return photos.isGranted;
      } else {
        final storage = await Permission.storage.status;
        if (storage.isDenied) {
          final result = await Permission.storage.request();
          if (!result.isGranted) {
            // Try requesting manage external storage as fallback
            final manageStorage = await Permission.manageExternalStorage.status;
            if (manageStorage.isDenied) {
              final manageResult =
                  await Permission.manageExternalStorage.request();
              return manageResult.isGranted;
            }
            return manageStorage.isGranted;
          }
          return result.isGranted;
        }
        return storage.isGranted;
      }
    }

    if (Platform.isIOS) {
      final photos = await Permission.photos.status;
      if (photos.isDenied) {
        final result = await Permission.photos.request();
        return result.isGranted;
      }
      return photos.isGranted;
    }

    return false;
  }

  static Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  static Future<void> shareAsImage(
    BuildContext context,
    GlobalKey previewKey,
    String filename, {
    bool showWatermark = true,
    String? backgroundImage,
    Color backgroundColor = Colors.white,
    double containerWidth = 800,
  }) async {
    try {
      // Check permissions first
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        throw Exception('Storage permission is required');
      }

      // Create a unique subfolder for sharing files
      final tempDir = await getTemporaryDirectory();
      final shareDir = Directory('${tempDir.path}/iqbal_shares');
      if (!await shareDir.exists()) {
        await shareDir.create(recursive: true);
      }

      // Clear old temporary files
      await _clearOldFiles(shareDir);

      // Generate a unique filename with timestamp to avoid conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFilename = '${filename}_$timestamp.png';
      final filePath = '${shareDir.path}/$uniqueFilename';

      // Capture widget to image using RepaintBoundary
      final boundary = previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Could not find repaint boundary in widget');
      }

      // Try to capture with different pixel ratios if necessary (fallback mechanism)
      Uint8List? pngBytes = await _captureWidgetWithFallback(boundary);
      if (pngBytes == null) {
        throw Exception('Failed to capture widget as image');
      }

      // Save image to file
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Share the file using share_plus
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Shared via Iqbal Literature',
        subject: 'Iqbal Literature Verse',
      );

      // Don't delete right away, as some share handlers may access the file after the share sheet is dismissed
      // File cleanup will happen on next run via _clearOldFiles
    } catch (e) {
      debugPrint('Error sharing image: $e');
      if (e.toString().contains('permission')) {
        _showPermissionErrorSnackbar(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share image: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
      }
    }
  }

  /// Share full content as image (for large poems)
  static Future<void> shareFullContentAsImage({
    required BuildContext context,
    required String title,
    required String content,
    required String filename,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black,
    String? backgroundImage,
  }) async {
    try {
      // Check permissions first
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        throw Exception('Storage permission is required');
      }

      debugPrint('[Image] Generating full content image for: $title');

      // Generate full content image
      final imageBytes = await _generateFullContentImage(
        title: title,
        content: content,
        backgroundColor: backgroundColor,
        textColor: textColor,
        backgroundImage: backgroundImage,
      );

      // Create temporary file
      final tempDir = await getTemporaryDirectory();
      final shareDir = Directory('${tempDir.path}/iqbal_shares');
      if (!await shareDir.exists()) {
        await shareDir.create(recursive: true);
      }

      await _clearOldFiles(shareDir);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFilename = '${filename}_$timestamp.png';
      final filePath = '${shareDir.path}/$uniqueFilename';

      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      debugPrint('[Image] Image saved to: $filePath');

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Sharing poem: $title',
        subject: 'Iqbal Literature Verse',
      );

      debugPrint('[Image] Image shared successfully');
    } catch (e) {
      debugPrint('[Image] Error in shareFullContentAsImage: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  /// Generate full content image using Canvas
  static Future<Uint8List> _generateFullContentImage({
    required String title,
    required String content,
    required Color backgroundColor,
    required Color textColor,
    String? backgroundImage,
  }) async {
    // Image dimensions (optimized for mobile sharing)
    const double imageWidth = 800;
    const double margin = 40;
    const double contentWidth = imageWidth - (margin * 2);
    
    // Calculate required height based on content
    final estimatedHeight = await _calculateRequiredHeight(
      title: title,
      content: content,
      contentWidth: contentWidth,
      margin: margin,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Fill background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, imageWidth, estimatedHeight),
      Paint()..color = backgroundColor,
    );

    // Draw background image if provided
    if (backgroundImage != null) {
      await _drawBackgroundImage(canvas, backgroundImage, imageWidth, estimatedHeight);
    }

    double yOffset = margin;

    // Draw title
    if (title.isNotEmpty) {
      yOffset = await _drawImageTitle(canvas, title, yOffset, contentWidth, textColor);
      yOffset += 20;
    }

    // Draw content
    await _drawImageContent(canvas, content, yOffset, contentWidth, textColor);

    // Draw footer
    await _drawImageFooter(canvas, imageWidth, estimatedHeight, textColor);

    // Convert to image
    final picture = recorder.endRecording();
    final image = await picture.toImage(imageWidth.toInt(), estimatedHeight.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    // Cleanup
    picture.dispose();
    image.dispose();

    if (byteData == null) {
      throw Exception('Failed to convert content to image');
    }

    return byteData.buffer.asUint8List();
  }

  static Future<double> _calculateRequiredHeight({
    required String title,
    required String content,
    required double contentWidth,
    required double margin,
  }) async {
    double height = margin * 2; // Top and bottom margins

    // Calculate title height
    if (title.isNotEmpty) {
      final titlePainter = TextPainter(
        text: TextSpan(
          text: title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'JameelNooriNastaleeq',
          ),
        ),
        textDirection: TextDirection.rtl,
      );
      titlePainter.layout(maxWidth: contentWidth);
      height += titlePainter.height + 40; // Title + spacing
    }

    // Calculate content height
    final contentPainter = TextPainter(
      text: TextSpan(
        text: content,
        style: const TextStyle(
          fontSize: 20,
          height: 2.2,
          fontFamily: 'JameelNooriNastaleeq',
        ),
      ),
      textDirection: TextDirection.rtl,
    );
    contentPainter.layout(maxWidth: contentWidth);
    height += contentPainter.height + 60; // Content + footer space

    return height;
  }

  static Future<double> _drawImageTitle(
    Canvas canvas,
    String title,
    double yOffset,
    double contentWidth,
    Color textColor,
  ) async {
    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'JameelNooriNastaleeq',
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );

    titlePainter.layout(maxWidth: contentWidth);
    
    // Center the title
    final titleX = 40 + (contentWidth - titlePainter.width) / 2;
    titlePainter.paint(canvas, Offset(titleX, yOffset));
    
    yOffset += titlePainter.height + 15;

    // Draw decorative line
    canvas.drawLine(
      Offset(60, yOffset),
      Offset(740, yOffset),
      Paint()
        ..color = textColor.withOpacity(0.6)
        ..strokeWidth = 2,
    );

    return yOffset + 20;
  }

  static Future<void> _drawImageContent(
    Canvas canvas,
    String content,
    double yOffset,
    double contentWidth,
    Color textColor,
  ) async {
    final contentPainter = TextPainter(
      text: TextSpan(
        text: content,
        style: TextStyle(
          fontSize: 20,
          height: 2.2,
          color: textColor,
          fontFamily: 'JameelNooriNastaleeq',
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
    );

    contentPainter.layout(maxWidth: contentWidth);
    
    // Right-align for Urdu text
    final contentX = 800 - 40 - contentPainter.width;
    contentPainter.paint(canvas, Offset(contentX, yOffset));
  }

  static Future<void> _drawImageFooter(
    Canvas canvas,
    double imageWidth,
    double imageHeight,
    Color textColor,
  ) async {
    final footerY = imageHeight - 25;

    final footerPainter = TextPainter(
      text: TextSpan(
        text: 'Iqbal Literature App',
        style: TextStyle(
          fontSize: 14,
          color: textColor.withOpacity(0.7),
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    footerPainter.layout();
    final footerX = (imageWidth - footerPainter.width) / 2;
    footerPainter.paint(canvas, Offset(footerX, footerY));
  }

  static Future<void> _drawBackgroundImage(
    Canvas canvas,
    String backgroundImage,
    double width,
    double height,
  ) async {
    // This would require loading the background image asset
    // For now, we'll just add a subtle pattern
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
  }

  static Future<Uint8List?> _captureWidgetWithFallback(
      RenderRepaintBoundary boundary,
      {List<double> pixelRatios = const [2.0, 1.5, 1.0]}) async {
    // Try with high resolution first, then fall back to lower resolutions
    for (final ratio in pixelRatios) {
      try {
        final ui.Image image = await boundary.toImage(pixelRatio: ratio);
        final ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          return byteData.buffer.asUint8List();
        }
      } catch (e) {
        debugPrint('Error capturing with pixel ratio $ratio: $e');
        // Continue to next pixel ratio
        continue;
      }
    }

    return null; // All attempts failed
  }

  static Future<void> _clearOldFiles(Directory dir) async {
    try {
      if (await dir.exists()) {
        final files = dir.listSync();
        final now = DateTime.now();
        for (var file in files) {
          if (file is File) {
            final stat = await file.stat();
            final age = now.difference(stat.modified);
            if (age.inHours > 24) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing old files: $e');
    }
  }

  static void _showPermissionErrorSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Storage permission is required to share files',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () {
            openAppSettings();
          },
        ),
      ),
    );
  }
}
