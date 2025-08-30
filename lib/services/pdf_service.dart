import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/pdf_document.dart';
import 'package:uuid/uuid.dart';

class PdfService {
  static const String _documentsFileName = 'pdf_documents.json';
  final Uuid _uuid = const Uuid();

  // Get the documents directory
  Future<Directory> get _documentsDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final documentsDir = Directory('${appDir.path}/pdf_documents');
    if (!await documentsDir.exists()) {
      await documentsDir.create(recursive: true);
    }
    return documentsDir;
  }

  // Get the documents file
  Future<File> get _documentsFile async {
    final appDir = await getApplicationDocumentsDirectory();
    return File('${appDir.path}/$_documentsFileName');
  }

  // Load documents from storage
  Future<List<PdfDocument>> loadDocuments() async {
    try {
      final file = await _documentsFile;
      if (!await file.exists()) {
        return [];
      }

      final jsonString = await file.readAsString();
      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((json) => PdfDocument.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load documents: $e');
    }
  }

  // Save documents to storage
  Future<void> saveDocuments(List<PdfDocument> documents) async {
    try {
      final file = await _documentsFile;
      final jsonList = documents.map((doc) => doc.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await file.writeAsString(jsonString);
    } catch (e) {
      throw Exception('Failed to save documents: $e');
    }
  }

  // Create a PDF document from file
  Future<PdfDocument> createDocumentFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final fileName = file.path.split('/').last;
      final fileSize = await file.length();
      final now = DateTime.now();

      // Generate a unique ID
      final id = _uuid.v4();

      // Copy file to app documents directory
      final documentsDir = await _documentsDirectory;
      final copiedFilePath = '${documentsDir.path}/$id.pdf';
      await file.copy(copiedFilePath);

      return PdfDocument(
        id: id,
        name: fileName,
        path: copiedFilePath,
        lastOpened: now,
        totalPages: 0, // Will be updated when PDF is first opened
        fileSize: fileSize.toDouble(),
        dateAdded: now,
      );
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  // Get file size in human readable format
  String getFileSizeString(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(1)} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Delete a document file
  Future<void> deleteDocumentFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Check if file is a valid PDF
  Future<bool> isValidPdf(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final bytes = await file.openRead(0, 4).first;
      // Check for PDF magic number
      return bytes.length >= 4 &&
          bytes[0] == 0x25 && // %
          bytes[1] == 0x50 && // P
          bytes[2] == 0x44 && // D
          bytes[3] == 0x46; // F
    } catch (e) {
      return false;
    }
  }
}
