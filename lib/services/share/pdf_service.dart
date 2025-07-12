import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

/// Robust PDF generation service for Iqbal Literature app
/// Uses Canvas-based rendering to ensure proper Urdu text display
class PdfService {
  // PDF page dimensions (A4 size)
  static const double pageWidth = 595; // A4 width in points
  static const double pageHeight = 842; // A4 height in points
  static const double margin = 40;
  static const double contentWidth = pageWidth - (margin * 2);
  static const double contentHeight = pageHeight - (margin * 2);

  // Text styling constants optimized for Urdu
  static const double titleFontSize = 24;
  static const double contentFontSize = 16;
  static const double footerFontSize = 10;
  static const double lineHeight = 1.8; // Reduced for more natural spacing
  static const String fontFamily = 'JameelNooriNastaleeq';

  // Add a scale factor for high-resolution rendering
  static const double _imageScaleFactor = 4; // 3x scaling for ~216 DPI

  /// Generate and share PDF from poem content
  static Future<void> generateAndSharePdf({
    required String title,
    required String content,
    required BuildContext context,
  }) async {
    try {
      debugPrint('[PDF] Starting PDF generation for: $title');

      // Generate PDF bytes
      final pdfBytes = await _generatePdfBytes(title, content);

      // Create temporary file with proper filename
      final tempFile = await _createTempFile(title, pdfBytes);

      debugPrint('[PDF] PDF saved to: ${tempFile.path}');

      // Share the PDF
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Sharing poem: $title',
      );

      debugPrint('[PDF] PDF shared successfully');
    } catch (e, stackTrace) {
      debugPrint('[PDF] Error in generateAndSharePdf: $e');
      debugPrint('[PDF] Stack trace: $stackTrace');
      
      // Show error to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  /// Generate PDF bytes from content
  static Future<Uint8List> _generatePdfBytes(String title, String content) async {
    final pdf = pw.Document();

    // Split content into pages
    final pages = _splitContentIntoPages(title, content);
    
    debugPrint('[PDF] Creating ${pages.length} page(s)');

    for (int i = 0; i < pages.length; i++) {
      final pageData = pages[i];
      final pageImage = await _renderPageToImage(pageData, i + 1, pages.length);
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pw.MemoryImage(pageImage)),
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  /// Split content into logical pages using accurate height measurements
  static List<PageData> _splitContentIntoPages(String title, String content) {
    final pages = <PageData>[];
    final lines = content.split('\n');
    int currentIndex = 0;
    int pageNumber = 1;

    // Calculate title height if present
    double titleHeight = 0;
    if (pageNumber == 1 && title.isNotEmpty) {
      final titlePainter = TextPainter(
        text: TextSpan(
          text: title,
          style: const TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      );
      titlePainter.layout(maxWidth: contentWidth);
      titleHeight = titlePainter.height + 40; // Spacing after title
    }

    while (currentIndex < lines.length) {
      double currentHeight = (pageNumber == 1) ? titleHeight : 40; // Top margin for subsequent pages
      int endIndex = currentIndex;

      for (int i = currentIndex; i < lines.length; i++) {
        final line = lines[i];
        double lineHeightAddition;

        if (line.trim().isEmpty) {
          lineHeightAddition = contentFontSize * 1.0; // Space for empty lines
        } else {
          final linePainter = TextPainter(
            text: TextSpan(
              text: line,
              style: const TextStyle(
                fontSize: contentFontSize,
                height: lineHeight,
                fontFamily: fontFamily,
              ),
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center, // Center align for measurement
          );
          linePainter.layout(maxWidth: contentWidth);
          lineHeightAddition = linePainter.height + (contentFontSize * 0.2); // Inter-line spacing
        }

        if (currentHeight + lineHeightAddition > contentHeight - 60) { // Reserve space for footer
          break;
        }

        currentHeight += lineHeightAddition;
        endIndex = i + 1;
      }

      // Prevent infinite loop if a single line is too long
      if (endIndex == currentIndex) {
        endIndex = currentIndex + 1;
      }

      final pageLines = lines.sublist(currentIndex, endIndex);
      final pageContent = pageLines.join('\n');

      pages.add(PageData(
        title: (pageNumber == 1) ? title : '',
        content: pageContent,
        pageNumber: pageNumber,
        isFirstPage: pageNumber == 1,
      ));

      currentIndex = endIndex;
      pageNumber++;
    }

    return pages;
  }

  /// Render a single page to image using Canvas
  static Future<Uint8List> _renderPageToImage(
    PageData pageData,
    int pageNumber,
    int totalPages,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Increase resolution by scaling the entire canvas
    canvas.scale(_imageScaleFactor);

    // Fill background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, pageWidth, pageHeight),
      Paint()..color = Colors.white,
    );

    double yOffset = margin;

    // Draw title (only on first page)
    if (pageData.title.isNotEmpty && pageData.isFirstPage) {
      yOffset = await _drawTitle(canvas, pageData.title, yOffset);
    }

    // Draw content (now center aligned)
    yOffset = await _drawContent(canvas, pageData.content, yOffset);

    // Draw footer
    await _drawFooter(canvas, pageNumber, totalPages);

    // Convert to high-res image
    final picture = recorder.endRecording();
    final img = await picture.toImage(
      (pageWidth * _imageScaleFactor).toInt(),
      (pageHeight * _imageScaleFactor).toInt(),
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    // Cleanup
    picture.dispose();
    img.dispose();

    if (byteData == null) {
      throw Exception('Failed to convert page to image');
    }

    return byteData.buffer.asUint8List();
  }

  /// Draw title section - minimalistic version without decorations
  static Future<double> _drawTitle(Canvas canvas, String title, double yOffset) async {
    if (title.isEmpty) return yOffset;

    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: fontFamily,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );

    titlePainter.layout(maxWidth: contentWidth);
    final titleX = margin + (contentWidth - titlePainter.width) / 2;
    titlePainter.paint(canvas, Offset(titleX, yOffset));

    return yOffset + titlePainter.height + 40; // Clean spacing after title
  }

  /// Draw content section - with adjusted alignment and spacing
  static Future<double> _drawContent(Canvas canvas, String content, double yOffset) async {
    final lines = content.split('\n');
    double currentY = yOffset;

    for (final line in lines) {
      if (line.trim().isEmpty) {
        currentY += contentFontSize * 1.0;
        continue;
      }

      final linePainter = TextPainter(
        text: TextSpan(
          text: line,
          style: const TextStyle(
            fontSize: contentFontSize,
            height: lineHeight,
            color: Colors.black,
            fontFamily: fontFamily,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center, // Center alignment
      );

      linePainter.layout(maxWidth: contentWidth);

      // Center horizontally within content area
      final contentX = margin + (contentWidth - linePainter.width) / 2;
      linePainter.paint(canvas, Offset(contentX, currentY));

      currentY += linePainter.height + (contentFontSize * 0.2);
    }

    return currentY;
  }

  /// Draw footer with page information - minimalistic version
  static Future<void> _drawFooter(Canvas canvas, int pageNumber, int totalPages) async {
    final footerY = pageHeight - margin - footerFontSize;

    // Page number in Urdu (right side)
    final pageNumberPainter = TextPainter(
      text: TextSpan(
        text: 'صفحہ $pageNumber از $totalPages',
        style: const TextStyle(
          fontSize: footerFontSize,
          color: Colors.grey,
          fontFamily: fontFamily,
        ),
      ),
      textDirection: TextDirection.rtl,
    );
    pageNumberPainter.layout();
    final pageNumberX = pageWidth - margin - pageNumberPainter.width;
    pageNumberPainter.paint(canvas, Offset(pageNumberX, footerY));

    // App name (left side)
    final appNamePainter = TextPainter(
      text: const TextSpan(
        text: 'Iqbal Literature App',
        style: TextStyle(
          fontSize: footerFontSize,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    appNamePainter.layout();
    appNamePainter.paint(canvas, Offset(margin, footerY));
  }

  /// Create temporary file with proper filename
  static Future<File> _createTempFile(String title, Uint8List pdfBytes) async {
    final tempDir = await getTemporaryDirectory();
    
    // Clean title for filename
    final cleanTitle = _sanitizeFilename(title);
    final filename = '${cleanTitle.isNotEmpty ? cleanTitle : 'Iqbal_Poem'}.pdf';
    
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(pdfBytes);
    
    return file;
  }

  /// Sanitize string for use as filename
  static String _sanitizeFilename(String input) {
    if (input.trim().isEmpty) return '';
    
    return input
        .trim()
        .replaceAll(RegExp(r'[^\w\u0600-\u06FF\s-]'), '') // Keep Urdu, English, spaces, hyphens
        .replaceAll(RegExp(r'\s+'), '_') // Replace spaces with underscores
        .substring(0, input.length > 50 ? 50 : input.length); // Limit length
  }
}

/// Data class for page information
class PageData {
  final String title;
  final String content;
  final int pageNumber;
  final bool isFirstPage;

  const PageData({
    required this.title,
    required this.content,
    required this.pageNumber,
    required this.isFirstPage,
  });
} 