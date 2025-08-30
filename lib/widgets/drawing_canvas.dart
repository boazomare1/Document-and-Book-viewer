import 'package:flutter/material.dart';
import '../models/annotation.dart';

// Temporary DrawingPoint class for backward compatibility
class DrawingPoint {
  final double x;
  final double y;
  final double pressure;

  const DrawingPoint({required this.x, required this.y, this.pressure = 1.0});

  AnnotationPoint toAnnotationPoint() {
    return AnnotationPoint(x, y);
  }

  static DrawingPoint fromAnnotationPoint(AnnotationPoint point) {
    return DrawingPoint(x: point.x, y: point.y);
  }
}

class DrawingCanvas extends StatefulWidget {
  final Color strokeColor;
  final double strokeWidth;
  final Function(List<DrawingPoint>) onDrawingComplete;
  final VoidCallback? onDrawingStart;
  final VoidCallback? onDrawingCancel;

  const DrawingCanvas({
    super.key,
    required this.strokeColor,
    required this.strokeWidth,
    required this.onDrawingComplete,
    this.onDrawingStart,
    this.onDrawingCancel,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<DrawingPoint> _currentPath = [];
  List<List<DrawingPoint>> _paths = [];
  bool _isDrawing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        painter: DrawingPainter(
          paths: _paths,
          currentPath: _currentPath,
          strokeColor: widget.strokeColor,
          strokeWidth: widget.strokeWidth,
        ),
        size: Size.infinite,
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDrawing = true;
      _currentPath = [
        DrawingPoint(
          x: details.localPosition.dx,
          y: details.localPosition.dy,
          pressure: 1.0,
        ),
      ];
    });
    widget.onDrawingStart?.call();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawing) return;

    setState(() {
      _currentPath.add(
        DrawingPoint(
          x: details.localPosition.dx,
          y: details.localPosition.dy,
          pressure: 1.0,
        ),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDrawing) return;

    setState(() {
      _isDrawing = false;
      if (_currentPath.length > 1) {
        _paths.add(List.from(_currentPath));
        widget.onDrawingComplete(_currentPath);
      }
      _currentPath = [];
    });
  }

  void clear() {
    setState(() {
      _paths.clear();
      _currentPath.clear();
      _isDrawing = false;
    });
  }

  void undo() {
    if (_paths.isNotEmpty) {
      setState(() {
        _paths.removeLast();
      });
    }
  }

  bool get hasPaths => _paths.isNotEmpty;
}

class DrawingPainter extends CustomPainter {
  final List<List<DrawingPoint>> paths;
  final List<DrawingPoint> currentPath;
  final Color strokeColor;
  final double strokeWidth;

  DrawingPainter({
    required this.paths,
    required this.currentPath,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = strokeColor
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

    // Draw completed paths
    for (final path in paths) {
      _drawPath(canvas, path, paint);
    }

    // Draw current path
    if (currentPath.isNotEmpty) {
      _drawPath(canvas, currentPath, paint);
    }
  }

  void _drawPath(Canvas canvas, List<DrawingPoint> points, Paint paint) {
    if (points.length < 2) return;

    final path = Path();
    path.moveTo(points.first.x, points.first.y);

    for (int i = 1; i < points.length; i++) {
      final point = points[i];
      path.lineTo(point.x, point.y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.paths != paths ||
        oldDelegate.currentPath != currentPath ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
