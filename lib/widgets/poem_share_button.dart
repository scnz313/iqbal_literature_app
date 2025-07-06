import 'package:flutter/material.dart';
import '../services/share/pdf_service.dart';

/// A specialized button for sharing poems as PDFs with advanced options
class PoemShareButton extends StatelessWidget {
  final String title;
  final String content;
  final String? author;
  final IconData? icon;
  final String? label;

  const PoemShareButton({
    super.key,
    required this.title,
    required this.content,
    this.author,
    this.icon = Icons.picture_as_pdf,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return label != null
        ? ElevatedButton.icon(
            icon: Icon(icon),
            label: Text(label!),
            onPressed: () => _sharePdf(context),
          )
        : IconButton(
            icon: Icon(icon),
            tooltip: 'Export as PDF',
            onPressed: () => _sharePdf(context),
          );
  }

  // Share the poem as PDF using the new robust service
  Future<void> _sharePdf(BuildContext context) async {
    try {
      await PdfService.generateAndSharePdf(
        title: title,
        content: content,
        context: context,
      );
    } catch (e) {
      // Error handling is already done in the PdfService
      debugPrint('Error in PoemShareButton: $e');
    }
  }
}
