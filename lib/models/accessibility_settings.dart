import 'package:flutter/material.dart';

enum ReadingTheme {
  light,
  dark,
  sepia,
  highContrast,
}

class AccessibilitySettings {
  final ReadingTheme theme;
  final double fontSize;
  final bool enableTts;
  final double ttsSpeed;
  final double ttsPitch;
  final double ttsVolume;
  final bool enableReflow;
  final bool enableScreenReader;
  final bool enableHighContrast;
  final bool enableLargeText;

  const AccessibilitySettings({
    this.theme = ReadingTheme.light,
    this.fontSize = 16.0,
    this.enableTts = false,
    this.ttsSpeed = 0.5,
    this.ttsPitch = 1.0,
    this.ttsVolume = 1.0,
    this.enableReflow = false,
    this.enableScreenReader = true,
    this.enableHighContrast = false,
    this.enableLargeText = false,
  });

  AccessibilitySettings copyWith({
    ReadingTheme? theme,
    double? fontSize,
    bool? enableTts,
    double? ttsSpeed,
    double? ttsPitch,
    double? ttsVolume,
    bool? enableReflow,
    bool? enableScreenReader,
    bool? enableHighContrast,
    bool? enableLargeText,
  }) {
    return AccessibilitySettings(
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      enableTts: enableTts ?? this.enableTts,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      ttsPitch: ttsPitch ?? this.ttsPitch,
      ttsVolume: ttsVolume ?? this.ttsVolume,
      enableReflow: enableReflow ?? this.enableReflow,
      enableScreenReader: enableScreenReader ?? this.enableScreenReader,
      enableHighContrast: enableHighContrast ?? this.enableHighContrast,
      enableLargeText: enableLargeText ?? this.enableLargeText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme.index,
      'fontSize': fontSize,
      'enableTts': enableTts,
      'ttsSpeed': ttsSpeed,
      'ttsPitch': ttsPitch,
      'ttsVolume': ttsVolume,
      'enableReflow': enableReflow,
      'enableScreenReader': enableScreenReader,
      'enableHighContrast': enableHighContrast,
      'enableLargeText': enableLargeText,
    };
  }

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      theme: ReadingTheme.values[json['theme'] ?? 0],
      fontSize: json['fontSize']?.toDouble() ?? 16.0,
      enableTts: json['enableTts'] ?? false,
      ttsSpeed: json['ttsSpeed']?.toDouble() ?? 0.5,
      ttsPitch: json['ttsPitch']?.toDouble() ?? 1.0,
      ttsVolume: json['ttsVolume']?.toDouble() ?? 1.0,
      enableReflow: json['enableReflow'] ?? false,
      enableScreenReader: json['enableScreenReader'] ?? true,
      enableHighContrast: json['enableHighContrast'] ?? false,
      enableLargeText: json['enableLargeText'] ?? false,
    );
  }

  // Get theme colors based on current theme
  Map<String, Color> getThemeColors() {
    switch (theme) {
      case ReadingTheme.light:
        return {
          'background': const Color(0xFFFFFFFF),
          'surface': const Color(0xFFF5F5F5),
          'primary': const Color(0xFF6750A4),
          'onBackground': const Color(0xFF1C1B1F),
          'onSurface': const Color(0xFF1C1B1F),
          'onPrimary': const Color(0xFFFFFFFF),
        };
      case ReadingTheme.dark:
        return {
          'background': const Color(0xFF1C1B1F),
          'surface': const Color(0xFF2F2F2F),
          'primary': const Color(0xFFD0BCFF),
          'onBackground': const Color(0xFFE6E1E5),
          'onSurface': const Color(0xFFE6E1E5),
          'onPrimary': const Color(0xFF381E72),
        };
      case ReadingTheme.sepia:
        return {
          'background': const Color(0xFFFDF6E3),
          'surface': const Color(0xFFF5E6D3),
          'primary': const Color(0xFF8B4513),
          'onBackground': const Color(0xFF2F2F2F),
          'onSurface': const Color(0xFF2F2F2F),
          'onPrimary': const Color(0xFFFFFFFF),
        };
      case ReadingTheme.highContrast:
        return {
          'background': const Color(0xFF000000),
          'surface': const Color(0xFF000000),
          'primary': const Color(0xFFFFFFFF),
          'onBackground': const Color(0xFFFFFFFF),
          'onSurface': const Color(0xFFFFFFFF),
          'onPrimary': const Color(0xFF000000),
        };
    }
  }
}
