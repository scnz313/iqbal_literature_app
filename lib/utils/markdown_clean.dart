// Utility to strip common markdown / formatting characters that leak into AI responses
extension MarkdownClean on String {
  String cleaned() {
    var out = this;
    // Remove ** bold markers
    out = out.replaceAll('**', '');
    // Remove single asterisk or underscore italics when surrounded by word characters
    out = out.replaceAllMapped(RegExp(r'[*_](\S.*?)[_*]'), (m) => m[1]!);
    // Remove back-ticks
    out = out.replaceAll('```', '').replaceAll('`', '');
    // Remove leading bullet markdown like "- " or "* " or "• "
    out = out.replaceAll(RegExp(r'^\s*[-*•]\s+', multiLine: true), '• ');
    // Collapse multiple spaces
    out = out.replaceAll(RegExp(r' {2,}'), ' ');
    return out.trim();
  }
} 