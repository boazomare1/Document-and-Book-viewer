import 'package:flutter/material.dart';
import '../models/annotation.dart';

class AnnotationToolbar extends StatefulWidget {
  final AnnotationType? selectedTool;
  final Function(AnnotationType) onToolSelected;
  final Function(Color) onColorChanged;
  final Function(double) onOpacityChanged;
  final Function(double) onStrokeWidthChanged;
  final Color currentColor;
  final double currentOpacity;
  final double currentStrokeWidth;
  final bool isVisible;

  const AnnotationToolbar({
    super.key,
    this.selectedTool,
    required this.onToolSelected,
    required this.onColorChanged,
    required this.onOpacityChanged,
    required this.onStrokeWidthChanged,
    required this.currentColor,
    required this.currentOpacity,
    required this.currentStrokeWidth,
    required this.isVisible,
  });

  @override
  State<AnnotationToolbar> createState() => _AnnotationToolbarState();
}

class _AnnotationToolbarState extends State<AnnotationToolbar> {
  bool _showColorPicker = false;
  bool _showOpacitySlider = false;
  bool _showStrokeWidthSlider = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolSection(colorScheme),
          if (_showColorPicker) _buildColorPicker(colorScheme),
          if (_showOpacitySlider) _buildOpacitySlider(colorScheme),
          if (_showStrokeWidthSlider) _buildStrokeWidthSlider(colorScheme),
        ],
      ),
    );
  }

  Widget _buildToolSection(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Annotation Tools',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _buildToolButton(
                AnnotationType.textHighlight,
                Icons.highlight,
                'Highlight',
                colorScheme,
              ),
              _buildToolButton(
                AnnotationType.underline,
                Icons.format_underline,
                'Underline',
                colorScheme,
              ),
              _buildToolButton(
                AnnotationType.strikethrough,
                Icons.format_strikethrough,
                'Strikethrough',
                colorScheme,
              ),
              _buildToolButton(
                AnnotationType.stickyNote,
                Icons.note,
                'Sticky Note',
                colorScheme,
              ),
              _buildToolButton(
                AnnotationType.stamp,
                Icons.verified,
                'Stamp',
                colorScheme,
              ),
              _buildToolButton(
                AnnotationType.redaction,
                Icons.block,
                'Redact',
                colorScheme,
              ),
              _buildToolButton(
                AnnotationType.lassoSelect,
                Icons.crop_free,
                'Lasso Select',
                colorScheme,
              ),
              _buildToolButton(
                AnnotationType.drawing,
                Icons.brush,
                'Draw',
                colorScheme,
              ),
              _buildToolButton(
                AnnotationType.text,
                Icons.text_fields,
                'Text',
                colorScheme,
              ),
              _buildToolButton(
                AnnotationType.shape,
                Icons.shape_line,
                'Shape',
                colorScheme,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildColorButton(colorScheme),
          if (_isDrawingTool) _buildStrokeWidthButton(colorScheme),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    AnnotationType tool,
    IconData icon,
    String label,
    ColorScheme colorScheme,
  ) {
    final isSelected = widget.selectedTool == tool;

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () => widget.onToolSelected(tool),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border:
                isSelected
                    ? Border.all(color: colorScheme.primary, width: 2)
                    : null,
          ),
          child: Icon(
            icon,
            size: 20,
            color:
                isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(ColorScheme colorScheme) {
    return InkWell(
      onTap: () {
        setState(() {
          _showColorPicker = !_showColorPicker;
          if (_showColorPicker) {
            _showOpacitySlider = false;
            _showStrokeWidthSlider = false;
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: widget.currentColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: colorScheme.outline),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Color',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              _showColorPicker ? Icons.expand_less : Icons.expand_more,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrokeWidthButton(ColorScheme colorScheme) {
    return InkWell(
      onTap: () {
        setState(() {
          _showStrokeWidthSlider = !_showStrokeWidthSlider;
          if (_showStrokeWidthSlider) {
            _showColorPicker = false;
            _showOpacitySlider = false;
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.line_weight,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Stroke',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              _showStrokeWidthSlider ? Icons.expand_less : Icons.expand_more,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(ColorScheme colorScheme) {
    final colors = [
      Colors.yellow,
      Colors.orange,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.cyan,
      Colors.green,
      Colors.lime,
      Colors.brown,
      Colors.grey,
      Colors.black,
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Color',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children:
                colors.map((color) {
                  final isSelected = widget.currentColor == color;
                  return GestureDetector(
                    onTap: () {
                      widget.onColorChanged(color);
                      setState(() {
                        _showOpacitySlider = true;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color:
                              isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOpacitySlider(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Opacity',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${(widget.currentOpacity * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: widget.currentOpacity,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            onChanged: widget.onOpacityChanged,
            activeColor: colorScheme.primary,
            inactiveColor: colorScheme.outline,
          ),
        ],
      ),
    );
  }

  Widget _buildStrokeWidthSlider(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stroke Width',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${widget.currentStrokeWidth.round()}px',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: widget.currentStrokeWidth,
            min: 1.0,
            max: 10.0,
            divisions: 9,
            onChanged: widget.onStrokeWidthChanged,
            activeColor: colorScheme.primary,
            inactiveColor: colorScheme.outline,
          ),
        ],
      ),
    );
  }

  bool get _isDrawingTool {
    return widget.selectedTool == AnnotationType.drawing ||
        widget.selectedTool == AnnotationType.lassoSelect ||
        widget.selectedTool == AnnotationType.shape;
  }
}
