import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/accessibility_utils.dart';
import '../utils/responsive_layout.dart';

class ReflowedReader extends StatefulWidget {
  final String text;
  final VoidCallback? onClose;
  final Function(String)? onTextSelected;
  final bool enableTTS;
  final Function(String)? onTTSWord;
  final Function(String)? onTTSSentence;

  const ReflowedReader({
    super.key,
    required this.text,
    this.onClose,
    this.onTextSelected,
    this.enableTTS = false,
    this.onTTSWord,
    this.onTTSSentence,
  });

  @override
  State<ReflowedReader> createState() => _ReflowedReaderState();
}

class _ReflowedReaderState extends State<ReflowedReader>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late TextEditingController _textController;
  late AnimationController _highlightAnimationController;
  late Animation<double> _highlightAnimation;

  // Accessibility settings
  double _fontSize = AccessibilityUtils.defaultFontSize;
  double _lineSpacing = AccessibilityUtils.defaultLineSpacing;
  String _fontFamily = AccessibilityUtils.dyslexiaFriendlyFonts.first;
  String _colorScheme = 'default';
  bool _showFocusRuler = false;
  bool _isTTSActive = false;
  bool _isScreenReaderMode = false;

  // TTS highlighting
  TextRange? _currentWordRange;
  TextRange? _currentSentenceRange;
  int _currentWordIndex = 0;
  int _currentSentenceIndex = 0;
  List<TextRange> _wordRanges = [];
  List<TextRange> _sentenceRanges = [];

  // Focus management
  final FocusNode _readerFocusNode = FocusNode();
  final FocusNode _settingsFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _textController = TextEditingController(text: widget.text);

    _highlightAnimationController = AnimationController(
      duration: AccessibilityUtils.wordHighlightDuration,
      vsync: this,
    );

    _highlightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _highlightAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Initialize word and sentence ranges
    _wordRanges = AccessibilityUtils.getWordBoundaries(widget.text);
    _sentenceRanges = AccessibilityUtils.getSentenceBoundaries(widget.text);

    // Register focus nodes
    AccessibilityFocusManager.registerFocusNode('reader', _readerFocusNode);
    AccessibilityFocusManager.registerFocusNode('settings', _settingsFocusNode);

    // Set up keyboard navigation
    _readerFocusNode.addListener(() {
      if (_readerFocusNode.hasFocus) {
        _setupKeyboardNavigation();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _highlightAnimationController.dispose();
    _readerFocusNode.dispose();
    _settingsFocusNode.dispose();

    // Unregister focus nodes
    AccessibilityFocusManager.unregisterFocusNode('reader');
    AccessibilityFocusManager.unregisterFocusNode('settings');

    super.dispose();
  }

  void _setupKeyboardNavigation() {
    // Keyboard navigation will be handled by the Focus widget
  }

  void _increaseFontSize() {
    setState(() {
      _fontSize = (_fontSize + 2).clamp(
        AccessibilityUtils.minFontSize,
        AccessibilityUtils.maxFontSize,
      );
    });
    _announceFontSizeChange();
  }

  void _decreaseFontSize() {
    setState(() {
      _fontSize = (_fontSize - 2).clamp(
        AccessibilityUtils.minFontSize,
        AccessibilityUtils.maxFontSize,
      );
    });
    _announceFontSizeChange();
  }

  void _changeLineSpacing(double spacing) {
    setState(() {
      _lineSpacing = spacing;
    });
    _announceLineSpacingChange();
  }

  void _changeFontFamily(String fontFamily) {
    setState(() {
      _fontFamily = fontFamily;
    });
    _announceFontChange();
  }

  void _changeColorScheme(String scheme) {
    setState(() {
      _colorScheme = scheme;
    });
    _announceColorSchemeChange();
  }

  void _toggleFocusRuler() {
    setState(() {
      _showFocusRuler = !_showFocusRuler;
    });
    _announceFocusRulerToggle();
  }

  void _toggleScreenReaderMode() {
    setState(() {
      _isScreenReaderMode = !_isScreenReaderMode;
    });
  }

  void _nextWord() {
    if (_wordRanges.isNotEmpty && _currentWordIndex < _wordRanges.length - 1) {
      setState(() {
        _currentWordIndex++;
        _currentWordRange = _wordRanges[_currentWordIndex];
      });
      _highlightCurrentWord();
      _scrollToWord();
    }
  }

  void _previousWord() {
    if (_wordRanges.isNotEmpty && _currentWordIndex > 0) {
      setState(() {
        _currentWordIndex--;
        _currentWordRange = _wordRanges[_currentWordIndex];
      });
      _highlightCurrentWord();
      _scrollToWord();
    }
  }

  void _nextSentence() {
    if (_sentenceRanges.isNotEmpty &&
        _currentSentenceIndex < _sentenceRanges.length - 1) {
      setState(() {
        _currentSentenceIndex++;
        _currentSentenceRange = _sentenceRanges[_currentSentenceIndex];
      });
      _highlightCurrentSentence();
      _scrollToSentence();
    }
  }

  void _previousSentence() {
    if (_sentenceRanges.isNotEmpty && _currentSentenceIndex > 0) {
      setState(() {
        _currentSentenceIndex--;
        _currentSentenceRange = _sentenceRanges[_currentSentenceIndex];
      });
      _highlightCurrentSentence();
      _scrollToSentence();
    }
  }

  void _highlightCurrentWord() {
    if (_currentWordRange != null) {
      _highlightAnimationController.forward().then((_) {
        _highlightAnimationController.reverse();
      });

      if (widget.onTTSWord != null) {
        final word = widget.text.substring(
          _currentWordRange!.start,
          _currentWordRange!.end,
        );
        widget.onTTSWord!(word);
      }
    }
  }

  void _highlightCurrentSentence() {
    if (_currentSentenceRange != null) {
      _highlightAnimationController.forward().then((_) {
        _highlightAnimationController.reverse();
      });

      if (widget.onTTSSentence != null) {
        final sentence = widget.text.substring(
          _currentSentenceRange!.start,
          _currentSentenceRange!.end,
        );
        widget.onTTSSentence!(sentence);
      }
    }
  }

  void _scrollToWord() {
    // Calculate scroll position for the current word
    // This is a simplified implementation
    if (_currentWordIndex > 0) {
      final scrollOffset =
          (_currentWordIndex / _wordRanges.length) *
          _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToSentence() {
    // Calculate scroll position for the current sentence
    if (_currentSentenceIndex > 0) {
      final scrollOffset =
          (_currentSentenceIndex / _sentenceRanges.length) *
          _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _announceFontSizeChange() {
    AccessibilityAnnouncementManager.announceFontSizeChange(context, _fontSize);
  }

  void _announceLineSpacingChange() {
    AccessibilityAnnouncementManager.announceLineSpacingChange(
      context,
      _lineSpacing,
    );
  }

  void _announceFontChange() {
    AccessibilityAnnouncementManager.announceFontChange(context, _fontFamily);
  }

  void _announceColorSchemeChange() {
    AccessibilityAnnouncementManager.announceColorSchemeChange(
      context,
      _colorScheme,
    );
  }

  void _announceFocusRulerToggle() {
    final message =
        _showFocusRuler
            ? AccessibilityUtils.screenReaderAnnouncements['focusRulerEnabled']!
            : AccessibilityUtils
                .screenReaderAnnouncements['focusRulerDisabled']!;
    AccessibilityAnnouncementManager.announce(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final colors = AccessibilityUtils.colorSchemes[_colorScheme]!;

    return Scaffold(
      backgroundColor: colors['background'],
      appBar: _buildAppBar(context, theme, colorScheme),
      body: Row(
        children: [
          // Settings panel
          if (_isScreenReaderMode)
            _buildSettingsPanel(context, theme, colorScheme),

          // Main reader content
          Expanded(child: _buildReaderContent(context, theme, colors)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      title: Text(
        'Reflowed Reader',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      leading: IconButton(
        onPressed: widget.onClose,
        icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
        tooltip: 'Close reflowed reader',
      ),
      actions: [
        _buildAccessibilityButton(context, theme, colorScheme),
        _buildSettingsButton(context, theme, colorScheme),
      ],
    );
  }

  Widget _buildAccessibilityButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return IconButton(
      onPressed: _toggleScreenReaderMode,
      icon: Icon(
        _isScreenReaderMode ? Icons.accessibility : Icons.accessibility_new,
        color: colorScheme.onSurfaceVariant,
      ),
      tooltip:
          _isScreenReaderMode
              ? 'Disable screen reader mode'
              : 'Enable screen reader mode',
    );
  }

  Widget _buildSettingsButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return IconButton(
      onPressed: () {
        _settingsFocusNode.requestFocus();
      },
      icon: Icon(Icons.settings, color: colorScheme.onSurfaceVariant),
      tooltip: 'Accessibility settings',
    );
  }

  Widget _buildSettingsPanel(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: 300,
      color: colorScheme.surfaceContainer,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Accessibility Settings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFontSizeControls(context, theme, colorScheme),
                const SizedBox(height: 16),
                _buildLineSpacingControls(context, theme, colorScheme),
                const SizedBox(height: 16),
                _buildFontFamilyControls(context, theme, colorScheme),
                const SizedBox(height: 16),
                _buildColorSchemeControls(context, theme, colorScheme),
                const SizedBox(height: 16),
                _buildFocusRulerControls(context, theme, colorScheme),
                const SizedBox(height: 16),
                _buildKeyboardShortcutsHelp(context, theme, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeControls(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Font Size',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: _decreaseFontSize,
              icon: Icon(Icons.remove, color: colorScheme.onSurfaceVariant),
              tooltip: 'Decrease font size',
            ),
            Expanded(
              child: Text(
                '${_fontSize.round()}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            IconButton(
              onPressed: _increaseFontSize,
              icon: Icon(Icons.add, color: colorScheme.onSurfaceVariant),
              tooltip: 'Increase font size',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLineSpacingControls(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Line Spacing',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<double>(
          value: _lineSpacing,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items:
              AccessibilityUtils.lineSpacings.map((spacing) {
                return DropdownMenuItem(
                  value: spacing,
                  child: Text('${spacing.toStringAsFixed(1)}x'),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              _changeLineSpacing(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildFontFamilyControls(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Font Family',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _fontFamily,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items:
              AccessibilityUtils.dyslexiaFriendlyFonts.map((font) {
                return DropdownMenuItem(value: font, child: Text(font));
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              _changeFontFamily(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildColorSchemeControls(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color Scheme',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _colorScheme,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items:
              AccessibilityUtils.colorSchemes.keys.map((scheme) {
                return DropdownMenuItem(
                  value: scheme,
                  child: Text(scheme.replaceAll('_', ' ').toUpperCase()),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              _changeColorScheme(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildFocusRulerControls(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Text(
          'Focus Ruler',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Switch(
          value: _showFocusRuler,
          onChanged: (value) {
            _toggleFocusRuler();
          },
        ),
      ],
    );
  }

  Widget _buildKeyboardShortcutsHelp(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return ExpansionTile(
      title: Text(
        'Keyboard Shortcuts',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            AccessibilityUtils.getKeyboardNavigationHelp(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReaderContent(
    BuildContext context,
    ThemeData theme,
    Map<String, Color> colors,
  ) {
    return Stack(
      children: [
        // Main text content
        Focus(
          focusNode: _readerFocusNode,
          autofocus: true,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent) {
                _handleKeyEvent(event);
              }
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: ResponsiveLayout.getAdaptivePadding(context),
              child: _buildTextContent(context, theme, colors),
            ),
          ),
        ),

        // Focus ruler
        if (_showFocusRuler) _buildFocusRuler(context, colors),
      ],
    );
  }

  Widget _buildTextContent(
    BuildContext context,
    ThemeData theme,
    Map<String, Color> colors,
  ) {
    final textWidth = AccessibilityUtils.calculateOptimalTextWidth(
      context,
      _fontSize,
    );

    return Container(
      width: textWidth,
      margin: EdgeInsets.symmetric(
        horizontal: (MediaQuery.of(context).size.width - textWidth) / 2,
      ),
      child: SelectableText.rich(
        _buildTextSpan(context, theme, colors),
        style: TextStyle(
          fontSize: _fontSize,
          fontFamily: _fontFamily,
          height: _lineSpacing,
          color: colors['text'],
        ),
        onSelectionChanged: (selection, cause) {
          if (selection.textInside(widget.text).isNotEmpty) {
            widget.onTextSelected?.call(selection.textInside(widget.text));
          }
        },
      ),
    );
  }

  TextSpan _buildTextSpan(
    BuildContext context,
    ThemeData theme,
    Map<String, Color> colors,
  ) {
    final spans = <TextSpan>[];
    int currentIndex = 0;

    while (currentIndex < widget.text.length) {
      // Check if current position is in a highlighted word
      if (_currentWordRange != null &&
          currentIndex >= _currentWordRange!.start &&
          currentIndex < _currentWordRange!.end) {
        spans.add(
          TextSpan(
            text: widget.text[currentIndex],
            style: TextStyle(
              backgroundColor: AccessibilityUtils.ttsWordHighlightColor
                  .withOpacity(_highlightAnimation.value),
            ),
          ),
        );
      }
      // Check if current position is in a highlighted sentence
      else if (_currentSentenceRange != null &&
          currentIndex >= _currentSentenceRange!.start &&
          currentIndex < _currentSentenceRange!.end) {
        spans.add(
          TextSpan(
            text: widget.text[currentIndex],
            style: TextStyle(
              backgroundColor: AccessibilityUtils.ttsSentenceHighlightColor
                  .withOpacity(_highlightAnimation.value),
            ),
          ),
        );
      }
      // Regular text
      else {
        spans.add(TextSpan(text: widget.text[currentIndex]));
      }
      currentIndex++;
    }

    return TextSpan(children: spans);
  }

  Widget _buildFocusRuler(BuildContext context, Map<String, Color> colors) {
    return Positioned(
      top:
          MediaQuery.of(context).size.height / 2 -
          AccessibilityUtils.defaultFocusRulerHeight / 2,
      left: 0,
      right: 0,
      child: Container(
        height: AccessibilityUtils.defaultFocusRulerHeight,
        decoration: BoxDecoration(
          color: AccessibilityUtils.defaultFocusRulerColor.withOpacity(
            AccessibilityUtils.defaultFocusRulerOpacity,
          ),
          boxShadow: [
            BoxShadow(
              color: AccessibilityUtils.defaultFocusRulerColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          _previousSentence();
          break;
        case LogicalKeyboardKey.arrowDown:
          _nextSentence();
          break;
        case LogicalKeyboardKey.arrowLeft:
          _previousWord();
          break;
        case LogicalKeyboardKey.arrowRight:
          _nextWord();
          break;
        case LogicalKeyboardKey.pageUp:
          _scrollController.animateTo(
            _scrollController.offset - 500,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          break;
        case LogicalKeyboardKey.pageDown:
          _scrollController.animateTo(
            _scrollController.offset + 500,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          break;
        case LogicalKeyboardKey.home:
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          break;
        case LogicalKeyboardKey.end:
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          break;
        case LogicalKeyboardKey.keyF:
          _toggleFocusRuler();
          break;
        case LogicalKeyboardKey.keyS:
          _toggleScreenReaderMode();
          break;
      }
    }
  }
}
