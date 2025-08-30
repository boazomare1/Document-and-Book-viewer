import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/pdf_provider.dart';
import '../providers/accessibility_provider.dart';
import '../widgets/pdf_document_card.dart';
import '../widgets/empty_state.dart';
import '../utils/responsive_layout.dart';
import '../utils/gesture_utils.dart';
import 'reader_screen.dart';
import 'accessibility_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late AnimationController _refreshAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _refreshRotationAnimation;

  @override
  void initState() {
    super.initState();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _refreshRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _refreshAnimationController,
        curve: Curves.linear,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PdfProvider>().loadDocuments();
      context.read<AccessibilityProvider>().initialize();
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _refreshAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        if (filePath != null) {
          await context.read<PdfProvider>().addDocument(filePath);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _refreshDocuments() async {
    _refreshAnimationController.repeat();
    await context.read<PdfProvider>().refreshAllDocuments();
    _refreshAnimationController.stop();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Documents refreshed'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context, theme, colorScheme),
      body: _buildBody(context, theme, colorScheme),
      floatingActionButton: _buildFloatingActionButton(
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
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.library_books,
              color: colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'PDF Library',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      actions: [
        _buildRefreshButton(context, theme, colorScheme),
        _buildAccessibilityButton(context, theme, colorScheme),
      ],
    );
  }

  Widget _buildRefreshButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Consumer<PdfProvider>(
      builder: (context, pdfProvider, child) {
        return AnimatedBuilder(
          animation: _refreshRotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _refreshRotationAnimation.value * 2 * 3.14159,
              child: IconButton(
                onPressed: pdfProvider.isLoading ? null : _refreshDocuments,
                icon: Icon(Icons.refresh, color: colorScheme.onSurfaceVariant),
                tooltip: 'Refresh Documents',
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAccessibilityButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AccessibilitySettingsScreen(),
          ),
        );
      },
      icon: Icon(Icons.accessibility_new, color: colorScheme.onSurfaceVariant),
      tooltip: 'Accessibility Settings',
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Consumer<PdfProvider>(
      builder: (context, pdfProvider, child) {
        if (pdfProvider.isLoading) {
          return _buildLoadingState(context, theme, colorScheme);
        }

        if (pdfProvider.error != null) {
          return _buildErrorState(context, theme, colorScheme, pdfProvider);
        }

        if (pdfProvider.documents.isEmpty) {
          return _buildEmptyState(context, theme, colorScheme);
        }

        return _buildDocumentList(context, theme, colorScheme, pdfProvider);
      },
    );
  }

  Widget _buildLoadingState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            'Loading documents...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    PdfProvider pdfProvider,
  ) {
    return Center(
      child: Padding(
        padding: ResponsiveLayout.getAdaptivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveLayout.getAdaptiveIconSize(context) * 2,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pdfProvider.error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                pdfProvider.clearError();
                pdfProvider.loadDocuments();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return EmptyState(onAddPdf: _pickPdfFile);
  }

  Widget _buildDocumentList(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    PdfProvider pdfProvider,
  ) {
    return GestureUtils.wrapWithPullToRefresh(
      onRefresh: pdfProvider.loadDocuments,
      backgroundColor: colorScheme.surface,
      color: colorScheme.primary,
      child: AdaptiveBuilder(
        builder: (context, isMobile, isTablet, isDesktop) {
          if (isMobile) {
            return _buildMobileLayout(context, theme, colorScheme, pdfProvider);
          } else if (isTablet) {
            return _buildTabletLayout(context, theme, colorScheme, pdfProvider);
          } else {
            return _buildDesktopLayout(
              context,
              theme,
              colorScheme,
              pdfProvider,
            );
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    PdfProvider pdfProvider,
  ) {
    return ListView.builder(
      padding: ResponsiveLayout.getAdaptivePadding(context),
      itemCount: pdfProvider.documents.length,
      itemBuilder: (context, index) {
        final document = pdfProvider.documents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureUtils.wrapWithHeroAnimation(
            tag: 'document_${document.id}',
            child: PdfDocumentCard(
              document: document,
              onTap: () async {
                final navigator = Navigator.of(context);
                await pdfProvider.openDocument(document);
                if (mounted) {
                  navigator.push(
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              ReaderScreen(document: document),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                }
              },
              onDelete: () => _showDeleteDialog(document),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    PdfProvider pdfProvider,
  ) {
    return GridView.builder(
      padding: ResponsiveLayout.getAdaptivePadding(context),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveLayout.getGridCrossAxisCount(context),
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: pdfProvider.documents.length,
      itemBuilder: (context, index) {
        final document = pdfProvider.documents[index];
        return GestureUtils.wrapWithHeroAnimation(
          tag: 'document_${document.id}',
          child: PdfDocumentCard(
            document: document,
            onTap: () async {
              final navigator = Navigator.of(context);
              await pdfProvider.openDocument(document);
              if (mounted) {
                navigator.push(
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            ReaderScreen(document: document),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              }
            },
            onDelete: () => _showDeleteDialog(document),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    PdfProvider pdfProvider,
  ) {
    return Row(
      children: [
        // Sidebar for desktop
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            border: Border(
              right: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Library',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: pdfProvider.documents.length,
                  itemBuilder: (context, index) {
                    final document = pdfProvider.documents[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildDesktopDocumentItem(
                        context,
                        theme,
                        colorScheme,
                        document,
                        pdfProvider,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Main content area
        Expanded(
          child: _buildTabletLayout(context, theme, colorScheme, pdfProvider),
        ),
      ],
    );
  }

  Widget _buildDesktopDocumentItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    document,
    PdfProvider pdfProvider,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            Icons.picture_as_pdf,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          document.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          document.totalPages > 0 ? '${document.totalPages} pages' : 'PDF document',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        onTap: () async {
          final navigator = Navigator.of(context);
          await pdfProvider.openDocument(document);
          if (mounted) {
            navigator.push(
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        ReaderScreen(document: document),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFloatingActionButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AnimatedBuilder(
      animation: _fabScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: FloatingActionButton.extended(
            onPressed: _pickPdfFile,
            icon: const Icon(Icons.add),
            label: const Text('Add PDF'),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(document) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Document'),
            content: Text(
              'Are you sure you want to delete "${document.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  context.read<PdfProvider>().removeDocument(document.id);
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
