import 'package:flutter/material.dart';

class LanguageConstants {
  static const Locale englishLocale = Locale('en', 'US');
  static const Locale urduLocale = Locale('ur', 'PK');
  static const Locale farsiLocale = Locale('fa', 'IR');
  
  static const List<Locale> supportedLocales = [
    englishLocale,
    urduLocale,
    farsiLocale,
  ];
  
  static const Map<String, String> languageNames = {
    'en': 'English',
    'ur': 'اردو',
    'fa': 'فارسی',
  };
  
  static Locale getLocaleFromLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return urduLocale;
      case 'fa':
        return farsiLocale;
      case 'en':
      default:
        return englishLocale;
    }
  }
  
  static String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }
}
