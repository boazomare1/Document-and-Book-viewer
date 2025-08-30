import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pdf_document.dart';
import '../services/pdf_service.dart';
import '../providers/accessibility_provider.dart';
import '../utils/responsive_layout.dart';
import '../utils/gesture_utils.dart';
import 'package:intl/intl.dart';

class PdfDocumentCard extends StatelessWidget {
  final PdfDocument document;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PdfDocumentCard({
    super.key,
    required this.document,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pdfService = PdfService();

    return Consumer<AccessibilityProvider>(
      builder: (context, accessibilityProvider, child) {
        final effectiveFontSize = accessibilityProvider.getEffectiveFontSize();
        final themeColors = accessibilityProvider.getEffectiveThemeColors();

        return AdaptiveBuilder(
          builder: (context, isMobile, isTablet, isDesktop) {
            if (isMobile) {
              return _buildMobileCard(
                context,
                theme,
                colorScheme,
                pdfService,
                effectiveFontSize,
                themeColors,
              );
            } else {
              return _buildTabletCard(
                context,
                theme,
                colorScheme,
                pdfService,
                effectiveFontSize,
                themeColors,
              );
            }
          },
        );
      },
    );
  }

  Widget _buildMobileCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    PdfService pdfService,
    double effectiveFontSize,
    Map<String, Color> themeColors,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveLayout.getAdaptiveBorderRadius(context),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: ResponsiveLayout.getAdaptiveBorderRadius(context),
        child: Padding(
          padding: ResponsiveLayout.getAdaptivePadding(context),
          child: Row(
            children: [
              _buildDocumentIcon(context, theme, colorScheme),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDocumentTitle(
                      context,
                      theme,
                      colorScheme,
                      effectiveFontSize,
                      themeColors,
                    ),
                    const SizedBox(height: 4),
                    _buildDocumentMetadata(
                      context,
                      theme,
                      colorScheme,
                      pdfService,
                      effectiveFontSize,
                      themeColors,
                    ),
                    const SizedBox(height: 4),
                    _buildLastOpenedInfo(
                      context,
                      theme,
                      colorScheme,
                      effectiveFontSize,
                      themeColors,
                    ),
                    if (document.lastReadPage > 1 &&
                        document.totalPages > 0) ...[
                      const SizedBox(height: 8),
                      _buildProgressIndicator(context, theme, colorScheme),
                      const SizedBox(height: 4),
                      _buildProgressText(
                        context,
                        theme,
                        colorScheme,
                        effectiveFontSize,
                      ),
                    ],
                  ],
                ),
              ),
              _buildActionButton(context, theme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    PdfService pdfService,
    double effectiveFontSize,
    Map<String, Color> themeColors,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveLayout.getAdaptiveBorderRadius(context),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: ResponsiveLayout.getAdaptiveBorderRadius(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildDocumentIcon(context, theme, colorScheme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDocumentTitle(
                          context,
                          theme,
                          colorScheme,
                          effectiveFontSize,
                          themeColors,
                        ),
                        const SizedBox(height: 4),
                        _buildDocumentMetadata(
                          context,
                          theme,
                          colorScheme,
                          pdfService,
                          effectiveFontSize,
                          themeColors,
                        ),
                      ],
                    ),
                  ),
                  _buildActionButton(context, theme, colorScheme),
                ],
              ),
            ),

            // Progress section
            if (document.lastReadPage > 1 && document.totalPages > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressIndicator(context, theme, colorScheme),
                    const SizedBox(height: 8),
                    _buildProgressText(
                      context,
                      theme,
                      colorScheme,
                      effectiveFontSize,
                    ),
                  ],
                ),
              ),
            ],

            // Footer with last opened info
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildLastOpenedInfo(
                context,
                theme,
                colorScheme,
                effectiveFontSize,
                themeColors,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentIcon(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: ResponsiveLayout.getAdaptiveIconSize(context) * 2,
      height: ResponsiveLayout.getAdaptiveIconSize(context) * 2.5,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.picture_as_pdf,
        color: colorScheme.onPrimaryContainer,
        size: ResponsiveLayout.getAdaptiveIconSize(context),
      ),
    );
  }

  Widget _buildDocumentTitle(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    double effectiveFontSize,
    Map<String, Color> themeColors,
  ) {
    return Text(
      document.name,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: effectiveFontSize,
        color: themeColors['onSurface'] ?? colorScheme.onSurface,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDocumentMetadata(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    PdfService pdfService,
    double effectiveFontSize,
    Map<String, Color> themeColors,
  ) {
    return Text(
      '${document.totalPages > 0 ? '${document.totalPages} pages' : 'PDF document'} • ${pdfService.getFileSizeString(document.fileSize)}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: themeColors['onSurfaceVariant'] ?? colorScheme.onSurfaceVariant,
        fontSize: effectiveFontSize * 0.8,
      ),
    );
  }

  Widget _buildLastOpenedInfo(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    double effectiveFontSize,
    Map<String, Color> themeColors,
  ) {
    return Text(
      'Last opened: ${_formatDate(document.lastOpened)}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: themeColors['onSurfaceVariant'] ?? colorScheme.onSurfaceVariant,
        fontSize: effectiveFontSize * 0.8,
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reading Progress',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${((document.lastReadPage / document.totalPages) * 100).round()}%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: document.lastReadPage / document.totalPages,
          backgroundColor: colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildProgressText(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    double effectiveFontSize,
  ) {
    return Text(
      'Page ${document.lastReadPage} of ${document.totalPages}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w500,
        fontSize: effectiveFontSize * 0.8,
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'delete') {
          onDelete();
        }
      },
      icon: Icon(
        Icons.more_vert,
        color: colorScheme.onSurfaceVariant,
        size: ResponsiveLayout.getAdaptiveIconSize(context),
      ),
      tooltip: 'More options',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).round();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}
