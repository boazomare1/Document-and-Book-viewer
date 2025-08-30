import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/annotation.dart';
import '../services/annotation_service.dart';

class AnnotationProvider extends ChangeNotifier {
  final AnnotationService _annotationService = AnnotationService();

  String? _currentDocumentId;
  AnnotationType? _selectedTool;
  Color _currentColor = Colors.yellow;
  double _currentOpacity = 0.5;
  double _currentStrokeWidth = 2.0;
  bool _isAnnotationMode = false;
  List<Annotation> _annotations = [];
  List<AnnotationVersion> _versionHistory = [];
  Map<String, dynamic> _annotationStats = {};

  // Getters
  String? get currentDocumentId => _currentDocumentId;
  AnnotationType? get selectedTool => _selectedTool;
  Color get currentColor => _currentColor;
  double get currentOpacity => _currentOpacity;
  double get currentStrokeWidth => _currentStrokeWidth;
  bool get isAnnotationMode => _isAnnotationMode;
  List<Annotation> get annotations => _annotations;
  List<AnnotationVersion> get versionHistory => _versionHistory;
  Map<String, dynamic> get annotationStats => _annotationStats;

  // Initialize provider for a document
  Future<void> initializeDocument(String documentId) async {
    _currentDocumentId = documentId;
    await _annotationService.loadAnnotations(documentId);
    _annotations = _annotationService.getAnnotations(documentId);
    _annotationStats = _annotationService.getAnnotationStats(documentId);
    notifyListeners();
  }

  // Tool selection
  void selectTool(AnnotationType tool) {
    _selectedTool = _selectedTool == tool ? null : tool;
    _isAnnotationMode = _selectedTool != null;
    notifyListeners();
  }

  void clearTool() {
    _selectedTool = null;
    _isAnnotationMode = false;
    notifyListeners();
  }

  // Color and style settings
  void setColor(Color color) {
    _currentColor = color;
    notifyListeners();
  }

  void setOpacity(double opacity) {
    _currentOpacity = opacity;
    notifyListeners();
  }

  void setStrokeWidth(double strokeWidth) {
    _currentStrokeWidth = strokeWidth;
    notifyListeners();
  }

  // Annotation creation methods
  Future<Annotation> createTextHighlight({
    required int pageNumber,
    required String selectedText,
    required List<int> textRanges,
    required AnnotationRectangle bounds,
    required String author,
  }) async {
    if (_currentDocumentId == null) {
      throw Exception('No document loaded');
    }

    final annotation = _annotationService.createTextHighlight(
      documentId: _currentDocumentId!,
      pageNumber: pageNumber,
      selectedText: selectedText,
      textRanges: textRanges,
      bounds: bounds,
      author: author,
      color: _currentColor,
      opacity: _currentOpacity,
    );

    await _annotationService.addAnnotation(annotation);
    _annotations = _annotationService.getAnnotations(_currentDocumentId!);
    _annotationStats = _annotationService.getAnnotationStats(
      _currentDocumentId!,
    );
    notifyListeners();

    return annotation;
  }

  Future<Annotation> createStickyNote({
    required int pageNumber,
    required AnnotationPoint position,
    required String noteText,
    required String author,
  }) async {
    if (_currentDocumentId == null) {
      throw Exception('No document loaded');
    }

    final annotation = _annotationService.createStickyNote(
      documentId: _currentDocumentId!,
      pageNumber: pageNumber,
      position: position,
      noteText: noteText,
      author: author,
      color: _currentColor,
    );

    await _annotationService.addAnnotation(annotation);
    _annotations = _annotationService.getAnnotations(_currentDocumentId!);
    _annotationStats = _annotationService.getAnnotationStats(
      _currentDocumentId!,
    );
    notifyListeners();

    return annotation;
  }

  Future<Annotation> createStamp({
    required int pageNumber,
    required AnnotationRectangle bounds,
    required StampType stampType,
    required String author,
    String? stampText,
    String? stampImagePath,
  }) async {
    if (_currentDocumentId == null) {
      throw Exception('No document loaded');
    }

    final annotation = _annotationService.createStamp(
      documentId: _currentDocumentId!,
      pageNumber: pageNumber,
      bounds: bounds,
      stampType: stampType,
      author: author,
      stampText: stampText,
      stampImagePath: stampImagePath,
    );

    await _annotationService.addAnnotation(annotation);
    _annotations = _annotationService.getAnnotations(_currentDocumentId!);
    _annotationStats = _annotationService.getAnnotationStats(
      _currentDocumentId!,
    );
    notifyListeners();

    return annotation;
  }

  Future<Annotation> createRedaction({
    required int pageNumber,
    required AnnotationRectangle bounds,
    required String author,
    String? redactionReason,
  }) async {
    if (_currentDocumentId == null) {
      throw Exception('No document loaded');
    }

    final annotation = _annotationService.createRedaction(
      documentId: _currentDocumentId!,
      pageNumber: pageNumber,
      bounds: bounds,
      author: author,
      redactionReason: redactionReason,
    );

    await _annotationService.addAnnotation(annotation);
    _annotations = _annotationService.getAnnotations(_currentDocumentId!);
    _annotationStats = _annotationService.getAnnotationStats(
      _currentDocumentId!,
    );
    notifyListeners();

    return annotation;
  }

  Future<Annotation> createDrawing({
    required int pageNumber,
    required List<AnnotationPoint> points,
    required String author,
    bool isFilled = false,
  }) async {
    if (_currentDocumentId == null) {
      throw Exception('No document loaded');
    }

    final annotation = _annotationService.createDrawing(
      documentId: _currentDocumentId!,
      pageNumber: pageNumber,
      points: points,
      author: author,
      color: _currentColor,
      strokeWidth: _currentStrokeWidth,
      isFilled: isFilled,
    );

    await _annotationService.addAnnotation(annotation);
    _annotations = _annotationService.getAnnotations(_currentDocumentId!);
    _annotationStats = _annotationService.getAnnotationStats(
      _currentDocumentId!,
    );
    notifyListeners();

    return annotation;
  }

  Future<Annotation> createLassoSelect({
    required int pageNumber,
    required List<AnnotationPoint> points,
    required String author,
  }) async {
    if (_currentDocumentId == null) {
      throw Exception('No document loaded');
    }

    final annotation = _annotationService.createLassoSelect(
      documentId: _currentDocumentId!,
      pageNumber: pageNumber,
      points: points,
      author: author,
      color: _currentColor,
    );

    await _annotationService.addAnnotation(annotation);
    _annotations = _annotationService.getAnnotations(_currentDocumentId!);
    _annotationStats = _annotationService.getAnnotationStats(
      _currentDocumentId!,
    );
    notifyListeners();

    return annotation;
  }

  // Annotation management
  Future<void> updateAnnotation(Annotation annotation) async {
    await _annotationService.updateAnnotation(annotation);
    _annotations = _annotationService.getAnnotations(_currentDocumentId!);
    _annotationStats = _annotationService.getAnnotationStats(
      _currentDocumentId!,
    );
    notifyListeners();
  }

  Future<void> deleteAnnotation(String annotationId) async {
    if (_currentDocumentId == null) {
      throw Exception('No document loaded');
    }

    await _annotationService.deleteAnnotation(
      _currentDocumentId!,
      annotationId,
    );
    _annotations = _annotationService.getAnnotations(_currentDocumentId!);
    _annotationStats = _annotationService.getAnnotationStats(
      _currentDocumentId!,
    );
    notifyListeners();
  }

  // Get annotations for specific page
  List<Annotation> getAnnotationsForPage(int pageNumber) {
    if (_currentDocumentId == null) return [];
    return _annotationService.getAnnotationsForPage(
      _currentDocumentId!,
      pageNumber,
    );
  }

  // Version history
  Future<void> loadVersionHistory(String annotationId) async {
    await _annotationService.loadVersionHistory(annotationId);
    _versionHistory = _annotationService.getVersionHistory(annotationId);
    notifyListeners();
  }

  // Search and filtering
  List<Annotation> searchAnnotations(String query) {
    if (_currentDocumentId == null) return [];
    return _annotationService.searchAnnotations(_currentDocumentId!, query);
  }

  List<Annotation> getAnnotationsByAuthor(String author) {
    if (_currentDocumentId == null) return [];
    return _annotationService.getAnnotationsByAuthor(
      _currentDocumentId!,
      author,
    );
  }

  List<Annotation> getAnnotationsByDateRange(DateTime start, DateTime end) {
    if (_currentDocumentId == null) return [];
    return _annotationService.getAnnotationsByDateRange(
      _currentDocumentId!,
      start,
      end,
    );
  }

  // XFDF import/export
  Future<String> exportToXFDF() async {
    if (_currentDocumentId == null) {
      throw Exception('No document loaded');
    }
    return await _annotationService.exportToXFDF(_currentDocumentId!);
  }

  Future<List<Annotation>> importFromXFDF(String xfdfContent) async {
    if (_currentDocumentId == null) {
      throw Exception('No document loaded');
    }

    final importedAnnotations = await _annotationService.importFromXFDF(
      _currentDocumentId!,
      xfdfContent,
    );
    _annotations = _annotationService.getAnnotations(_currentDocumentId!);
    _annotationStats = _annotationService.getAnnotationStats(
      _currentDocumentId!,
    );
    notifyListeners();

    return importedAnnotations;
  }

  // PDF flattening
  Future<Uint8List> flattenAnnotationsToPDF(Uint8List originalPdf) async {
    if (_currentDocumentId == null) {
      throw Exception('No document loaded');
    }
    return await _annotationService.flattenAnnotationsToPDF(
      _currentDocumentId!,
      originalPdf,
    );
  }

  // Table of contents
  List<TableOfContentsItem> get tableOfContents {
    // TODO: Implement actual table of contents extraction from PDF
    // For now, return a placeholder structure
    return [
      const TableOfContentsItem(title: 'Introduction', pageNumber: 1, level: 0),
      const TableOfContentsItem(
        title: 'Chapter 1',
        pageNumber: 5,
        level: 0,
        children: [
          TableOfContentsItem(title: 'Section 1.1', pageNumber: 6, level: 1),
          TableOfContentsItem(title: 'Section 1.2', pageNumber: 12, level: 1),
        ],
      ),
      const TableOfContentsItem(title: 'Chapter 2', pageNumber: 20, level: 0),
    ];
  }

  // Utility methods
  bool hasAnnotations(int pageNumber) {
    return getAnnotationsForPage(pageNumber).isNotEmpty;
  }

  int getAnnotationCount(int pageNumber) {
    return getAnnotationsForPage(pageNumber).length;
  }

  List<Annotation> getAnnotationsByType(AnnotationType type) {
    return _annotations.where((a) => a.type == type).toList();
  }

  void clearAllAnnotations() {
    if (_currentDocumentId == null) return;

    _annotations.clear();
    _annotationStats.clear();
    notifyListeners();
  }


}
