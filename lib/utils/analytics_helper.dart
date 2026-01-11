import 'package:flutter/material.dart';
import 'dart:io' show Platform;

/// Helper class to safely handle Firebase Analytics
/// Returns empty list on Windows since Firebase Analytics is not supported
class AnalyticsHelper {
  /// Get navigator observers for Firebase Analytics
  /// Returns empty list on Windows to avoid PlatformException errors
  static List<NavigatorObserver> getNavigatorObservers() {
    // Windows doesn't support Firebase Analytics - return empty immediately
    // This prevents any Firebase Analytics code from running on Windows
    if (Platform.isWindows) {
      return [];
    }

    // For non-Windows platforms, try to initialize Firebase Analytics
    // This is done in main.dart with proper error handling
    // We return empty here to be safe
    return [];
  }
}

