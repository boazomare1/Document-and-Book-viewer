import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/accessibility_settings.dart';
import 'package:flutter/material.dart'; // Added missing import for Color

class AccessibilityService {
  static const String _settingsKey = 'accessibility_settings';

  static final AccessibilityService _instance =
      AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  AccessibilitySettings _settings = const AccessibilitySettings();

  AccessibilitySettings get settings => _settings;

  Future<void> initialize() async {
    await loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
        _settings = AccessibilitySettings.fromJson(settingsMap);
      }
    } catch (e) {
      // Use default settings if loading fails
      _settings = const AccessibilitySettings();
    }
  }

  Future<void> saveSettings(AccessibilitySettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(settings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
      _settings = settings;
    } catch (e) {
      // Handle save error
    }
  }

  Future<void> updateTheme(ReadingTheme theme) async {
    final newSettings = _settings.copyWith(theme: theme);
    await saveSettings(newSettings);
  }

  Future<void> updateFontSize(double fontSize) async {
    final newSettings = _settings.copyWith(fontSize: fontSize);
    await saveSettings(newSettings);
  }

  Future<void> updateTtsSettings({
    bool? enableTts,
    double? ttsSpeed,
    double? ttsPitch,
    double? ttsVolume,
  }) async {
    final newSettings = _settings.copyWith(
      enableTts: enableTts,
      ttsSpeed: ttsSpeed,
      ttsPitch: ttsPitch,
      ttsVolume: ttsVolume,
    );
    await saveSettings(newSettings);
  }

  Future<void> updateReflowSettings(bool enableReflow) async {
    final newSettings = _settings.copyWith(enableReflow: enableReflow);
    await saveSettings(newSettings);
  }

  Future<void> updateScreenReaderSettings(bool enableScreenReader) async {
    final newSettings = _settings.copyWith(
      enableScreenReader: enableScreenReader,
    );
    await saveSettings(newSettings);
  }

  Future<void> updateHighContrastSettings(bool enableHighContrast) async {
    final newSettings = _settings.copyWith(
      enableHighContrast: enableHighContrast,
    );
    await saveSettings(newSettings);
  }

  Future<void> updateLargeTextSettings(bool enableLargeText) async {
    final newSettings = _settings.copyWith(enableLargeText: enableLargeText);
    await saveSettings(newSettings);
  }

  // Get effective font size based on settings
  double getEffectiveFontSize() {
    double baseSize = _settings.fontSize;
    if (_settings.enableLargeText) {
      baseSize *= 1.3; // 30% larger for large text mode
    }
    return baseSize;
  }

  // Get effective theme colors with high contrast if enabled
  Map<String, Color> getEffectiveThemeColors() {
    final colors = _settings.getThemeColors();

    if (_settings.enableHighContrast) {
      return {
        'background': const Color(0xFF000000),
        'surface': const Color(0xFF000000),
        'primary': const Color(0xFFFFFFFF),
        'onBackground': const Color(0xFFFFFFFF),
        'onSurface': const Color(0xFFFFFFFF),
        'onPrimary': const Color(0xFF000000),
      };
    }

    return colors;
  }

  // Reset to default settings
  Future<void> resetToDefaults() async {
    const defaultSettings = AccessibilitySettings();
    await saveSettings(defaultSettings);
  }
}
