import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../models/pdf_document.dart';
import '../providers/pdf_provider.dart';
import '../providers/accessibility_provider.dart';
import '../providers/annotation_provider.dart';

import '../utils/responsive_layout.dart';
import '../utils/gesture_utils.dart';


import '../widgets/reflowed_reader.dart';
import '../widgets/annotation_toolbar.dart';

import '../widgets/page_navigator.dart';
import '../widgets/table_of_contents_sidebar.dart';

class ReaderScreen extends StatefulWidget {
  final PdfDocument document;

  const ReaderScreen({super.key, required this.document});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with TickerProviderStateMixin {
  bool _showSearchPanel = false;
  bool _showBottomBar = true;
  bool _showAnnotationToolbar = false;
  bool _showPageNavigator = false;
  bool _showTableOfContents = false;
  int _currentPage = 1;
  int _totalPages = 100;
  PDFViewController? _pdfViewController;
  bool _isNavigating = false;

  bool _isFullScreen = false;
  bool _isReflowedMode = false;

  // Animation controllers
  late AnimationController _bottomBarAnimationController;
  late AnimationController _toolbarAnimationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _bottomBarAnimation;
  late Animation<double> _toolbarAnimation;
  late Animation<double> _searchAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _bottomBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _toolbarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bottomBarAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _bottomBarAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _toolbarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _toolbarAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _currentPage = widget.document.lastReadPage;

    // Load annotations for this document
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnotationProvider>().initializeDocument(widget.document.id);

      // Check if reflowed mode is enabled
      final accessibilityProvider = context.read<AccessibilityProvider>();
      _isReflowedMode = accessibilityProvider.isReflowedMode;
    });
  }

  @override
  void dispose() {
    _bottomBarAnimationController.dispose();
    _toolbarAnimationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int pageNumber) {
    if (_currentPage != pageNumber && !_isNavigating) {
      setState(() {
        _currentPage = pageNumber;
        _isNavigating = true;
      });

      if (_pdfViewController != null) {
        _pdfViewController!.setPage(pageNumber - 1);
      }

      context.read<PdfProvider>().updateReadingProgress(
        widget.document.id,
        pageNumber,
      );

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _isNavigating = false;
          });
        }
      });
    }
  }

  void _toggleSearchPanel() {
    setState(() {
      _showSearchPanel = !_showSearchPanel;
    });

    if (_showSearchPanel) {
      _searchAnimationController.forward();
    } else {
      _searchAnimationController.reverse();
    }
  }

  void _toggleBottomBar() {
    setState(() {
      _showBottomBar = !_showBottomBar;
    });

    if (_showBottomBar) {
      _bottomBarAnimationController.reverse();
    } else {
      _bottomBarAnimationController.forward();
    }
  }

  void _toggleAnnotationToolbar() {
    setState(() {
      _showAnnotationToolbar = !_showAnnotationToolbar;
    });

    if (_showAnnotationToolbar) {
      _toolbarAnimationController.forward();
    } else {
      _toolbarAnimationController.reverse();
    }
  }

  void _performSearch(String text) {
    // TODO: Implement search functionality
  }

  void _onZoomChanged(double scale) {
    // Handle zoom changes if needed in the future
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _toggleReflowedMode() {
    setState(() {
      _isReflowedMode = !_isReflowedMode;
    });

    final accessibilityProvider = context.read<AccessibilityProvider>();
    accessibilityProvider.setReflowedMode(_isReflowedMode);

    if (_isReflowedMode) {
      accessibilityProvider.announce(context, 'Reflowed reader mode enabled');
    } else {
      accessibilityProvider.announce(context, 'Reflowed reader mode disabled');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _isFullScreen ? null : _buildAppBar(context, theme, colorScheme),
      body: _buildBody(context, theme, colorScheme),
      bottomNavigationBar: _buildBottomNavigationBar(
        context,
        theme,
        colorScheme,
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
        widget.document.name,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(Icons.arrow_back, color: colorScheme.onSurfaceVariant),
        tooltip: 'Back',
      ),
      actions: [
        _buildSearchButton(context, theme, colorScheme),
        _buildAnnotationButton(context, theme, colorScheme),
        _buildPageNavigatorButton(context, theme, colorScheme),
        _buildTableOfContentsButton(context, theme, colorScheme),
        _buildReflowedModeButton(context, theme, colorScheme),
        _buildFullScreenButton(context, theme, colorScheme),
        _buildMoreOptionsButton(context, theme, colorScheme),
      ],
    );
  }

  Widget _buildSearchButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return IconButton(
      onPressed: _toggleSearchPanel,
      icon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
      tooltip: 'Search',
      style: IconButton.styleFrom(
        backgroundColor: _showSearchPanel ? colorScheme.primaryContainer : null,
        foregroundColor:
            _showSearchPanel
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildAnnotationButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return IconButton(
      onPressed: _toggleAnnotationToolbar,
      icon: Icon(Icons.edit, color: colorScheme.onSurfaceVariant),
      tooltip: 'Annotations',
      style: IconButton.styleFrom(
        backgroundColor:
            _showAnnotationToolbar ? colorScheme.primaryContainer : null,
        foregroundColor:
            _showAnnotationToolbar
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPageNavigatorButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return IconButton(
      onPressed: () {
        setState(() {
          _showPageNavigator = !_showPageNavigator;
        });
      },
      icon: Icon(Icons.grid_view, color: colorScheme.onSurfaceVariant),
      tooltip: 'Page Navigator',
      style: IconButton.styleFrom(
        backgroundColor:
            _showPageNavigator ? colorScheme.primaryContainer : null,
        foregroundColor:
            _showPageNavigator
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildTableOfContentsButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return IconButton(
      onPressed: () {
        setState(() {
          _showTableOfContents = !_showTableOfContents;
        });
      },
      icon: Icon(Icons.list, color: colorScheme.onSurfaceVariant),
      tooltip: 'Table of Contents',
      style: IconButton.styleFrom(
        backgroundColor:
            _showTableOfContents ? colorScheme.primaryContainer : null,
        foregroundColor:
            _showTableOfContents
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildReflowedModeButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return IconButton(
      onPressed: _toggleReflowedMode,
      icon: Icon(
        _isReflowedMode ? Icons.text_fields : Icons.text_format,
        color: colorScheme.onSurfaceVariant,
      ),
      tooltip:
          _isReflowedMode ? 'Disable Reflowed Mode' : 'Enable Reflowed Mode',
      style: IconButton.styleFrom(
        backgroundColor: _isReflowedMode ? colorScheme.primaryContainer : null,
        foregroundColor:
            _isReflowedMode
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildFullScreenButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return IconButton(
      onPressed: _toggleFullScreen,
      icon: Icon(
        _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
        color: colorScheme.onSurfaceVariant,
      ),
      tooltip: _isFullScreen ? 'Exit Full Screen' : 'Full Screen',
    );
  }

  Widget _buildMoreOptionsButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'tts':
            // TODO: Implement TTS
            break;
          case 'share':
            // TODO: Implement share
            break;
          case 'bookmark':
            // TODO: Implement bookmark
            break;
        }
      },
      icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
      tooltip: 'More options',
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'tts',
              child: Row(
                children: [
                  Icon(Icons.volume_up),
                  SizedBox(width: 12),
                  Text('Text-to-Speech'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 12),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'bookmark',
              child: Row(
                children: [
                  Icon(Icons.bookmark_border),
                  SizedBox(width: 12),
                  Text('Bookmark'),
                ],
              ),
            ),
          ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // Show reflowed reader if enabled
    if (_isReflowedMode) {
      return ReflowedReader(
        text: _getExtractedText(),
        onClose: () => _toggleReflowedMode(),
        onTextSelected: (text) {
          // Handle text selection
          final accessibilityProvider = context.read<AccessibilityProvider>();
          if (accessibilityProvider.isTTSEnabled) {
            accessibilityProvider.speakText(text);
          }
        },
        enableTTS: context.read<AccessibilityProvider>().isTTSEnabled,
        onTTSWord: (word) {
          // Handle word-level TTS
        },
        onTTSSentence: (sentence) {
          // Handle sentence-level TTS
        },
      );
    }

    return Stack(
      children: [
        // Main PDF viewer
        _buildPdfViewer(context, theme, colorScheme),

        // Search panel
        if (_showSearchPanel) _buildSearchPanel(context, theme, colorScheme),

        // Annotation toolbar
        if (_showAnnotationToolbar)
          _buildAnnotationToolbarOverlay(context, theme, colorScheme),

        // Page navigator
        if (_showPageNavigator)
          _buildPageNavigatorOverlay(context, theme, colorScheme),

        // Table of contents
        if (_showTableOfContents)
          _buildTableOfContentsOverlay(context, theme, colorScheme),

        // Bottom bar
        if (_showBottomBar) _buildBottomBar(context, theme, colorScheme),
      ],
    );
  }

  String _getExtractedText() {
    // TODO: Extract text from PDF
    // For now, return a placeholder text
    return '''
This is a sample text extracted from the PDF document. In reflowed reader mode, 
the text is displayed in a more accessible format with adjustable font size, 
line spacing, and dyslexia-friendly fonts. Users can navigate through the text 
word by word or sentence by sentence with TTS synchronization.

The reflowed reader mode provides:
- Adjustable font size (12-48px)
- Customizable line spacing (1.0-3.0x)
- Dyslexia-friendly fonts (OpenDyslexic, Comic Sans MS, etc.)
- Multiple color schemes (default, high contrast, low vision, color blind)
- Focus ruler for low-vision readers
- Word and sentence-level TTS synchronization
- Full keyboard navigation support
- Screen reader announcements

This mode is particularly helpful for users with:
- Dyslexia and reading difficulties
- Low vision and visual impairments
- Motor impairments requiring keyboard navigation
- Cognitive disabilities requiring simplified reading experience
''';
  }

  Widget _buildPdfViewer(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return GestureUtils.wrapWithSwipeGesture(
      onSwipeLeft:
          _totalPages > 0 && _currentPage < _totalPages
              ? () => _onPageChanged(_currentPage + 1)
              : null,
      onSwipeRight:
          _currentPage > 1 ? () => _onPageChanged(_currentPage - 1) : null,
      onDoubleTap: _toggleBottomBar,
      child: GestureUtils.wrapWithZoomGesture(
        onZoomChanged: _onZoomChanged,
        child: Container(
          color: colorScheme.surface,
          child: PDFView(
            filePath: widget.document.path,
            enableSwipe: false, // We handle swipe gestures ourselves
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: false,
            pageSnap: false,
            defaultPage: _currentPage - 1,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onPageChanged: (page, total) {
              final newPage = (page ?? 0) + 1;
              final newTotal = total ?? 100;

              if (_currentPage != newPage || _totalPages != newTotal) {
                setState(() {
                  _currentPage = newPage;
                  _totalPages = newTotal;
                  _isNavigating = false;
                });

                if (total != null &&
                    (widget.document.totalPages == 0 ||
                        widget.document.totalPages != total)) {
                  context.read<PdfProvider>().updateDocumentTotalPages(
                    widget.document.id,
                    total,
                  );
                }

                context.read<PdfProvider>().updateReadingProgress(
                  widget.document.id,
                  newPage,
                );
              }
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _pdfViewController = pdfViewController;
            },
            onRender: (pages) {
              // PDF rendered
            },
            onError: (error) {
              // Handle error
            },
            onPageError: (page, error) {
              // Handle page error
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchPanel(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AnimatedBuilder(
      animation: _searchAnimation,
      builder: (context, child) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(0, -100 + (_searchAnimation.value * 100)),
            child: Container(
              color: colorScheme.surfaceContainer,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search in document...',
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onChanged: _performSearch,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _toggleSearchPanel,
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    tooltip: 'Close search',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnnotationToolbarOverlay(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AnimatedBuilder(
      animation: _toolbarAnimation,
      builder: (context, child) {
        return Positioned(
          top: 16,
          right: 16,
          child: Transform.scale(
            scale: _toolbarAnimation.value,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Consumer<AnnotationProvider>(
                builder: (context, annotationProvider, child) {
                  return AnnotationToolbar(
                    selectedTool: annotationProvider.selectedTool,
                    onToolSelected: (tool) {
                      annotationProvider.selectTool(tool);
                    },
                    onColorChanged: (color) {
                      annotationProvider.setColor(color);
                    },
                    onOpacityChanged: (opacity) {
                      annotationProvider.setOpacity(opacity);
                    },
                    onStrokeWidthChanged: (strokeWidth) {
                      annotationProvider.setStrokeWidth(strokeWidth);
                    },
                    currentColor: annotationProvider.currentColor,
                    currentOpacity: annotationProvider.currentOpacity,
                    currentStrokeWidth: annotationProvider.currentStrokeWidth,
                    isVisible: _showAnnotationToolbar,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageNavigatorOverlay(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Positioned(
      bottom: ResponsiveLayout.getBottomBarHeight(context) + 16,
      left: 16,
      right: 16,
      child: PageNavigator(
        currentPage: _currentPage,
        totalPages: _totalPages,
        onPageSelected: _onPageChanged,
      ),
    );
  }

  Widget _buildTableOfContentsOverlay(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Positioned(
      top: 0,
      right: 0,
      bottom: 0,
      width: ResponsiveLayout.getSidebarWidth(context),
      child: TableOfContentsSidebar(
        onPageSelected: (pageNumber) {
          setState(() {
            _currentPage = pageNumber;
          });
          _onPageChanged(pageNumber);
        },
        onClose: () {
          setState(() {
            _showTableOfContents = false;
          });
        },
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AnimatedBuilder(
      animation: _bottomBarAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Transform.translate(
            offset: Offset(0, 100 * _bottomBarAnimation.value),
            child: Container(
              color: colorScheme.surfaceContainer.withValues(alpha: 0.95),
              padding: ResponsiveLayout.getAdaptivePadding(context),
              child: SafeArea(
                child: Row(
                  children: [
                    _buildNavigationButton(
                      context,
                      theme,
                      colorScheme,
                      Icons.chevron_left,
                      'Previous page',
                      _currentPage > 1
                          ? () => _onPageChanged(_currentPage - 1)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPageInfo(context, theme, colorScheme),
                    ),
                    const SizedBox(width: 16),
                    _buildNavigationButton(
                      context,
                      theme,
                      colorScheme,
                      Icons.chevron_right,
                      'Next page',
                      _totalPages > 0 && _currentPage < _totalPages
                          ? () => _onPageChanged(_currentPage + 1)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    String tooltip,
    VoidCallback? onPressed,
  ) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor:
            onPressed != null
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPageInfo(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _totalPages > 0
              ? 'Page $_currentPage of $_totalPages'
              : 'Page $_currentPage',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        if (_totalPages > 0) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: _currentPage / _totalPages,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: 4,
          ),
        ],
      ],
    );
  }

  Widget? _buildBottomNavigationBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return null; // We handle bottom navigation with our custom bottom bar
  }
}
