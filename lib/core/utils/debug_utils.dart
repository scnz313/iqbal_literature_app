import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

class DebugUtils {
  /// Print debug messages only when debug mode is enabled
  static void debugPrint(String message) {
    if (AppConstants.enableDebugMode && kDebugMode) {
      print('🐛 $message');
    }
  }

  /// Print info messages only when logging is enabled
  static void infoPrint(String message) {
    if (AppConstants.enableLogging && kDebugMode) {
      print('ℹ️ $message');
    }
  }

  /// Print error messages (always shown in debug mode)
  static void errorPrint(String message) {
    if (kDebugMode) {
      print('❌ $message');
    }
  }

  /// Print success messages only when logging is enabled
  static void successPrint(String message) {
    if (AppConstants.enableLogging && kDebugMode) {
      print('✅ $message');
    }
  }

  /// Print warning messages only when logging is enabled
  static void warningPrint(String message) {
    if (AppConstants.enableLogging && kDebugMode) {
      print('⚠️ $message');
    }
  }
} 