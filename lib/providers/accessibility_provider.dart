import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../utils/accessibility_utils.dart';

class AccessibilityProvider extends ChangeNotifier {
  // Basic accessibility settings
  double _fontSize = AccessibilityUtils.defaultFontSize;
  double _lineSpacing = AccessibilityUtils.defaultLineSpacing;
  String _fontFamily = AccessibilityUtils.dyslexiaFriendlyFonts.first;
  String _colorScheme = 'default';
  bool _isHighContrast = false;
  bool _isLargeText = false;
  bool _isScreenReaderMode = false;

  // Reflowed reader mode
  bool _isReflowedMode = false;
  double _reflowedFontSize = AccessibilityUtils.defaultFontSize;
  double _reflowedLineSpacing = AccessibilityUtils.defaultLineSpacing;
  String _reflowedFontFamily = AccessibilityUtils.dyslexiaFriendlyFonts.first;
  String _reflowedColorScheme = 'default';

  // Focus ruler
  bool _showFocusRuler = false;
  double _focusRulerHeight = AccessibilityUtils.defaultFocusRulerHeight;
  Color _focusRulerColor = AccessibilityUtils.defaultFocusRulerColor;
  double _focusRulerOpacity = AccessibilityUtils.defaultFocusRulerOpacity;

  // TTS settings
  final TTSController _ttsController = TTSController();
  bool _isTTSEnabled = false;
  bool _isWordByWordTTS = false;
  bool _isSentenceBySentenceTTS = false;
  double _ttsSpeed = 0.5;
  String _selectedVoice = '';
  String _selectedLanguage = 'en-US';

  // Keyboard navigation
  bool _isKeyboardNavigationEnabled = false;
  String _currentFocusId = '';
  List<String> _focusOrder = [];

  // Screen reader announcements
  bool _enableAnnouncements = true;

  // Getters
  double get fontSize => _fontSize;
  double get lineSpacing => _lineSpacing;
  String get fontFamily => _fontFamily;
  String get colorScheme => _colorScheme;
  bool get isHighContrast => _isHighContrast;
  bool get isLargeText => _isLargeText;
  bool get isScreenReaderMode => _isScreenReaderMode;
  bool get isReflowedMode => _isReflowedMode;
  double get reflowedFontSize => _reflowedFontSize;
  double get reflowedLineSpacing => _reflowedLineSpacing;
  String get reflowedFontFamily => _reflowedFontFamily;
  String get reflowedColorScheme => _reflowedColorScheme;
  bool get showFocusRuler => _showFocusRuler;
  double get focusRulerHeight => _focusRulerHeight;
  Color get focusRulerColor => _focusRulerColor;
  double get focusRulerOpacity => _focusRulerOpacity;
  TTSController get ttsController => _ttsController;
  bool get isTTSEnabled => _isTTSEnabled;
  bool get isWordByWordTTS => _isWordByWordTTS;
  bool get isSentenceBySentenceTTS => _isSentenceBySentenceTTS;
  double get ttsSpeed => _ttsSpeed;
  String get selectedVoice => _selectedVoice;
  String get selectedLanguage => _selectedLanguage;
  bool get isKeyboardNavigationEnabled => _isKeyboardNavigationEnabled;
  String get currentFocusId => _currentFocusId;
  List<String> get focusOrder => _focusOrder;
  bool get enableAnnouncements => _enableAnnouncements;

  // Initialize accessibility provider
  Future<void> initialize() async {
    await _ttsController.initialize();
    _loadSettings();
    notifyListeners();
  }

  // Load saved settings
  void _loadSettings() {
    // TODO: Load settings from shared preferences
    // For now, use default values
  }

  // Save settings
  void _saveSettings() {
    // TODO: Save settings to shared preferences
  }

  // Basic accessibility settings
  void setFontSize(double size) {
    _fontSize = size.clamp(
      AccessibilityUtils.minFontSize,
      AccessibilityUtils.maxFontSize,
    );
    _saveSettings();
    notifyListeners();
  }

  void setLineSpacing(double spacing) {
    _lineSpacing = spacing.clamp(1.0, 3.0);
    _saveSettings();
    notifyListeners();
  }

  void setFontFamily(String font) {
    if (AccessibilityUtils.dyslexiaFriendlyFonts.contains(font)) {
      _fontFamily = font;
      _saveSettings();
      notifyListeners();
    }
  }

  void setColorScheme(String scheme) {
    if (AccessibilityUtils.colorSchemes.containsKey(scheme)) {
      _colorScheme = scheme;
      _saveSettings();
      notifyListeners();
    }
  }

  void toggleHighContrast() {
    _isHighContrast = !_isHighContrast;
    if (_isHighContrast) {
      _colorScheme = 'highContrast';
    } else {
      _colorScheme = 'default';
    }
    _saveSettings();
    notifyListeners();
  }

  void toggleLargeText() {
    _isLargeText = !_isLargeText;
    if (_isLargeText) {
      _fontSize = (_fontSize * 1.2).clamp(
        AccessibilityUtils.minFontSize,
        AccessibilityUtils.maxFontSize,
      );
    } else {
      _fontSize = (_fontSize / 1.2).clamp(
        AccessibilityUtils.minFontSize,
        AccessibilityUtils.maxFontSize,
      );
    }
    _saveSettings();
    notifyListeners();
  }

  void toggleScreenReaderMode() {
    _isScreenReaderMode = !_isScreenReaderMode;
    _saveSettings();
    notifyListeners();
  }

  // Reflowed reader mode settings
  void setReflowedMode(bool enabled) {
    _isReflowedMode = enabled;
    _saveSettings();
    notifyListeners();
  }

  void setReflowedFontSize(double size) {
    _reflowedFontSize = size.clamp(
      AccessibilityUtils.minFontSize,
      AccessibilityUtils.maxFontSize,
    );
    _saveSettings();
    notifyListeners();
  }

  void setReflowedLineSpacing(double spacing) {
    _reflowedLineSpacing = spacing.clamp(1.0, 3.0);
    _saveSettings();
    notifyListeners();
  }

  void setReflowedFontFamily(String font) {
    if (AccessibilityUtils.dyslexiaFriendlyFonts.contains(font)) {
      _reflowedFontFamily = font;
      _saveSettings();
      notifyListeners();
    }
  }

  void setReflowedColorScheme(String scheme) {
    if (AccessibilityUtils.colorSchemes.containsKey(scheme)) {
      _reflowedColorScheme = scheme;
      _saveSettings();
      notifyListeners();
    }
  }

  // Focus ruler settings
  void toggleFocusRuler() {
    _showFocusRuler = !_showFocusRuler;
    _saveSettings();
    notifyListeners();
  }

  void setFocusRulerHeight(double height) {
    _focusRulerHeight = height.clamp(1.0, 10.0);
    _saveSettings();
    notifyListeners();
  }

  void setFocusRulerColor(Color color) {
    _focusRulerColor = color;
    _saveSettings();
    notifyListeners();
  }

  void setFocusRulerOpacity(double opacity) {
    _focusRulerOpacity = opacity.clamp(0.1, 1.0);
    _saveSettings();
    notifyListeners();
  }

  // TTS settings
  void setTTSEnabled(bool enabled) {
    _isTTSEnabled = enabled;
    _ttsController.setEnabled(enabled);
    _saveSettings();
    notifyListeners();
  }

  void setWordByWordTTS(bool enabled) {
    _isWordByWordTTS = enabled;
    _ttsController.setWordByWord(enabled);
    if (enabled) {
      _isSentenceBySentenceTTS = false;
      _ttsController.setSentenceBySentence(false);
    }
    _saveSettings();
    notifyListeners();
  }

  void setSentenceBySentenceTTS(bool enabled) {
    _isSentenceBySentenceTTS = enabled;
    _ttsController.setSentenceBySentence(enabled);
    if (enabled) {
      _isWordByWordTTS = false;
      _ttsController.setWordByWord(false);
    }
    _saveSettings();
    notifyListeners();
  }

  void setTTSSpeed(double speed) {
    _ttsSpeed = speed.clamp(0.1, 1.0);
    _ttsController.setSpeed(_ttsSpeed);
    _saveSettings();
    notifyListeners();
  }

  void setSelectedVoice(String voice) {
    _selectedVoice = voice;
    _ttsController.setVoice(voice);
    _saveSettings();
    notifyListeners();
  }

  void setSelectedLanguage(String language) {
    _selectedLanguage = language;
    _ttsController.setLanguage(language);
    _saveSettings();
    notifyListeners();
  }

  // Keyboard navigation
  void setKeyboardNavigationEnabled(bool enabled) {
    _isKeyboardNavigationEnabled = enabled;
    _saveSettings();
    notifyListeners();
  }

  void setCurrentFocus(String focusId) {
    _currentFocusId = focusId;
    notifyListeners();
  }

  void setFocusOrder(List<String> order) {
    _focusOrder = order;
    notifyListeners();
  }

  void nextFocus() {
    if (_focusOrder.isNotEmpty) {
      final currentIndex = _focusOrder.indexOf(_currentFocusId);
      if (currentIndex != -1 && currentIndex < _focusOrder.length - 1) {
        _currentFocusId = _focusOrder[currentIndex + 1];
        AccessibilityFocusManager.focusNode(_currentFocusId);
        notifyListeners();
      }
    }
  }

  void previousFocus() {
    if (_focusOrder.isNotEmpty) {
      final currentIndex = _focusOrder.indexOf(_currentFocusId);
      if (currentIndex > 0) {
        _currentFocusId = _focusOrder[currentIndex - 1];
        AccessibilityFocusManager.focusNode(_currentFocusId);
        notifyListeners();
      }
    }
  }

  // Screen reader announcements
  void setEnableAnnouncements(bool enabled) {
    _enableAnnouncements = enabled;
    _saveSettings();
    notifyListeners();
  }

  void announce(BuildContext context, String message) {
    if (_enableAnnouncements) {
      AccessibilityAnnouncementManager.announce(context, message);
    }
  }

  // Get effective theme colors based on accessibility settings
  Map<String, Color> getEffectiveThemeColors() {
    final colors = AccessibilityUtils.colorSchemes[_colorScheme]!;

    if (_isHighContrast) {
      return {
        'background': Colors.black,
        'surface': Colors.black,
        'primary': Colors.white,
        'onPrimary': Colors.black,
        'onSurface': Colors.white,
        'onBackground': Colors.white,
        'onSurfaceVariant': Colors.grey[300]!,
      };
    }

    return colors;
  }

  // Get effective font size based on accessibility settings
  double getEffectiveFontSize() {
    double effectiveSize = _fontSize;

    if (_isLargeText) {
      effectiveSize *= 1.2;
    }

    return effectiveSize.clamp(
      AccessibilityUtils.minFontSize,
      AccessibilityUtils.maxFontSize,
    );
  }

  // Get effective theme for reflowed mode
  ThemeData getReflowedTheme(ThemeData baseTheme) {
    final colors = AccessibilityUtils.colorSchemes[_reflowedColorScheme]!;

    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(
        fontSizeFactor: _reflowedFontSize / AccessibilityUtils.defaultFontSize,
        fontFamily: _reflowedFontFamily,
      ),
      colorScheme: baseTheme.colorScheme.copyWith(
        surface: colors['background']!,
        onSurface: colors['text']!,
        primary: colors['highlight']!,
      ),
    );
  }

  // TTS methods
  Future<void> speakText(String text) async {
    if (_isTTSEnabled) {
      await _ttsController.speak(text);
    }
  }

  Future<void> stopTTS() async {
    await _ttsController.stop();
  }

  Future<void> pauseTTS() async {
    await _ttsController.pause();
  }

  Future<void> resumeTTS() async {
    await _ttsController.resume();
  }

  Future<void> toggleTTSPlayPause(String text) async {
    await _ttsController.togglePlayPause(text);
  }

  // Reset all settings to defaults
  void resetToDefaults() {
    _fontSize = AccessibilityUtils.defaultFontSize;
    _lineSpacing = AccessibilityUtils.defaultLineSpacing;
    _fontFamily = AccessibilityUtils.dyslexiaFriendlyFonts.first;
    _colorScheme = 'default';
    _isHighContrast = false;
    _isLargeText = false;
    _isScreenReaderMode = false;
    _isReflowedMode = false;
    _reflowedFontSize = AccessibilityUtils.defaultFontSize;
    _reflowedLineSpacing = AccessibilityUtils.defaultLineSpacing;
    _reflowedFontFamily = AccessibilityUtils.dyslexiaFriendlyFonts.first;
    _reflowedColorScheme = 'default';
    _showFocusRuler = false;
    _focusRulerHeight = AccessibilityUtils.defaultFocusRulerHeight;
    _focusRulerColor = AccessibilityUtils.defaultFocusRulerColor;
    _focusRulerOpacity = AccessibilityUtils.defaultFocusRulerOpacity;
    _isTTSEnabled = false;
    _isWordByWordTTS = false;
    _isSentenceBySentenceTTS = false;
    _ttsSpeed = 0.5;
    _selectedVoice = '';
    _selectedLanguage = 'en-US';
    _isKeyboardNavigationEnabled = false;
    _currentFocusId = '';
    _focusOrder = [];
    _enableAnnouncements = true;

    _ttsController.setEnabled(false);
    _ttsController.setWordByWord(false);
    _ttsController.setSentenceBySentence(false);
    _ttsController.setSpeed(_ttsSpeed);

    _saveSettings();
    notifyListeners();
  }

  // Export settings for backup
  Map<String, dynamic> exportSettings() {
    return {
      'fontSize': _fontSize,
      'lineSpacing': _lineSpacing,
      'fontFamily': _fontFamily,
      'colorScheme': _colorScheme,
      'isHighContrast': _isHighContrast,
      'isLargeText': _isLargeText,
      'isScreenReaderMode': _isScreenReaderMode,
      'isReflowedMode': _isReflowedMode,
      'reflowedFontSize': _reflowedFontSize,
      'reflowedLineSpacing': _reflowedLineSpacing,
      'reflowedFontFamily': _reflowedFontFamily,
      'reflowedColorScheme': _reflowedColorScheme,
      'showFocusRuler': _showFocusRuler,
      'focusRulerHeight': _focusRulerHeight,
      'focusRulerColor': _focusRulerColor.toARGB32(),
      'focusRulerOpacity': _focusRulerOpacity,
      'isTTSEnabled': _isTTSEnabled,
      'isWordByWordTTS': _isWordByWordTTS,
      'isSentenceBySentenceTTS': _isSentenceBySentenceTTS,
      'ttsSpeed': _ttsSpeed,
      'selectedVoice': _selectedVoice,
      'selectedLanguage': _selectedLanguage,
      'isKeyboardNavigationEnabled': _isKeyboardNavigationEnabled,
      'enableAnnouncements': _enableAnnouncements,
    };
  }

  // Import settings from backup
  void importSettings(Map<String, dynamic> settings) {
    _fontSize = settings['fontSize'] ?? AccessibilityUtils.defaultFontSize;
    _lineSpacing =
        settings['lineSpacing'] ?? AccessibilityUtils.defaultLineSpacing;
    _fontFamily =
        settings['fontFamily'] ??
        AccessibilityUtils.dyslexiaFriendlyFonts.first;
    _colorScheme = settings['colorScheme'] ?? 'default';
    _isHighContrast = settings['isHighContrast'] ?? false;
    _isLargeText = settings['isLargeText'] ?? false;
    _isScreenReaderMode = settings['isScreenReaderMode'] ?? false;
    _isReflowedMode = settings['isReflowedMode'] ?? false;
    _reflowedFontSize =
        settings['reflowedFontSize'] ?? AccessibilityUtils.defaultFontSize;
    _reflowedLineSpacing =
        settings['reflowedLineSpacing'] ??
        AccessibilityUtils.defaultLineSpacing;
    _reflowedFontFamily =
        settings['reflowedFontFamily'] ??
        AccessibilityUtils.dyslexiaFriendlyFonts.first;
    _reflowedColorScheme = settings['reflowedColorScheme'] ?? 'default';
    _showFocusRuler = settings['showFocusRuler'] ?? false;
    _focusRulerHeight =
        settings['focusRulerHeight'] ??
        AccessibilityUtils.defaultFocusRulerHeight;
    _focusRulerColor = Color(
      settings['focusRulerColor'] ??
          AccessibilityUtils.defaultFocusRulerColor.toARGB32(),
    );
    _focusRulerOpacity =
        settings['focusRulerOpacity'] ??
        AccessibilityUtils.defaultFocusRulerOpacity;
    _isTTSEnabled = settings['isTTSEnabled'] ?? false;
    _isWordByWordTTS = settings['isWordByWordTTS'] ?? false;
    _isSentenceBySentenceTTS = settings['isSentenceBySentenceTTS'] ?? false;
    _ttsSpeed = settings['ttsSpeed'] ?? 0.5;
    _selectedVoice = settings['selectedVoice'] ?? '';
    _selectedLanguage = settings['selectedLanguage'] ?? 'en-US';
    _isKeyboardNavigationEnabled =
        settings['isKeyboardNavigationEnabled'] ?? false;
    _enableAnnouncements = settings['enableAnnouncements'] ?? true;

    // Update TTS controller
    _ttsController.setEnabled(_isTTSEnabled);
    _ttsController.setWordByWord(_isWordByWordTTS);
    _ttsController.setSentenceBySentence(_isSentenceBySentenceTTS);
    _ttsController.setSpeed(_ttsSpeed);
    _ttsController.setVoice(_selectedVoice);
    _ttsController.setLanguage(_selectedLanguage);

    _saveSettings();
    notifyListeners();
  }

  @override
  void dispose() {
    _ttsController.dispose();
    super.dispose();
  }
}
