import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/pdf_document.dart';

class OcrService {
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();
  final ImageLabeler _imageLabeler = GoogleMlKit.vision.imageLabeler();

  bool _isInitialized = false;

  // Initialize OCR service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize text recognizer
      await _textRecognizer.close();
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize OCR service: $e');
    }
  }

  // Extract text from image
  Future<OcrResult> extractTextFromImage(Uint8List imageBytes) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final InputImage inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: Size(0, 0), // Will be determined from image
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: 0,
        ),
      );

      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      final List<TextBlock> textBlocks = recognizedText.blocks;
      final List<String> extractedText = [];
      final List<OcrTextBlock> ocrTextBlocks = [];

      for (final TextBlock block in textBlocks) {
        final String text = block.text;
        extractedText.add(text);

        final List<OcrTextLine> ocrTextLines = [];
        for (final TextLine line in block.lines) {
          final List<OcrTextElement> ocrTextElements = [];

          for (final TextElement element in line.elements) {
            ocrTextElements.add(
              OcrTextElement(
                text: element.text,
                boundingBox: element.boundingBox,
                confidence: 0.8, // Default confidence
              ),
            );
          }

          ocrTextLines.add(
            OcrTextLine(
              text: line.text,
              boundingBox: line.boundingBox,
              elements: ocrTextElements,
            ),
          );
        }

        ocrTextBlocks.add(
          OcrTextBlock(
            text: text,
            boundingBox: block.boundingBox,
            confidence: 0.8, // Default confidence
            lines: ocrTextLines,
          ),
        );
      }

      return OcrResult(
        text: extractedText.join('\n'),
        textBlocks: ocrTextBlocks,
        confidence: _calculateAverageConfidence(ocrTextBlocks),
        language: _detectLanguage(extractedText.join(' ')),
      );
    } catch (e) {
      throw Exception('Failed to extract text from image: $e');
    }
  }

  // Extract text from PDF page image
  Future<OcrResult> extractTextFromPdfPage(
    String pdfPath,
    int pageNumber,
  ) async {
    try {
      // In a real implementation, you would:
      // 1. Load the PDF document
      // 2. Render the specific page to an image
      // 3. Extract text from the rendered image

      // For now, return a placeholder result
      return OcrResult(
        text: 'OCR text extraction for page $pageNumber',
        textBlocks: [],
        confidence: 0.8,
        language: 'en',
      );
    } catch (e) {
      throw Exception('Failed to extract text from PDF page: $e');
    }
  }

  // Process scanned PDF document
  Future<ScannedPdfResult> processScannedPdf(String pdfPath) async {
    try {
      // In a real implementation, you would:
      // 1. Load the PDF document
      // 2. Render each page to an image
      // 3. Extract text from each page
      // 4. Create a searchable PDF with extracted text

      final List<OcrResult> pageResults = [];
      final int totalPages = 10; // Placeholder

      for (int i = 1; i <= totalPages; i++) {
        final result = await extractTextFromPdfPage(pdfPath, i);
        pageResults.add(result);
      }

      return ScannedPdfResult(
        originalPath: pdfPath,
        searchablePath: _generateSearchablePdfPath(pdfPath),
        pageResults: pageResults,
        totalPages: totalPages,
        averageConfidence: _calculateAverageConfidenceFromResults(pageResults),
        processingTime: Duration(seconds: 5), // Placeholder
      );
    } catch (e) {
      throw Exception('Failed to process scanned PDF: $e');
    }
  }

  // Detect language from text
  String _detectLanguage(String text) {
    // Simple language detection based on character sets
    if (text.contains(RegExp(r'[а-яё]', caseSensitive: false))) {
      return 'ru';
    } else if (text.contains(RegExp(r'[一-龯]'))) {
      return 'zh';
    } else if (text.contains(RegExp(r'[あ-ん]'))) {
      return 'ja';
    } else if (text.contains(RegExp(r'[가-힣]'))) {
      return 'ko';
    } else if (text.contains(RegExp(r'[ا-ي]'))) {
      return 'ar';
    } else {
      return 'en';
    }
  }

  // Calculate average confidence
  double _calculateAverageConfidence(List<OcrTextBlock> textBlocks) {
    if (textBlocks.isEmpty) return 0.0;

    final double totalConfidence = textBlocks.fold<double>(
      0.0,
      (sum, block) => sum + block.confidence,
    );

    return totalConfidence / textBlocks.length;
  }

  // Calculate average confidence from multiple results
  double _calculateAverageConfidenceFromResults(List<OcrResult> results) {
    if (results.isEmpty) return 0.0;

    final double totalConfidence = results.fold<double>(
      0.0,
      (sum, result) => sum + result.confidence,
    );

    return totalConfidence / results.length;
  }

  // Generate searchable PDF path
  String _generateSearchablePdfPath(String originalPath) {
    final String fileName = path.basenameWithoutExtension(originalPath);
    final String extension = path.extension(originalPath);
    return '${fileName}_searchable$extension';
  }

  // Check if PDF is scanned (no text content)
  Future<bool> isScannedPdf(String pdfPath) async {
    try {
      // In a real implementation, you would:
      // 1. Load the PDF document
      // 2. Check if it contains text content
      // 3. Return true if no text content is found

      // For now, return false (assume it's not scanned)
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get OCR statistics
  Future<OcrStatistics> getOcrStatistics(String pdfPath) async {
    try {
      final bool isScanned = await isScannedPdf(pdfPath);

      return OcrStatistics(
        isScanned: isScanned,
        totalPages: 10, // Placeholder
        processedPages: isScanned ? 10 : 0,
        averageConfidence: isScanned ? 0.85 : 0.0,
        languages: isScanned ? ['en'] : [],
        processingTime: isScanned ? Duration(seconds: 30) : Duration.zero,
      );
    } catch (e) {
      return OcrStatistics(
        isScanned: false,
        totalPages: 0,
        processedPages: 0,
        averageConfidence: 0.0,
        languages: [],
        processingTime: Duration.zero,
      );
    }
  }

  // Batch process multiple PDFs
  Future<List<ScannedPdfResult>> batchProcessPdfs(List<String> pdfPaths) async {
    final List<ScannedPdfResult> results = [];

    for (final String pdfPath in pdfPaths) {
      try {
        final bool isScanned = await isScannedPdf(pdfPath);
        if (isScanned) {
          final result = await processScannedPdf(pdfPath);
          results.add(result);
        }
      } catch (e) {
        print('Failed to process PDF $pdfPath: $e');
      }
    }

    return results;
  }

  // Clean up resources
  Future<void> dispose() async {
    try {
      await _textRecognizer.close();
      await _imageLabeler.close();
      _isInitialized = false;
    } catch (e) {
      print('Failed to dispose OCR service: $e');
    }
  }
}

class OcrResult {
  final String text;
  final List<OcrTextBlock> textBlocks;
  final double confidence;
  final String language;

  const OcrResult({
    required this.text,
    required this.textBlocks,
    required this.confidence,
    required this.language,
  });
}

class OcrTextBlock {
  final String text;
  final Rect boundingBox;
  final double confidence;
  final List<OcrTextLine> lines;

  const OcrTextBlock({
    required this.text,
    required this.boundingBox,
    required this.confidence,
    required this.lines,
  });
}

class OcrTextLine {
  final String text;
  final Rect boundingBox;
  final List<OcrTextElement> elements;

  const OcrTextLine({
    required this.text,
    required this.boundingBox,
    required this.elements,
  });
}

class OcrTextElement {
  final String text;
  final Rect boundingBox;
  final double confidence;

  const OcrTextElement({
    required this.text,
    required this.boundingBox,
    required this.confidence,
  });
}

class ScannedPdfResult {
  final String originalPath;
  final String searchablePath;
  final List<OcrResult> pageResults;
  final int totalPages;
  final double averageConfidence;
  final Duration processingTime;

  const ScannedPdfResult({
    required this.originalPath,
    required this.searchablePath,
    required this.pageResults,
    required this.totalPages,
    required this.averageConfidence,
    required this.processingTime,
  });
}

class OcrStatistics {
  final bool isScanned;
  final int totalPages;
  final int processedPages;
  final double averageConfidence;
  final List<String> languages;
  final Duration processingTime;

  const OcrStatistics({
    required this.isScanned,
    required this.totalPages,
    required this.processedPages,
    required this.averageConfidence,
    required this.languages,
    required this.processingTime,
  });
}
