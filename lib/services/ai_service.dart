import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/ai_models.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final Uuid _uuid = const Uuid();
  final Map<String, String> _apiKeys = {};
  final Map<String, dynamic> _cache = {};
  final Map<String, List<SearchResult>> _searchIndex = {};

  // API Configuration
  static const String _openaiBaseUrl = 'https://api.openai.com/v1';
  static const String _googleTranslateUrl =
      'https://translation.googleapis.com/language/translate/v2';
  static const String _tesseractUrl = 'https://api.ocr.space/parse/image';

  // Initialize API keys
  Future<void> initialize({
    String? openaiApiKey,
    String? googleApiKey,
    String? ocrApiKey,
  }) async {
    if (openaiApiKey != null) _apiKeys['openai'] = openaiApiKey;
    if (googleApiKey != null) _apiKeys['google'] = googleApiKey;
    if (ocrApiKey != null) _apiKeys['ocr'] = ocrApiKey;
  }

  // PDF Summarization
  Future<PDFSummary> summarizePDF({
    required String documentId,
    required String content,
    required int totalPages,
    SummaryType type = SummaryType.brief,
    int maxLength = 500,
  }) async {
    final cacheKey = 'summary_${documentId}_${type.name}_$maxLength';

    if (_cache.containsKey(cacheKey)) {
      return PDFSummary.fromJson(_cache[cacheKey]);
    }

    try {
      final prompt = _buildSummaryPrompt(content, type, maxLength);
      final response = await _callOpenAI(prompt, maxTokens: 1000);

      final summary = PDFSummary(
        id: _uuid.v4(),
        documentId: documentId,
        type: type,
        content: response,
        wordCount: response.split(' ').length,
        confidence: _calculateConfidence(response),
        createdAt: DateTime.now(),
        keyPoints: _extractKeyPoints(response),
        estimatedReadingTime: _calculateReadingTime(response),
      );

      _cache[cacheKey] = summary.toJson();
      return summary;
    } catch (e) {
      throw AIException('Failed to summarize PDF: $e');
    }
  }

  // Q&A about PDF content
  Future<QAAnswer> askQuestion({
    required String documentId,
    required String question,
    required String context,
    int pageNumber = 0,
  }) async {
    try {
      final prompt = _buildQAPrompt(question, context, pageNumber.toString());
      final response = await _callOpenAI(prompt, maxTokens: 500);

      final answer = QAAnswer(
        id: _uuid.v4(),
        documentId: documentId,
        question: question,
        answer: response,
        confidence: _calculateConfidence(response),
        createdAt: DateTime.now(),
        sources: _extractSources(response, context),
        pageNumber: pageNumber,
      );

      return answer;
    } catch (e) {
      throw AIException('Failed to answer question: $e');
    }
  }

  // Text Translation
  Future<Translation> translateText({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'auto',
  }) async {
    try {
      if (_apiKeys['google'] != null) {
        return await _translateWithGoogle(text, targetLanguage, sourceLanguage);
      } else {
        return await _translateWithOpenAI(text, targetLanguage, sourceLanguage);
      }
    } catch (e) {
      throw AIException('Failed to translate text: $e');
    }
  }

  // Semantic Search
  Future<List<SearchResult>> semanticSearch({
    required String query,
    required String documentId,
    required String content,
    int maxResults = 10,
  }) async {
    try {
      // Generate embeddings for query
      final queryEmbedding = await _generateEmbedding(query);

      // Split content into chunks and generate embeddings
      final chunks = _splitIntoChunks(content, 1000);
      final chunkEmbeddings = await Future.wait(
        chunks.map((chunk) => _generateEmbedding(chunk)),
      );

      // Calculate similarities
      final similarities =
          chunkEmbeddings.map((embedding) {
            return _calculateCosineSimilarity(queryEmbedding, embedding);
          }).toList();

      // Sort by similarity and return top results
      final sortedIndices = List<int>.generate(similarities.length, (i) => i)
        ..sort((a, b) => similarities[b].compareTo(similarities[a]));

      final results = <SearchResult>[];
      for (int i = 0; i < maxResults && i < sortedIndices.length; i++) {
        final index = sortedIndices[i];
        final similarity = similarities[index];

        if (similarity > 0.7) {
          // Threshold for relevance
          results.add(
            SearchResult(
              id: _uuid.v4(),
              documentId: documentId,
              query: query,
              snippet: _generateSnippet(chunks[index], query),
              similarity: similarity,
              pageNumber: _estimatePageNumber(index, chunks.length),
              createdAt: DateTime.now(),
              highlights: _extractHighlights(chunks[index], query),
            ),
          );
        }
      }

      return results;
    } catch (e) {
      throw AIException('Failed to perform semantic search: $e');
    }
  }

  // OCR for scanned PDFs
  Future<OCRResult> performOCR({
    required Uint8List imageData,
    required String documentId,
    int pageNumber = 1,
    String language = 'eng',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_tesseractUrl),
        headers: {
          'apikey': _apiKeys['ocr'] ?? '',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'language': language,
          'isOverlayRequired': 'false',
          'filetype': 'png',
          'detectOrientation': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parsedText = data['ParsedResults'][0]['ParsedText'] as String;

        return OCRResult(
          id: _uuid.v4(),
          documentId: documentId,
          text: parsedText,
          confidence: _calculateOCRConfidence(data),
          createdAt: DateTime.now(),
          pageNumber: pageNumber,
          boundingBoxes: _extractBoundingBoxes(data),
          language: language,
        );
      } else {
        throw AIException(
          'OCR API returned status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw AIException('Failed to perform OCR: $e');
    }
  }

  // Full-text search with snippet previews
  Future<List<SearchResult>> fullTextSearch({
    required String query,
    required String documentId,
    required String content,
    int maxResults = 10,
  }) async {
    try {
      final results = <SearchResult>[];
      final queryLower = query.toLowerCase();
      final lines = content.split('\n');

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.toLowerCase().contains(queryLower)) {
          final snippet = _generateSnippet(line, query);
          final similarity = _calculateTextSimilarity(query, line);

          results.add(
            SearchResult(
              id: _uuid.v4(),
              documentId: documentId,
              query: query,
              snippet: snippet,
              similarity: similarity,
              pageNumber: _estimatePageNumber(i, lines.length),
              context: line,
              createdAt: DateTime.now(),
            ),
          );
        }
      }

      // Sort by similarity and limit results
      results.sort((a, b) => b.similarity.compareTo(a.similarity));
      return results.take(maxResults).toList();
    } catch (e) {
      throw AIException('Failed to perform full-text search: $e');
    }
  }

  // Content Analysis
  Future<ContentAnalysis> analyzeContent({
    required String documentId,
    required String content,
    required int totalPages,
  }) async {
    try {
      final prompt = _buildAnalysisPrompt(content);
      final response = await _callOpenAI(prompt, maxTokens: 800);

      return ContentAnalysis(
        id: _uuid.v4(),
        documentId: documentId,
        analysis: response,
        totalPages: totalPages,
        wordCount: content.split(' ').length,
        readingLevel: _calculateReadingLevel(content),
        topics: _extractTopics(response),
        sentiment: _analyzeSentiment(content),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw AIException('Failed to analyze content: $e');
    }
  }

  // Helper methods
  String _buildSummaryPrompt(String content, SummaryType type, int maxLength) {
    final typeInstructions = {
      SummaryType.brief: 'Provide a brief summary in 2-3 sentences.',
      SummaryType.comprehensive:
          'Provide a comprehensive summary covering all major points.',
      SummaryType.executive:
          'Provide an executive summary suitable for business presentation.',
      SummaryType.academic:
          'Provide an academic summary with key findings and methodology.',
    };

    return '''
You are an AI assistant analyzing a PDF document. ${typeInstructions[type]}

Document content:
$content

Requirements:
- Maximum ${maxLength} words
- Focus on key information and main points
- Maintain factual accuracy
- Use clear, concise language

Summary:
''';
  }

  String _buildQAPrompt(String question, String context, String? pageContext) {
    return '''
You are an AI assistant answering questions about a PDF document.

Context: $context
${pageContext != null ? 'Page context: $pageContext' : ''}

Question: $question

Instructions:
- Answer based only on the provided context
- If the information is not in the context, say "I cannot find this information in the document"
- Provide specific page references when possible
- Be concise but thorough

Answer:
''';
  }

  String _buildAnalysisPrompt(String content) {
    return '''
Analyze the following document content and provide insights:

Content: $content

Please provide:
1. Main topics and themes
2. Key findings or arguments
3. Document structure and organization
4. Target audience
5. Writing style and tone
6. Overall assessment

Analysis:
''';
  }

  Future<String> _callOpenAI(String prompt, {int maxTokens = 500}) async {
    if (_apiKeys['openai'] == null) {
      throw AIException('OpenAI API key not configured');
    }

    final response = await http.post(
      Uri.parse('$_openaiBaseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${_apiKeys['openai']}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are a helpful AI assistant.'},
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': maxTokens,
        'temperature': 0.3,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw AIException('OpenAI API error: ${response.statusCode}');
    }
  }

  Future<Translation> _translateWithGoogle(
    String text,
    String targetLanguage,
    String sourceLanguage,
  ) async {
    final response = await http.post(
      Uri.parse('$_googleTranslateUrl?key=${_apiKeys['google']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'q': text,
        'source': sourceLanguage,
        'target': targetLanguage,
        'format': 'text',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final translatedText =
          data['data']['translations'][0]['translatedText'] as String;

      return Translation(
        id: _uuid.v4(),
        originalText: text,
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        confidence: 0.95,
        createdAt: DateTime.now(),
      );
    } else {
      throw AIException('Google Translate API error: ${response.statusCode}');
    }
  }

  Future<Translation> _translateWithOpenAI(
    String text,
    String targetLanguage,
    String sourceLanguage,
  ) async {
    final prompt = 'Translate the following text to $targetLanguage:\n\n$text';
    final translatedText = await _callOpenAI(prompt, maxTokens: 300);

    return Translation(
      id: _uuid.v4(),
      originalText: text,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      confidence: 0.85,
      createdAt: DateTime.now(),
    );
  }

  Future<List<double>> _generateEmbedding(String text) async {
    // Simplified embedding generation - in production, use a proper embedding model
    final words = text.toLowerCase().split(' ');
    final embedding = List<double>.filled(384, 0.0);

    for (int i = 0; i < words.length && i < 384; i++) {
      embedding[i] = words[i].hashCode / double.maxFinite;
    }

    return embedding;
  }

  double _calculateCosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0.0 || normB == 0.0) return 0.0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  List<String> _splitIntoChunks(String text, int chunkSize) {
    final words = text.split(' ');
    final chunks = <String>[];

    for (int i = 0; i < words.length; i += chunkSize) {
      final end = (i + chunkSize < words.length) ? i + chunkSize : words.length;
      chunks.add(words.sublist(i, end).join(' '));
    }

    return chunks;
  }

  String _generateSnippet(String text, String query) {
    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();
    final index = textLower.indexOf(queryLower);

    if (index == -1) {
      return text.length > 200 ? '${text.substring(0, 200)}...' : text;
    }

    final start = (index - 50).clamp(0, text.length);
    final end = (index + query.length + 50).clamp(0, text.length);

    String snippet = text.substring(start, end);
    if (start > 0) snippet = '...$snippet';
    if (end < text.length) snippet = '$snippet...';

    return snippet;
  }

  int _estimatePageNumber(int index, int totalItems) {
    // Simple estimation - in production, use actual page mapping
    return ((index / totalItems) * 100).round().clamp(1, 100);
  }

  double _calculateTextSimilarity(String query, String text) {
    final queryWords = query.toLowerCase().split(' ');
    final textWords = text.toLowerCase().split(' ');

    int matches = 0;
    for (final queryWord in queryWords) {
      if (textWords.any((word) => word.contains(queryWord))) {
        matches++;
      }
    }

    return matches / queryWords.length;
  }

  List<String> _extractKeyPoints(String summary) {
    final sentences = summary.split('.');
    return sentences
        .where((sentence) => sentence.trim().isNotEmpty)
        .take(5)
        .map((sentence) => sentence.trim())
        .toList();
  }

  int _calculateReadingTime(String text) {
    const wordsPerMinute = 200;
    final wordCount = text.split(' ').length;
    return (wordCount / wordsPerMinute).ceil();
  }

  double _calculateConfidence(String answer) {
    // Simple confidence calculation based on answer length and completeness
    if (answer.length < 10) return 0.3;
    if (answer.length < 50) return 0.6;
    if (answer.length < 200) return 0.8;
    return 0.9;
  }

  List<String> _extractSources(String answer, String context) {
    // Extract potential sources from the answer
    final sources = <String>[];
    final sentences = answer.split('.');

    for (final sentence in sentences) {
      if (sentence.contains('page') || sentence.contains('section')) {
        sources.add(sentence.trim());
      }
    }

    return sources;
  }

  double _calculateOCRConfidence(Map<String, dynamic> data) {
    final results = data['ParsedResults'] as List;
    if (results.isEmpty) return 0.0;

    final confidence =
        results[0]['TextOverlay']['Lines']
            .map((line) => line['Words'].map((word) => word['Confidence']))
            .expand((confidences) => confidences)
            .map((confidence) => double.parse(confidence.toString()))
            .average;

    return confidence;
  }

  List<BoundingBox> _extractBoundingBoxes(Map<String, dynamic> data) {
    final boxes = <BoundingBox>[];
    final results = data['ParsedResults'] as List;

    if (results.isNotEmpty) {
      final lines = results[0]['TextOverlay']['Lines'] as List;

      for (final line in lines) {
        final words = line['Words'] as List;
        for (final word in words) {
          final coords = word['Left'] as int;
          final top = word['Top'] as int;
          final width = word['Width'] as int;
          final height = word['Height'] as int;

          boxes.add(
            BoundingBox(
              text: word['WordText'] as String,
              x: coords.toDouble(),
              y: top.toDouble(),
              width: width.toDouble(),
              height: height.toDouble(),
            ),
          );
        }
      }
    }

    return boxes;
  }

  String _calculateReadingLevel(String text) {
    final sentences = text.split('.').length;
    final words = text.split(' ').length;
    final syllables = _countSyllables(text);

    if (sentences == 0 || words == 0) return 'Unknown';

    final fleschScore =
        206.835 - (1.015 * (words / sentences)) - (84.6 * (syllables / words));

    if (fleschScore >= 90) return 'Very Easy';
    if (fleschScore >= 80) return 'Easy';
    if (fleschScore >= 70) return 'Fairly Easy';
    if (fleschScore >= 60) return 'Standard';
    if (fleschScore >= 50) return 'Fairly Difficult';
    if (fleschScore >= 30) return 'Difficult';
    return 'Very Difficult';
  }

  int _countSyllables(String text) {
    final words = text.toLowerCase().split(' ');
    int totalSyllables = 0;

    for (final word in words) {
      totalSyllables += _countWordSyllables(word);
    }

    return totalSyllables;
  }

  int _countWordSyllables(String word) {
    word = word.toLowerCase();
    word = word.replaceAll(RegExp(r'[^a-z]'), '');

    if (word.isEmpty) return 0;

    int syllables = 0;
    bool previousIsVowel = false;

    for (int i = 0; i < word.length; i++) {
      final isVowel = 'aeiouy'.contains(word[i]);
      if (isVowel && !previousIsVowel) {
        syllables++;
      }
      previousIsVowel = isVowel;
    }

    if (word.endsWith('e') && syllables > 1) {
      syllables--;
    }

    return syllables.clamp(1, 10);
  }

  List<String> _extractTopics(String analysis) {
    final topics = <String>[];
    final lines = analysis.split('\n');

    for (final line in lines) {
      if (line.toLowerCase().contains('topic') ||
          line.toLowerCase().contains('theme')) {
        final topic = line.replaceAll(RegExp(r'^[^:]*:\s*'), '').trim();
        if (topic.isNotEmpty) {
          topics.add(topic);
        }
      }
    }

    return topics.take(5).toList();
  }

  String _analyzeSentiment(String text) {
    final positiveWords = [
      'good',
      'great',
      'excellent',
      'positive',
      'beneficial',
      'successful',
    ];
    final negativeWords = [
      'bad',
      'poor',
      'negative',
      'harmful',
      'unsuccessful',
      'problem',
    ];

    final words = text.toLowerCase().split(' ');
    int positiveCount = 0;
    int negativeCount = 0;

    for (final word in words) {
      if (positiveWords.contains(word)) positiveCount++;
      if (negativeWords.contains(word)) negativeCount++;
    }

    if (positiveCount > negativeCount) return 'Positive';
    if (negativeCount > positiveCount) return 'Negative';
    return 'Neutral';
  }

  // Cache management
  void clearCache() {
    _cache.clear();
  }

  void removeFromCache(String key) {
    _cache.remove(key);
  }

  Map<String, dynamic> getCacheStats() {
    return {'totalEntries': _cache.length, 'keys': _cache.keys.toList()};
  }
}

class AIException implements Exception {
  final String message;
  AIException(this.message);

  @override
  String toString() => 'AIException: $message';
}
