import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccessibilityUtils {
  // Font sizes for reflowed reader mode
  static const List<double> fontSizes = [
    12,
    14,
    16,
    18,
    20,
    22,
    24,
    28,
    32,
    36,
  ];
  static const double defaultFontSize = 16.0;
  static const double minFontSize = 12.0;
  static const double maxFontSize = 48.0;

  // Line spacing options
  static const List<double> lineSpacings = [
    1.0,
    1.2,
    1.4,
    1.6,
    1.8,
    2.0,
    2.2,
    2.5,
  ];
  static const double defaultLineSpacing = 1.4;

  // Dyslexia-friendly fonts
  static const List<String> dyslexiaFriendlyFonts = [
    'OpenDyslexic',
    'Comic Sans MS',
    'Arial',
    'Verdana',
    'Tahoma',
    'Trebuchet MS',
    'Georgia',
    'Times New Roman',
  ];

  // Color schemes for different vision types
  static const Map<String, Map<String, Color>> colorSchemes = {
    'default': {
      'background': Color(0xFFFFFFFF),
      'text': Color(0xFF000000),
      'highlight': Color(0xFFFFEB3B),
    },
    'highContrast': {
      'background': Color(0xFF000000),
      'text': Color(0xFFFFFFFF),
      'highlight': Color(0xFFFF0000),
    },
    'lowVision': {
      'background': Color(0xFFF5F5F5),
      'text': Color(0xFF2C2C2C),
      'highlight': Color(0xFFFF6B35),
    },
    'colorBlind': {
      'background': Color(0xFFFFFFFF),
      'text': Color(0xFF000000),
      'highlight': Color(0xFF0066CC),
    },
  };

  // Focus ruler settings
  static const double defaultFocusRulerHeight = 3.0;
  static const Color defaultFocusRulerColor = Color(0xFF2196F3);
  static const double defaultFocusRulerOpacity = 0.7;

  // TTS synchronization settings
  static const Duration wordHighlightDuration = Duration(milliseconds: 500);
  static const Duration sentenceHighlightDuration = Duration(
    milliseconds: 1000,
  );
  static const Color ttsWordHighlightColor = Color(0xFFFFEB3B);
  static const Color ttsSentenceHighlightColor = Color(0xFFFF9800);

  // Keyboard navigation
  static final Map<LogicalKeyboardKey, String> keyboardShortcuts = {
    LogicalKeyboardKey.arrowUp: 'Previous line',
    LogicalKeyboardKey.arrowDown: 'Next line',
    LogicalKeyboardKey.arrowLeft: 'Previous word',
    LogicalKeyboardKey.arrowRight: 'Next word',
    LogicalKeyboardKey.pageUp: 'Previous page',
    LogicalKeyboardKey.pageDown: 'Next page',
    LogicalKeyboardKey.home: 'Beginning of document',
    LogicalKeyboardKey.end: 'End of document',
    LogicalKeyboardKey.space: 'Play/Pause TTS',
    LogicalKeyboardKey.keyR: 'Toggle reflowed mode',
    LogicalKeyboardKey.keyF: 'Toggle focus ruler',
    LogicalKeyboardKey.keyT: 'Toggle TTS',
    LogicalKeyboardKey.keyH: 'Toggle high contrast',
    LogicalKeyboardKey.keyL: 'Toggle large text',
    LogicalKeyboardKey.keyS: 'Toggle screen reader mode',
  };

  // Screen reader announcements
  static const Map<String, String> screenReaderAnnouncements = {
    'pageChanged': 'Page {page} of {total}',
    'fontSizeChanged': 'Font size changed to {size}',
    'lineSpacingChanged': 'Line spacing changed to {spacing}',
    'fontChanged': 'Font changed to {font}',
    'colorSchemeChanged': 'Color scheme changed to {scheme}',
    'ttsStarted': 'Text-to-speech started',
    'ttsPaused': 'Text-to-speech paused',
    'ttsStopped': 'Text-to-speech stopped',
    'reflowedModeEnabled': 'Reflowed reader mode enabled',
    'reflowedModeDisabled': 'Reflowed reader mode disabled',
    'focusRulerEnabled': 'Focus ruler enabled',
    'focusRulerDisabled': 'Focus ruler disabled',
  };

  // Get accessible text for screen readers
  static String getAccessibleText(String text, {String? context}) {
    if (context != null) {
      return '$context: $text';
    }
    return text;
  }

  // Format numbers for screen readers
  static String formatNumberForScreenReader(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      final thousands = (number / 1000).round();
      return '$thousands thousand';
    } else {
      final millions = (number / 1000000).round();
      return '$millions million';
    }
  }

  // Get semantic label for UI elements
  static String getSemanticLabel(
    String element, {
    String? action,
    String? state,
  }) {
    String label = element;
    if (action != null) {
      label = '$label, $action';
    }
    if (state != null) {
      label = '$label, $state';
    }
    return label;
  }

  // Calculate optimal text width for reflowed reading
  static double calculateOptimalTextWidth(
    BuildContext context,
    double fontSize,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = MediaQuery.of(context).padding;
    final availableWidth =
        screenWidth -
        padding.left -
        padding.right -
        32; // 16px margin on each side

    // Optimal line length is typically 50-75 characters
    // Assuming average character width is about 0.6 * fontSize
    final avgCharWidth = fontSize * 0.6;
    final optimalChars = 65; // Sweet spot for readability
    final optimalWidth = optimalChars * avgCharWidth;

    return optimalWidth.clamp(200, availableWidth);
  }

  // Get contrast ratio between two colors
  static double getContrastRatio(Color color1, Color color2) {
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();

    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  // Check if contrast meets WCAG guidelines
  static bool meetsWCAGContrast(
    Color foreground,
    Color background, {
    bool isLargeText = false,
  }) {
    final contrastRatio = getContrastRatio(foreground, background);
    return isLargeText ? contrastRatio >= 3.0 : contrastRatio >= 4.5;
  }

  // Get accessible color for text based on background
  static Color getAccessibleTextColor(Color backgroundColor) {
    const white = Color(0xFFFFFFFF);
    const black = Color(0xFF000000);

    final whiteContrast = getContrastRatio(white, backgroundColor);
    final blackContrast = getContrastRatio(black, backgroundColor);

    return whiteContrast > blackContrast ? white : black;
  }

  // Calculate focus ruler position
  static double calculateFocusRulerPosition(
    double scrollOffset,
    double lineHeight,
  ) {
    // Position the ruler at the center of the viewport
    return scrollOffset + (lineHeight / 2);
  }

  // Get word boundaries for TTS highlighting
  static List<TextRange> getWordBoundaries(String text) {
    final words = text.split(RegExp(r'\s+'));
    final ranges = <TextRange>[];
    int currentIndex = 0;

    for (final word in words) {
      final start = text.indexOf(word, currentIndex);
      if (start != -1) {
        ranges.add(TextRange(start: start, end: start + word.length));
        currentIndex = start + word.length;
      }
    }

    return ranges;
  }

  // Get sentence boundaries for TTS highlighting
  static List<TextRange> getSentenceBoundaries(String text) {
    final sentences = text.split(RegExp(r'[.!?]+'));
    final ranges = <TextRange>[];
    int currentIndex = 0;

    for (final sentence in sentences) {
      if (sentence.trim().isNotEmpty) {
        final start = text.indexOf(sentence, currentIndex);
        if (start != -1) {
          // Find the end of the sentence (including punctuation)
          int end = start + sentence.length;
          while (end < text.length && !text[end].contains(RegExp(r'[.!?]'))) {
            end++;
          }
          if (end < text.length) end++; // Include the punctuation

          ranges.add(TextRange(start: start, end: end));
          currentIndex = end;
        }
      }
    }

    return ranges;
  }

  // Format time for screen readers
  static String formatTimeForScreenReader(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '$minutes minute${minutes == 1 ? '' : 's'} $seconds second${seconds == 1 ? '' : 's'}';
    } else {
      return '$seconds second${seconds == 1 ? '' : 's'}';
    }
  }

  // Get keyboard navigation help text
  static String getKeyboardNavigationHelp() {
    return keyboardShortcuts.entries
        .map((entry) => '${entry.key.keyLabel}: ${entry.value}')
        .join('\n');
  }

  // Validate accessibility settings
  static bool validateAccessibilitySettings({
    required double fontSize,
    required double lineSpacing,
    required String fontFamily,
    required String colorScheme,
  }) {
    return fontSize >= minFontSize &&
        fontSize <= maxFontSize &&
        lineSpacing >= 1.0 &&
        lineSpacing <= 3.0 &&
        dyslexiaFriendlyFonts.contains(fontFamily) &&
        colorSchemes.containsKey(colorScheme);
  }
}

// Accessibility focus manager
class AccessibilityFocusManager {
  static final Map<String, FocusNode> _focusNodes = {};

  static void registerFocusNode(String id, FocusNode node) {
    _focusNodes[id] = node;
  }

  static void unregisterFocusNode(String id) {
    _focusNodes.remove(id);
  }

  static FocusNode? getFocusNode(String id) {
    return _focusNodes[id];
  }

  static void focusNode(String id) {
    final node = _focusNodes[id];
    if (node != null && node.canRequestFocus) {
      node.requestFocus();
    }
  }

  static void clearAllFocus() {
    for (final node in _focusNodes.values) {
      if (node.hasFocus) {}
    }
  }
}

// Accessibility announcement manager
class AccessibilityAnnouncementManager {
  static void announce(BuildContext context, String message) {
    // Use Semantics widget to announce messages
    // This will be handled by the Semantics widget in the widget tree
  }

  static void announcePageChange(
    BuildContext context,
    int currentPage,
    int totalPages,
  ) {
    final message = AccessibilityUtils.screenReaderAnnouncements['pageChanged']!
        .replaceAll('{page}', currentPage.toString())
        .replaceAll('{total}', totalPages.toString());
    announce(context, message);
  }

  static void announceFontSizeChange(BuildContext context, double fontSize) {
    final message = AccessibilityUtils
        .screenReaderAnnouncements['fontSizeChanged']!
        .replaceAll('{size}', fontSize.round().toString());
    announce(context, message);
  }

  static void announceLineSpacingChange(
    BuildContext context,
    double lineSpacing,
  ) {
    final message = AccessibilityUtils
        .screenReaderAnnouncements['lineSpacingChanged']!
        .replaceAll('{spacing}', lineSpacing.toStringAsFixed(1));
    announce(context, message);
  }

  static void announceFontChange(BuildContext context, String font) {
    final message = AccessibilityUtils.screenReaderAnnouncements['fontChanged']!
        .replaceAll('{font}', font);
    announce(context, message);
  }

  static void announceColorSchemeChange(BuildContext context, String scheme) {
    final message = AccessibilityUtils
        .screenReaderAnnouncements['colorSchemeChanged']!
        .replaceAll('{scheme}', scheme);
    announce(context, message);
  }
}
