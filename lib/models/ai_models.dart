

enum SummaryType { brief, detailed, bulletPoints, executive, academic }

class PDFSummary {
  final String id;
  final String documentId;
  final SummaryType type;
  final String content;
  final int wordCount;
  final double confidence;
  final DateTime createdAt;
  final List<String> keyPoints;
  final int estimatedReadingTime;

  PDFSummary({
    required this.id,
    required this.documentId,
    required this.type,
    required this.content,
    required this.wordCount,
    required this.confidence,
    required this.createdAt,
    required this.keyPoints,
    required this.estimatedReadingTime,
  });

  factory PDFSummary.fromJson(Map<String, dynamic> json) {
    return PDFSummary(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      type: SummaryType.values.firstWhere(
        (e) => e.toString() == 'SummaryType.${json['type']}',
        orElse: () => SummaryType.brief,
      ),
      content: json['content'] as String,
      wordCount: json['wordCount'] as int,
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
      estimatedReadingTime: json['estimatedReadingTime'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'type': type.toString().split('.').last,
      'content': content,
      'wordCount': wordCount,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
      'keyPoints': keyPoints,
      'estimatedReadingTime': estimatedReadingTime,
    };
  }
}

class QAAnswer {
  final String id;
  final String documentId;
  final String question;
  final String answer;
  final double confidence;
  final DateTime createdAt;
  final List<String> sources;
  final int pageNumber;

  QAAnswer({
    required this.id,
    required this.documentId,
    required this.question,
    required this.answer,
    required this.confidence,
    required this.createdAt,
    required this.sources,
    required this.pageNumber,
  });

  factory QAAnswer.fromJson(Map<String, dynamic> json) {
    return QAAnswer(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      sources: List<String>.from(json['sources'] ?? []),
      pageNumber: json['pageNumber'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'question': question,
      'answer': answer,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
      'sources': sources,
      'pageNumber': pageNumber,
    };
  }
}

class Translation {
  final String id;
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final double confidence;
  final DateTime createdAt;
  final int pageNumber;

  Translation({
    required this.id,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.confidence,
    required this.createdAt,
    required this.pageNumber,
  });

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      id: json['id'] as String,
      originalText: json['originalText'] as String,
      translatedText: json['translatedText'] as String,
      sourceLanguage: json['sourceLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      pageNumber: json['pageNumber'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalText': originalText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
      'pageNumber': pageNumber,
    };
  }
}

class SearchResult {
  final String id;
  final String documentId;
  final String query;
  final String snippet;
  final double similarity;
  final int pageNumber;
  final DateTime createdAt;
  final List<String> highlights;

  SearchResult({
    required this.id,
    required this.documentId,
    required this.query,
    required this.snippet,
    required this.similarity,
    required this.pageNumber,
    required this.createdAt,
    required this.highlights,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      query: json['query'] as String,
      snippet: json['snippet'] as String,
      similarity: (json['similarity'] as num).toDouble(),
      pageNumber: json['pageNumber'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      highlights: List<String>.from(json['highlights'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'query': query,
      'snippet': snippet,
      'similarity': similarity,
      'pageNumber': pageNumber,
      'createdAt': createdAt.toIso8601String(),
      'highlights': highlights,
    };
  }
}

class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y, 'width': width, 'height': height};
  }
}

class OCRResult {
  final String id;
  final String documentId;
  final String text;
  final double confidence;
  final DateTime createdAt;
  final int pageNumber;
  final List<BoundingBox> boundingBoxes;
  final String language;

  OCRResult({
    required this.id,
    required this.documentId,
    required this.text,
    required this.confidence,
    required this.createdAt,
    required this.pageNumber,
    required this.boundingBoxes,
    required this.language,
  });

  factory OCRResult.fromJson(Map<String, dynamic> json) {
    return OCRResult(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      text: json['text'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      pageNumber: json['pageNumber'] as int,
      boundingBoxes:
          (json['boundingBoxes'] as List<dynamic>?)
              ?.map((e) => BoundingBox.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      language: json['language'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'text': text,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
      'pageNumber': pageNumber,
      'boundingBoxes': boundingBoxes.map((e) => e.toJson()).toList(),
      'language': language,
    };
  }
}

class ContentAnalysis {
  final String id;
  final String documentId;
  final int wordCount;
  final int pageCount;
  final List<String> topics;
  final String sentiment;
  final String readingLevel;
  final DateTime createdAt;
  final Map<String, dynamic> detailedAnalysis;

  ContentAnalysis({
    required this.id,
    required this.documentId,
    required this.wordCount,
    required this.pageCount,
    required this.topics,
    required this.sentiment,
    required this.readingLevel,
    required this.createdAt,
    required this.detailedAnalysis,
  });

  factory ContentAnalysis.fromJson(Map<String, dynamic> json) {
    return ContentAnalysis(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      wordCount: json['wordCount'] as int,
      pageCount: json['pageCount'] as int,
      topics: List<String>.from(json['topics'] ?? []),
      sentiment: json['sentiment'] as String,
      readingLevel: json['readingLevel'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      detailedAnalysis: Map<String, dynamic>.from(
        json['detailedAnalysis'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'wordCount': wordCount,
      'pageCount': pageCount,
      'topics': topics,
      'sentiment': sentiment,
      'readingLevel': readingLevel,
      'createdAt': createdAt.toIso8601String(),
      'detailedAnalysis': detailedAnalysis,
    };
  }
}

class AISettings {
  final String? openAIKey;
  final String? googleTranslateKey;
  final bool enableSummarization;
  final bool enableQA;
  final bool enableTranslation;
  final bool enableSemanticSearch;
  final bool enableOCR;
  final bool enableContentAnalysis;
  final String defaultLanguage;
  final int maxSearchResults;
  final double minConfidence;

  AISettings({
    this.openAIKey,
    this.googleTranslateKey,
    this.enableSummarization = true,
    this.enableQA = true,
    this.enableTranslation = true,
    this.enableSemanticSearch = true,
    this.enableOCR = true,
    this.enableContentAnalysis = true,
    this.defaultLanguage = 'en',
    this.maxSearchResults = 10,
    this.minConfidence = 0.7,
  });

  factory AISettings.fromJson(Map<String, dynamic> json) {
    return AISettings(
      openAIKey: json['openAIKey'] as String?,
      googleTranslateKey: json['googleTranslateKey'] as String?,
      enableSummarization: json['enableSummarization'] as bool? ?? true,
      enableQA: json['enableQA'] as bool? ?? true,
      enableTranslation: json['enableTranslation'] as bool? ?? true,
      enableSemanticSearch: json['enableSemanticSearch'] as bool? ?? true,
      enableOCR: json['enableOCR'] as bool? ?? true,
      enableContentAnalysis: json['enableContentAnalysis'] as bool? ?? true,
      defaultLanguage: json['defaultLanguage'] as String? ?? 'en',
      maxSearchResults: json['maxSearchResults'] as int? ?? 10,
      minConfidence: (json['minConfidence'] as num?)?.toDouble() ?? 0.7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'openAIKey': openAIKey,
      'googleTranslateKey': googleTranslateKey,
      'enableSummarization': enableSummarization,
      'enableQA': enableQA,
      'enableTranslation': enableTranslation,
      'enableSemanticSearch': enableSemanticSearch,
      'enableOCR': enableOCR,
      'enableContentAnalysis': enableContentAnalysis,
      'defaultLanguage': defaultLanguage,
      'maxSearchResults': maxSearchResults,
      'minConfidence': minConfidence,
    };
  }

  AISettings copyWith({
    String? openAIKey,
    String? googleTranslateKey,
    bool? enableSummarization,
    bool? enableQA,
    bool? enableTranslation,
    bool? enableSemanticSearch,
    bool? enableOCR,
    bool? enableContentAnalysis,
    String? defaultLanguage,
    int? maxSearchResults,
    double? minConfidence,
  }) {
    return AISettings(
      openAIKey: openAIKey ?? this.openAIKey,
      googleTranslateKey: googleTranslateKey ?? this.googleTranslateKey,
      enableSummarization: enableSummarization ?? this.enableSummarization,
      enableQA: enableQA ?? this.enableQA,
      enableTranslation: enableTranslation ?? this.enableTranslation,
      enableSemanticSearch: enableSemanticSearch ?? this.enableSemanticSearch,
      enableOCR: enableOCR ?? this.enableOCR,
      enableContentAnalysis:
          enableContentAnalysis ?? this.enableContentAnalysis,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      maxSearchResults: maxSearchResults ?? this.maxSearchResults,
      minConfidence: minConfidence ?? this.minConfidence,
    );
  }
}

class SupportedLanguage {
  final String code;
  final String name;
  final String nativeName;

  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  static const List<SupportedLanguage> all = [
    SupportedLanguage(code: 'en', name: 'English', nativeName: 'English'),
    SupportedLanguage(code: 'es', name: 'Spanish', nativeName: 'Español'),
    SupportedLanguage(code: 'fr', name: 'French', nativeName: 'Français'),
    SupportedLanguage(code: 'de', name: 'German', nativeName: 'Deutsch'),
    SupportedLanguage(code: 'it', name: 'Italian', nativeName: 'Italiano'),
    SupportedLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português'),
    SupportedLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский'),
    SupportedLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語'),
    SupportedLanguage(code: 'ko', name: 'Korean', nativeName: '한국어'),
    SupportedLanguage(code: 'zh', name: 'Chinese', nativeName: '中文'),
    SupportedLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    SupportedLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
    SupportedLanguage(code: 'tr', name: 'Turkish', nativeName: 'Türkçe'),
    SupportedLanguage(code: 'nl', name: 'Dutch', nativeName: 'Nederlands'),
    SupportedLanguage(code: 'pl', name: 'Polish', nativeName: 'Polski'),
    SupportedLanguage(code: 'sv', name: 'Swedish', nativeName: 'Svenska'),
    SupportedLanguage(code: 'da', name: 'Danish', nativeName: 'Dansk'),
    SupportedLanguage(code: 'no', name: 'Norwegian', nativeName: 'Norsk'),
    SupportedLanguage(code: 'fi', name: 'Finnish', nativeName: 'Suomi'),
    SupportedLanguage(code: 'cs', name: 'Czech', nativeName: 'Čeština'),
    SupportedLanguage(code: 'hu', name: 'Hungarian', nativeName: 'Magyar'),
    SupportedLanguage(code: 'ro', name: 'Romanian', nativeName: 'Română'),
    SupportedLanguage(code: 'bg', name: 'Bulgarian', nativeName: 'Български'),
    SupportedLanguage(code: 'hr', name: 'Croatian', nativeName: 'Hrvatski'),
    SupportedLanguage(code: 'sk', name: 'Slovak', nativeName: 'Slovenčina'),
    SupportedLanguage(code: 'sl', name: 'Slovenian', nativeName: 'Slovenščina'),
    SupportedLanguage(code: 'et', name: 'Estonian', nativeName: 'Eesti'),
    SupportedLanguage(code: 'lv', name: 'Latvian', nativeName: 'Latviešu'),
    SupportedLanguage(code: 'lt', name: 'Lithuanian', nativeName: 'Lietuvių'),
    SupportedLanguage(code: 'mt', name: 'Maltese', nativeName: 'Malti'),
    SupportedLanguage(code: 'el', name: 'Greek', nativeName: 'Ελληνικά'),
    SupportedLanguage(code: 'he', name: 'Hebrew', nativeName: 'עברית'),
    SupportedLanguage(code: 'th', name: 'Thai', nativeName: 'ไทย'),
    SupportedLanguage(code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt'),
    SupportedLanguage(
      code: 'id',
      name: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
    ),
    SupportedLanguage(code: 'ms', name: 'Malay', nativeName: 'Bahasa Melayu'),
    SupportedLanguage(code: 'tl', name: 'Filipino', nativeName: 'Filipino'),
    SupportedLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    SupportedLanguage(code: 'ur', name: 'Urdu', nativeName: 'اردو'),
    SupportedLanguage(code: 'fa', name: 'Persian', nativeName: 'فارسی'),
    SupportedLanguage(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી'),
    SupportedLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
    SupportedLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
    SupportedLanguage(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    SupportedLanguage(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം'),
    SupportedLanguage(code: 'si', name: 'Sinhala', nativeName: 'සිංහල'),
    SupportedLanguage(code: 'my', name: 'Burmese', nativeName: 'မြန်မာ'),
    SupportedLanguage(code: 'km', name: 'Khmer', nativeName: 'ខ្មែរ'),
    SupportedLanguage(code: 'lo', name: 'Lao', nativeName: 'ລາວ'),
    SupportedLanguage(code: 'mn', name: 'Mongolian', nativeName: 'Монгол'),
    SupportedLanguage(code: 'ka', name: 'Georgian', nativeName: 'ქართული'),
    SupportedLanguage(code: 'am', name: 'Amharic', nativeName: 'አማርኛ'),
    SupportedLanguage(code: 'sw', name: 'Swahili', nativeName: 'Kiswahili'),
    SupportedLanguage(code: 'zu', name: 'Zulu', nativeName: 'isiZulu'),
    SupportedLanguage(code: 'af', name: 'Afrikaans', nativeName: 'Afrikaans'),
    SupportedLanguage(code: 'is', name: 'Icelandic', nativeName: 'Íslenska'),
    SupportedLanguage(code: 'ga', name: 'Irish', nativeName: 'Gaeilge'),
    SupportedLanguage(code: 'cy', name: 'Welsh', nativeName: 'Cymraeg'),
    SupportedLanguage(code: 'eu', name: 'Basque', nativeName: 'Euskara'),
    SupportedLanguage(code: 'ca', name: 'Catalan', nativeName: 'Català'),
    SupportedLanguage(code: 'gl', name: 'Galician', nativeName: 'Galego'),
    SupportedLanguage(code: 'sq', name: 'Albanian', nativeName: 'Shqip'),
    SupportedLanguage(code: 'mk', name: 'Macedonian', nativeName: 'Македонски'),
    SupportedLanguage(code: 'sr', name: 'Serbian', nativeName: 'Српски'),
    SupportedLanguage(code: 'bs', name: 'Bosnian', nativeName: 'Bosanski'),
    SupportedLanguage(
      code: 'me',
      name: 'Montenegrin',
      nativeName: 'Crnogorski',
    ),
  ];

  static SupportedLanguage? fromCode(String code) {
    try {
      return all.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportedLanguage &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
