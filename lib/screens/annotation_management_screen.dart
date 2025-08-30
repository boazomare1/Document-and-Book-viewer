import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/annotation_provider.dart';
import '../models/annotation.dart';

class AnnotationManagementScreen extends StatefulWidget {
  final String documentId;
  final String documentTitle;

  const AnnotationManagementScreen({
    super.key,
    required this.documentId,
    required this.documentTitle,
  });

  @override
  State<AnnotationManagementScreen> createState() =>
      _AnnotationManagementScreenState();
}

class _AnnotationManagementScreenState extends State<AnnotationManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  AnnotationType? _filterType;
  String? _filterAuthor;
  DateTimeRange? _filterDateRange;

  String? _selectedAnnotationId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeDocument();
  }

  Future<void> _initializeDocument() async {
    final provider = context.read<AnnotationProvider>();
    await provider.initializeDocument(widget.documentId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Annotations - ${widget.documentTitle}'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Annotations'),
            Tab(text: 'By Type'),
            Tab(text: 'Version History'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _exportAnnotations,
            icon: const Icon(Icons.download),
            tooltip: 'Export Annotations',
          ),
          IconButton(
            onPressed: _importAnnotations,
            icon: const Icon(Icons.upload),
            tooltip: 'Import Annotations',
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Annotations',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(colorScheme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllAnnotationsTab(colorScheme),
                _buildByTypeTab(colorScheme),
                _buildVersionHistoryTab(colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search annotations...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: const Icon(Icons.clear),
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildAllAnnotationsTab(ColorScheme colorScheme) {
    return Consumer<AnnotationProvider>(
      builder: (context, provider, child) {
        final annotations = _getFilteredAnnotations(provider);

        if (annotations.isEmpty) {
          return _buildEmptyState(colorScheme, 'No annotations found');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: annotations.length,
          itemBuilder: (context, index) {
            final annotation = annotations[index];
            return _buildAnnotationCard(annotation, colorScheme, provider);
          },
        );
      },
    );
  }

  Widget _buildByTypeTab(ColorScheme colorScheme) {
    return Consumer<AnnotationProvider>(
      builder: (context, provider, child) {
        final stats = provider.annotationStats;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: AnnotationType.values.length,
          itemBuilder: (context, index) {
            final type = AnnotationType.values[index];
            final count = stats[type.name] ?? 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Icon(
                      _getAnnotationTypeIcon(type),
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getAnnotationTypeName(type),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        count.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                children: [
                  _buildAnnotationsByType(provider, type, colorScheme),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVersionHistoryTab(ColorScheme colorScheme) {
    return Consumer<AnnotationProvider>(
      builder: (context, provider, child) {
        if (_selectedAnnotationId == null) {
          return _buildEmptyState(
            colorScheme,
            'Select an annotation to view version history',
          );
        }

        final versions = provider.versionHistory;

        if (versions.isEmpty) {
          return _buildEmptyState(colorScheme, 'No version history found');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: versions.length,
          itemBuilder: (context, index) {
            final version = versions[index];
            return _buildVersionCard(version, colorScheme, provider);
          },
        );
      },
    );
  }

  Widget _buildAnnotationCard(
    Annotation annotation,
    ColorScheme colorScheme,
    AnnotationProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: annotation.color.withValues(
              alpha: (annotation.opacity * 255).round().toDouble(),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getAnnotationTypeIcon(annotation.type),
            color: colorScheme.onSurface,
            size: 20,
          ),
        ),
        title: Text(
          _getAnnotationTypeName(annotation.type),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Page ${annotation.pageNumber} • ${annotation.author}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (annotation.content?.isNotEmpty == true)
              Text(
                annotation.content!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              'Created: ${_formatDate(annotation.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected:
              (value) => _handleAnnotationAction(value, annotation, provider),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'history',
                  child: Row(
                    children: [
                      Icon(Icons.history),
                      SizedBox(width: 8),
                      Text('Version History'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
        onTap: () => _showAnnotationDetails(annotation, provider),
      ),
    );
  }

  Widget _buildVersionCard(
    AnnotationVersion version,
    ColorScheme colorScheme,
    AnnotationProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.history,
            color: colorScheme.onTertiaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          version.changeDescription,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'By ${version.author}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              _formatDate(version.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _restoreVersion(version, provider),
          icon: const Icon(Icons.restore),
          tooltip: 'Restore this version',
        ),
      ),
    );
  }

  Widget _buildAnnotationsByType(
    AnnotationProvider provider,
    AnnotationType type,
    ColorScheme colorScheme,
  ) {
    final annotations = provider.getAnnotationsByType(type);

    if (annotations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No annotations of this type'),
      );
    }

    return Column(
      children:
          annotations.map((annotation) {
            return _buildAnnotationCard(annotation, colorScheme, provider);
          }).toList(),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  List<Annotation> _getFilteredAnnotations(AnnotationProvider provider) {
    List<Annotation> annotations = provider.annotations;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      annotations = provider.searchAnnotations(_searchQuery);
    }

    // Apply type filter
    if (_filterType != null) {
      annotations = annotations.where((a) => a.type == _filterType).toList();
    }

    // Apply author filter
    if (_filterAuthor != null) {
      annotations =
          annotations.where((a) => a.author == _filterAuthor).toList();
    }

    // Apply date range filter
    if (_filterDateRange != null) {
      annotations =
          annotations.where((a) {
            return a.createdAt.isAfter(_filterDateRange!.start) &&
                a.createdAt.isBefore(_filterDateRange!.end);
          }).toList();
    }

    return annotations;
  }

  IconData _getAnnotationTypeIcon(AnnotationType type) {
    switch (type) {
      case AnnotationType.textHighlight:
        return Icons.highlight;
      case AnnotationType.underline:
        return Icons.format_underline;
      case AnnotationType.strikethrough:
        return Icons.format_strikethrough;
      case AnnotationType.stickyNote:
        return Icons.note;
      case AnnotationType.stamp:
        return Icons.verified;
      case AnnotationType.redaction:
        return Icons.block;
      case AnnotationType.lassoSelect:
        return Icons.crop_free;
      case AnnotationType.drawing:
        return Icons.brush;
      case AnnotationType.text:
        return Icons.text_fields;
      case AnnotationType.shape:
        return Icons.shape_line;
    }
  }

  String _getAnnotationTypeName(AnnotationType type) {
    switch (type) {
      case AnnotationType.textHighlight:
        return 'Text Highlight';
      case AnnotationType.underline:
        return 'Underline';
      case AnnotationType.strikethrough:
        return 'Strikethrough';
      case AnnotationType.stickyNote:
        return 'Sticky Note';
      case AnnotationType.stamp:
        return 'Stamp';
      case AnnotationType.redaction:
        return 'Redaction';
      case AnnotationType.lassoSelect:
        return 'Lasso Select';
      case AnnotationType.drawing:
        return 'Drawing';
      case AnnotationType.text:
        return 'Text';
      case AnnotationType.shape:
        return 'Shape';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _handleAnnotationAction(
    String action,
    Annotation annotation,
    AnnotationProvider provider,
  ) {
    switch (action) {
      case 'edit':
        _editAnnotation(annotation, provider);
        break;
      case 'history':
        _showVersionHistory(annotation, provider);
        break;
      case 'delete':
        _deleteAnnotation(annotation, provider);
        break;
    }
  }

  void _editAnnotation(Annotation annotation, AnnotationProvider provider) {
    // TODO: Implement annotation editing dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit annotation - Coming soon')),
    );
  }

  void _showVersionHistory(Annotation annotation, AnnotationProvider provider) {
    setState(() {
      _selectedAnnotationId = annotation.id;
      _tabController.animateTo(2);
    });
    provider.loadVersionHistory(annotation.id);
  }

  void _deleteAnnotation(Annotation annotation, AnnotationProvider provider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Annotation'),
            content: Text(
              'Are you sure you want to delete this ${_getAnnotationTypeName(annotation.type).toLowerCase()}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  provider.deleteAnnotation(annotation.id);
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showAnnotationDetails(
    Annotation annotation,
    AnnotationProvider provider,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(_getAnnotationTypeName(annotation.type)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Page: ${annotation.pageNumber}'),
                Text('Author: ${annotation.author}'),
                Text('Created: ${_formatDate(annotation.createdAt)}'),
                Text('Modified: ${_formatDate(annotation.modifiedAt)}'),
                if (annotation.content?.isNotEmpty == true)
                  Text('Content: ${annotation.content}'),
                if (annotation.selectedText?.isNotEmpty == true)
                  Text('Selected Text: ${annotation.selectedText}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _restoreVersion(AnnotationVersion version, AnnotationProvider provider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Restore Version'),
            content: const Text(
              'Are you sure you want to restore this version?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  provider.updateAnnotation(version.annotation);
                  Navigator.of(context).pop();
                },
                child: const Text('Restore'),
              ),
            ],
          ),
    );
  }

  void _exportAnnotations() async {
    try {
      final provider = context.read<AnnotationProvider>();
      await provider.exportToXFDF();

      // TODO: Implement file saving
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Annotations exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export annotations: $e')),
      );
    }
  }

  void _importAnnotations() async {
    // TODO: Implement file picker and import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import annotations - Coming soon')),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Annotations'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<AnnotationType>(
                  value: _filterType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...AnnotationType.values.map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_getAnnotationTypeName(type)),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterType = value;
                    });
                  },
                ),
                // TODO: Add more filter options
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _filterType = null;
                    _filterAuthor = null;
                    _filterDateRange = null;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Clear All'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
