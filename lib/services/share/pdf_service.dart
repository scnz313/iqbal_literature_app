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
  static const double titleFontSize = 26;
  static const double contentFontSize = 18;
  static const double footerFontSize = 11;
  static const double lineHeight = 2.2; // Increased for better Urdu readability
  static const String fontFamily = 'JameelNooriNastaleeq';

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

  /// Split content into logical pages
  static List<PageData> _splitContentIntoPages(String title, String content) {
    final pages = <PageData>[];
    final lines = content.split('\n');
    
    // More conservative line estimates for better Urdu text handling
    const baseLinesPerPage = 22;
    final firstPageLines = baseLinesPerPage - (title.isNotEmpty ? 6 : 0); // Account for title space
    
    int currentIndex = 0;
    int pageNumber = 1;
    
    while (currentIndex < lines.length) {
      final isFirstPage = pageNumber == 1;
      final linesForThisPage = isFirstPage ? firstPageLines : baseLinesPerPage;
      
      final endIndex = (currentIndex + linesForThisPage).clamp(0, lines.length);
      final pageLines = lines.sublist(currentIndex, endIndex);
      
      // Join lines preserving empty lines for proper poem structure
      final pageContent = pageLines.join('\n');
      
      pages.add(PageData(
        title: isFirstPage ? title : '',
        content: pageContent,
        pageNumber: pageNumber,
        isFirstPage: isFirstPage,
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

    // Fill background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, pageWidth, pageHeight),
      Paint()..color = Colors.white,
    );

    double yOffset = margin;

    // Draw title (only on first page)
    if (pageData.title.isNotEmpty && pageData.isFirstPage) {
      yOffset = await _drawTitle(canvas, pageData.title, yOffset);
      yOffset += 20; // Extra spacing after title
    }

    // Draw content
    yOffset = await _drawContent(canvas, pageData.content, yOffset);

    // Draw footer
    await _drawFooter(canvas, pageNumber, totalPages);

    // Convert to image
    final picture = recorder.endRecording();
    final image = await picture.toImage(pageWidth.toInt(), pageHeight.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    // Cleanup
    picture.dispose();
    image.dispose();

    if (byteData == null) {
      throw Exception('Failed to convert page to image');
    }

    return byteData.buffer.asUint8List();
  }

  /// Draw title section
  static Future<double> _drawTitle(Canvas canvas, String title, double yOffset) async {
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
    
    // Center the title properly for RTL text
    final titleX = margin + (contentWidth - titlePainter.width) / 2;
    titlePainter.paint(canvas, Offset(titleX, yOffset));
    
    yOffset += titlePainter.height + 15;

    // Draw decorative divider line
    final dividerY = yOffset;
    canvas.drawLine(
      Offset(margin + 20, dividerY),
      Offset(pageWidth - margin - 20, dividerY),
      Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 2,
    );

    // Add small decorative elements
    canvas.drawCircle(
      Offset(pageWidth / 2, dividerY),
      3,
      Paint()..color = Colors.grey.shade600,
    );

    return yOffset + 25;
  }

  /// Draw content section
  static Future<double> _drawContent(Canvas canvas, String content, double yOffset) async {
    // Split content into lines for better control
    final lines = content.split('\n');
    double currentY = yOffset;
    
    for (final line in lines) {
      if (line.trim().isEmpty) {
        currentY += contentFontSize * 0.8; // Add spacing for empty lines
        continue;
      }
      
      final linePainter = TextPainter(
        text: TextSpan(
          text: line.trim(),
          style: const TextStyle(
            fontSize: contentFontSize,
            height: lineHeight,
            color: Colors.black,
            fontFamily: fontFamily,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
      );

      linePainter.layout(maxWidth: contentWidth);
      
      // Right-align the content for proper Urdu text alignment
      final contentX = pageWidth - margin - linePainter.width;
      linePainter.paint(canvas, Offset(contentX, currentY));
      
      currentY += linePainter.height + (contentFontSize * 0.3); // Add line spacing
    }

    return currentY;
  }

  /// Draw footer with page information
  static Future<void> _drawFooter(Canvas canvas, int pageNumber, int totalPages) async {
    final footerY = pageHeight - margin + 5;

    // Draw elegant footer separator line
    canvas.drawLine(
      Offset(margin + 30, footerY - 25),
      Offset(pageWidth - margin - 30, footerY - 25),
      Paint()
        ..color = Colors.grey.shade400
        ..strokeWidth = 1,
    );

    // Add small decorative dots
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(pageWidth / 2 - 10 + (i * 10), footerY - 25),
        1,
        Paint()..color = Colors.grey.shade500,
      );
    }

    // Page number (left side in English)
    final pageNumberPainter = TextPainter(
      text: TextSpan(
        text: 'صفحہ $pageNumber از $totalPages', // Urdu page numbering
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
    pageNumberPainter.paint(canvas, Offset(pageNumberX, footerY - 18));

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
    appNamePainter.paint(canvas, Offset(margin, footerY - 18));
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