import 'package:flutter/material.dart';
import '../models/pdf_document.dart';
import '../services/pdf_service.dart';
import 'package:uuid/uuid.dart';

class PdfProvider extends ChangeNotifier {
  final PdfService _pdfService = PdfService();
  final Uuid _uuid = const Uuid();

  List<PdfDocument> _documents = [];
  PdfDocument? _currentDocument;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PdfDocument> get documents => _documents;
  PdfDocument? get currentDocument => _currentDocument;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load documents from storage
  Future<void> loadDocuments() async {
    _setLoading(true);
    try {
      _documents = await _pdfService.loadDocuments();

      // Check if any documents have zero page counts and need updating
      bool needsUpdate = false;
      for (int i = 0; i < _documents.length; i++) {
        if (_documents[i].totalPages == 0) {
          // Mark for update - we'll update these when they're opened
          needsUpdate = true;
        }
      }

      if (needsUpdate) {
        // Notify listeners to show that some documents need page count updates
        notifyListeners();
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to load documents: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Add a new PDF document
  Future<void> addDocument(String filePath) async {
    _setLoading(true);
    try {
      final document = await _pdfService.createDocumentFromFile(filePath);
      _documents.insert(0, document);
      await _pdfService.saveDocuments(_documents);
      _error = null;
    } catch (e) {
      _error = 'Failed to add document: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Open a PDF document
  Future<void> openDocument(PdfDocument document) async {
    _setLoading(true);
    try {
      final updatedDocument = document.copyWith(lastOpened: DateTime.now());

      // Update in the list
      final index = _documents.indexWhere((d) => d.id == document.id);
      if (index != -1) {
        _documents[index] = updatedDocument;
        await _pdfService.saveDocuments(_documents);
      }

      _currentDocument = updatedDocument;
      _error = null;
    } catch (e) {
      _error = 'Failed to open document: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Update reading progress
  Future<void> updateReadingProgress(String documentId, int pageNumber) async {
    try {
      final index = _documents.indexWhere((d) => d.id == documentId);
      if (index != -1) {
        _documents[index] = _documents[index].copyWith(
          lastReadPage: pageNumber,
          lastOpened: DateTime.now(),
        );

        if (_currentDocument?.id == documentId) {
          _currentDocument = _documents[index];
        }

        await _pdfService.saveDocuments(_documents);
      }
    } catch (e) {
      _error = 'Failed to update progress: $e';
      notifyListeners();
    }
  }

  // Update document total pages
  Future<void> updateDocumentTotalPages(
    String documentId,
    int totalPages,
  ) async {
    try {
      final index = _documents.indexWhere((d) => d.id == documentId);
      if (index != -1) {
        _documents[index] = _documents[index].copyWith(totalPages: totalPages);

        if (_currentDocument?.id == documentId) {
          _currentDocument = _documents[index];
        }

        await _pdfService.saveDocuments(_documents);
        notifyListeners(); // Notify listeners to update UI
      }
    } catch (e) {
      _error = 'Failed to update total pages: $e';
      notifyListeners();
    }
  }

  // Force refresh all documents (useful for updating existing documents)
  Future<void> refreshAllDocuments() async {
    try {
      // This will trigger a reload of all documents and update the UI
      await loadDocuments();
    } catch (e) {
      _error = 'Failed to refresh documents: $e';
      notifyListeners();
    }
  }

  // Remove a document
  Future<void> removeDocument(String documentId) async {
    try {
      _documents.removeWhere((d) => d.id == documentId);
      if (_currentDocument?.id == documentId) {
        _currentDocument = null;
      }
      await _pdfService.saveDocuments(_documents);
    } catch (e) {
      _error = 'Failed to remove document: $e';
      notifyListeners();
    }
  }

  // Clear current document
  void clearCurrentDocument() {
    _currentDocument = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
