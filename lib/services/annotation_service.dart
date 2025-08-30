import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/annotation.dart';

class AnnotationService {
  static final AnnotationService _instance = AnnotationService._internal();
  factory AnnotationService() => _instance;
  AnnotationService._internal();

  final Map<String, List<Annotation>> _annotations = {};
  final Map<String, List<AnnotationVersion>> _versionHistory = {};
  final Uuid _uuid = const Uuid();

  // Get annotations for a document
  List<Annotation> getAnnotations(String documentId) {
    return _annotations[documentId] ?? [];
  }

  // Get annotations for a specific page
  List<Annotation> getAnnotationsForPage(String documentId, int pageNumber) {
    return getAnnotations(
      documentId,
    ).where((annotation) => annotation.pageNumber == pageNumber).toList();
  }

  // Add a new annotation
  Future<Annotation> addAnnotation(Annotation annotation) async {
    final documentId = annotation.documentId;
    if (!_annotations.containsKey(documentId)) {
      _annotations[documentId] = [];
    }

    _annotations[documentId]!.add(annotation);

    // Create version history entry
    await _addVersionHistory(annotation, 'Created');

    await _saveAnnotations(documentId);
    return annotation;
  }

  // Update an existing annotation
  Future<Annotation> updateAnnotation(Annotation annotation) async {
    final documentId = annotation.documentId;
    final index = _annotations[documentId]?.indexWhere(
      (a) => a.id == annotation.id,
    );

    if (index != null && index >= 0) {
      _annotations[documentId]![index] = annotation;

      // Create version history entry
      await _addVersionHistory(annotation, 'Updated');

      await _saveAnnotations(documentId);
    }

    return annotation;
  }

  // Delete an annotation
  Future<void> deleteAnnotation(String documentId, String annotationId) async {
    _annotations[documentId]?.removeWhere((a) => a.id == annotationId);
    await _saveAnnotations(documentId);
  }

  // Get version history for an annotation
  List<AnnotationVersion> getVersionHistory(String annotationId) {
    return _versionHistory[annotationId] ?? [];
  }

  // Add version history entry
  Future<void> _addVersionHistory(
    Annotation annotation,
    String changeDescription,
  ) async {
    final version = AnnotationVersion(
      id: _uuid.v4(),
      annotationId: annotation.id,
      annotation: annotation,
      timestamp: DateTime.now(),
      author: annotation.author,
      changeDescription: changeDescription,
    );

    if (!_versionHistory.containsKey(annotation.id)) {
      _versionHistory[annotation.id] = [];
    }

    _versionHistory[annotation.id]!.add(version);
    await _saveVersionHistory(annotation.id);
  }

  // Create text highlight annotation
  Annotation createTextHighlight({
    required String documentId,
    required int pageNumber,
    required String selectedText,
    required List<int> textRanges,
    required AnnotationRectangle bounds,
    required String author,
    Color color = Colors.yellow,
    double opacity = 0.5,
  }) {
    return Annotation(
      id: _uuid.v4(),
      documentId: documentId,
      type: AnnotationType.textHighlight,
      pageNumber: pageNumber,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      author: author,
      color: color,
      opacity: opacity,
      isVisible: true,
      properties: {},
      selectedText: selectedText,
      textRanges: textRanges,
      bounds: bounds,
      version: 1,
    );
  }

  // Create sticky note annotation
  Annotation createStickyNote({
    required String documentId,
    required int pageNumber,
    required AnnotationPoint position,
    required String noteText,
    required String author,
    Color color = Colors.yellow,
  }) {
    return Annotation(
      id: _uuid.v4(),
      documentId: documentId,
      type: AnnotationType.stickyNote,
      pageNumber: pageNumber,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      author: author,
      color: color,
      opacity: 1.0,
      isVisible: true,
      properties: {},
      notePosition: position,
      noteText: noteText,
      isOpen: true,
      version: 1,
    );
  }

  // Create stamp annotation
  Annotation createStamp({
    required String documentId,
    required int pageNumber,
    required AnnotationRectangle bounds,
    required StampType stampType,
    required String author,
    String? stampText,
    String? stampImagePath,
  }) {
    return Annotation(
      id: _uuid.v4(),
      documentId: documentId,
      type: AnnotationType.stamp,
      pageNumber: pageNumber,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      author: author,
      color: _getStampColor(stampType),
      opacity: 1.0,
      isVisible: true,
      properties: {},
      bounds: bounds,
      stampType: stampType,
      stampText: stampText,
      stampImagePath: stampImagePath,
      version: 1,
    );
  }

  // Create redaction annotation
  Annotation createRedaction({
    required String documentId,
    required int pageNumber,
    required AnnotationRectangle bounds,
    required String author,
    String? redactionReason,
  }) {
    return Annotation(
      id: _uuid.v4(),
      documentId: documentId,
      type: AnnotationType.redaction,
      pageNumber: pageNumber,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      author: author,
      color: Colors.black,
      opacity: 1.0,
      isVisible: true,
      properties: {},
      bounds: bounds,
      isRedacted: true,
      redactionReason: redactionReason,
      version: 1,
    );
  }

  // Create drawing annotation
  Annotation createDrawing({
    required String documentId,
    required int pageNumber,
    required List<AnnotationPoint> points,
    required String author,
    Color color = Colors.red,
    double strokeWidth = 2.0,
    bool isFilled = false,
  }) {
    return Annotation(
      id: _uuid.v4(),
      documentId: documentId,
      type: AnnotationType.drawing,
      pageNumber: pageNumber,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      author: author,
      color: color,
      opacity: 1.0,
      isVisible: true,
      properties: {},
      points: points,
      strokeWidth: strokeWidth,
      isFilled: isFilled,
      version: 1,
    );
  }

  // Create lasso select annotation
  Annotation createLassoSelect({
    required String documentId,
    required int pageNumber,
    required List<AnnotationPoint> points,
    required String author,
    Color color = Colors.blue,
  }) {
    return Annotation(
      id: _uuid.v4(),
      documentId: documentId,
      type: AnnotationType.lassoSelect,
      pageNumber: pageNumber,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      author: author,
      color: color,
      opacity: 0.3,
      isVisible: true,
      properties: {},
      points: points,
      isFilled: true,
      version: 1,
    );
  }

  // Get stamp color based on type
  Color _getStampColor(StampType stampType) {
    switch (stampType) {
      case StampType.approved:
        return Colors.green;
      case StampType.rejected:
        return Colors.red;
      case StampType.draft:
        return Colors.orange;
      case StampType.confidential:
        return Colors.purple;
      case StampType.urgent:
        return Colors.red;
      case StampType.custom:
        return Colors.blue;
    }
  }

  // Export annotations to XFDF format
  Future<String> exportToXFDF(String documentId) async {
    final annotations = getAnnotations(documentId);
    final xfdf = _generateXFDF(annotations);
    return xfdf;
  }

  // Import annotations from XFDF format
  Future<List<Annotation>> importFromXFDF(
    String documentId,
    String xfdfContent,
  ) async {
    final annotations = _parseXFDF(xfdfContent, documentId);

    for (final annotation in annotations) {
      await addAnnotation(annotation);
    }

    return annotations;
  }

  // Generate XFDF content
  String _generateXFDF(List<Annotation> annotations) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
      '<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">',
    );
    buffer.writeln('  <annots>');

    for (final annotation in annotations) {
      buffer.writeln(_annotationToXFDF(annotation));
    }

    buffer.writeln('  </annots>');
    buffer.writeln('</xfdf>');

    return buffer.toString();
  }

  // Convert annotation to XFDF format
  String _annotationToXFDF(Annotation annotation) {
    final buffer = StringBuffer();

    switch (annotation.type) {
      case AnnotationType.textHighlight:
        buffer.writeln('    <highlight page="${annotation.pageNumber}">');
        buffer.writeln('      <rect>${_rectToXFDF(annotation.bounds!)}</rect>');
        buffer.writeln(
          '      <color>${_colorToXFDF(annotation.color)}</color>',
        );
        buffer.writeln('      <opacity>${annotation.opacity}</opacity>');
        if (annotation.selectedText != null) {
          buffer.writeln(
            '      <contents>${annotation.selectedText}</contents>',
          );
        }
        buffer.writeln('    </highlight>');
        break;

      case AnnotationType.stickyNote:
        buffer.writeln('    <text page="${annotation.pageNumber}">');
        buffer.writeln(
          '      <rect>${_pointToXFDF(annotation.notePosition!)}</rect>',
        );
        buffer.writeln(
          '      <color>${_colorToXFDF(annotation.color)}</color>',
        );
        if (annotation.noteText != null) {
          buffer.writeln('      <contents>${annotation.noteText}</contents>');
        }
        buffer.writeln('    </text>');
        break;

      case AnnotationType.stamp:
        buffer.writeln('    <stamp page="${annotation.pageNumber}">');
        buffer.writeln('      <rect>${_rectToXFDF(annotation.bounds!)}</rect>');
        buffer.writeln(
          '      <color>${_colorToXFDF(annotation.color)}</color>',
        );
        if (annotation.stampText != null) {
          buffer.writeln('      <contents>${annotation.stampText}</contents>');
        }
        buffer.writeln('    </stamp>');
        break;

      case AnnotationType.redaction:
        buffer.writeln('    <redact page="${annotation.pageNumber}">');
        buffer.writeln('      <rect>${_rectToXFDF(annotation.bounds!)}</rect>');
        buffer.writeln(
          '      <color>${_colorToXFDF(annotation.color)}</color>',
        );
        if (annotation.redactionReason != null) {
          buffer.writeln(
            '      <contents>${annotation.redactionReason}</contents>',
          );
        }
        buffer.writeln('    </redact>');
        break;

      case AnnotationType.drawing:
        buffer.writeln('    <ink page="${annotation.pageNumber}">');
        buffer.writeln(
          '      <color>${_colorToXFDF(annotation.color)}</color>',
        );
        buffer.writeln('      <width>${annotation.strokeWidth}</width>');
        buffer.writeln(
          '      <inklist>${_pointsToXFDF(annotation.points!)}</inklist>',
        );
        buffer.writeln('    </ink>');
        break;

      default:
        // Handle other annotation types
        break;
    }

    return buffer.toString();
  }

  // Convert rectangle to XFDF format
  String _rectToXFDF(AnnotationRectangle rect) {
    return '${rect.x} ${rect.y} ${rect.x + rect.width} ${rect.y + rect.height}';
  }

  // Convert point to XFDF format
  String _pointToXFDF(AnnotationPoint point) {
    return '${point.x} ${point.y}';
  }

  // Convert points to XFDF format
  String _pointsToXFDF(List<AnnotationPoint> points) {
    return points.map((p) => '${p.x} ${p.y}').join(' ');
  }

  // Convert color to XFDF format
  String _colorToXFDF(Color color) {
    return '${color.r} ${color.g} ${color.b}';
  }

  // Parse XFDF content
  List<Annotation> _parseXFDF(String xfdfContent, String documentId) {
    // This is a simplified parser - in a real implementation, you'd use XML parsing
    final annotations = <Annotation>[];

    // Parse highlights
    final highlightMatches = RegExp(
      r'<highlight page="(\d+)">(.*?)</highlight>',
      dotAll: true,
    ).allMatches(xfdfContent);
    for (final match in highlightMatches) {
      final pageNumber = int.parse(match.group(1)!);
      final content = match.group(2)!;

      final rectMatch = RegExp(r'<rect>(.*?)</rect>').firstMatch(content);
      final colorMatch = RegExp(r'<color>(.*?)</color>').firstMatch(content);
      final opacityMatch = RegExp(
        r'<opacity>(.*?)</opacity>',
      ).firstMatch(content);
      final contentsMatch = RegExp(
        r'<contents>(.*?)</contents>',
      ).firstMatch(content);

      if (rectMatch != null && colorMatch != null) {
        final rect = _parseXFDFRect(rectMatch.group(1)!);
        final color = _parseXFDFColor(colorMatch.group(1)!);
        final opacity =
            opacityMatch != null ? double.parse(opacityMatch.group(1)!) : 0.5;
        final selectedText = contentsMatch?.group(1);

        final annotation = createTextHighlight(
          documentId: documentId,
          pageNumber: pageNumber,
          selectedText: selectedText ?? '',
          textRanges: [], // Would need to be parsed from XFDF
          bounds: rect,
          author: 'Imported',
          color: color,
          opacity: opacity,
        );

        annotations.add(annotation);
      }
    }

    return annotations;
  }

  // Parse XFDF rectangle
  AnnotationRectangle _parseXFDFRect(String rectString) {
    final parts = rectString.trim().split(' ');
    if (parts.length >= 4) {
      final x = double.parse(parts[0]);
      final y = double.parse(parts[1]);
      final x2 = double.parse(parts[2]);
      final y2 = double.parse(parts[3]);

      return AnnotationRectangle(x: x, y: y, width: x2 - x, height: y2 - y);
    }

    return const AnnotationRectangle(x: 0, y: 0, width: 100, height: 100);
  }

  // Parse XFDF color
  Color _parseXFDFColor(String colorString) {
    final parts = colorString.trim().split(' ');
    if (parts.length >= 3) {
      final r = int.parse(parts[0]);
      final g = int.parse(parts[1]);
      final b = int.parse(parts[2]);

      return Color.fromARGB(255, r, g, b);
    }

    return Colors.black;
  }

  // Save annotations to local storage
  Future<void> _saveAnnotations(String documentId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/annotations_$documentId.json');

      final annotations = _annotations[documentId] ?? [];
      final jsonData = annotations.map((a) => a.toJson()).toList();

      await file.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      debugPrint('Error saving annotations: $e');
    }
  }

  // Load annotations from local storage
  Future<void> loadAnnotations(String documentId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/annotations_$documentId.json');

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonData = jsonDecode(jsonString) as List;

        _annotations[documentId] =
            jsonData
                .map(
                  (data) => Annotation.fromJson(data as Map<String, dynamic>),
                )
                .toList();
      }
    } catch (e) {
      debugPrint('Error loading annotations: $e');
    }
  }

  // Save version history
  Future<void> _saveVersionHistory(String annotationId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/version_history_$annotationId.json');

      final versions = _versionHistory[annotationId] ?? [];
      final jsonData = versions.map((v) => v.toJson()).toList();

      await file.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      debugPrint('Error saving version history: $e');
    }
  }

  // Load version history
  Future<void> loadVersionHistory(String annotationId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/version_history_$annotationId.json');

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonData = jsonDecode(jsonString) as List;

        _versionHistory[annotationId] =
            jsonData
                .map(
                  (data) =>
                      AnnotationVersion.fromJson(data as Map<String, dynamic>),
                )
                .toList();
      }
    } catch (e) {
      debugPrint('Error loading version history: $e');
    }
  }

  // Flatten annotations into PDF (placeholder for PDF generation)
  Future<Uint8List> flattenAnnotationsToPDF(
    String documentId,
    Uint8List originalPdf,
  ) async {
    // This would integrate with a PDF library to merge annotations
    // For now, return the original PDF
    return originalPdf;
  }

  // Get annotation statistics
  Map<String, dynamic> getAnnotationStats(String documentId) {
    final annotations = getAnnotations(documentId);
    final stats = <String, int>{};

    for (final type in AnnotationType.values) {
      stats[type.name] = annotations.where((a) => a.type == type).length;
    }

    return stats;
  }

  // Search annotations
  List<Annotation> searchAnnotations(String documentId, String query) {
    final annotations = getAnnotations(documentId);
    return annotations.where((annotation) {
      return annotation.content?.toLowerCase().contains(query.toLowerCase()) ==
              true ||
          annotation.selectedText?.toLowerCase().contains(
                query.toLowerCase(),
              ) ==
              true ||
          annotation.noteText?.toLowerCase().contains(query.toLowerCase()) ==
              true ||
          annotation.author.toLowerCase().contains(query.toLowerCase()) == true;
    }).toList();
  }

  // Get annotations by author
  List<Annotation> getAnnotationsByAuthor(String documentId, String author) {
    return getAnnotations(documentId).where((a) => a.author == author).toList();
  }

  // Get annotations by date range
  List<Annotation> getAnnotationsByDateRange(
    String documentId,
    DateTime start,
    DateTime end,
  ) {
    return getAnnotations(documentId).where((a) {
      return a.createdAt.isAfter(start) && a.createdAt.isBefore(end);
    }).toList();
  }
}
