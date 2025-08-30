import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/ai_service.dart';
import '../../lib/models/ai_features.dart';

void main() {
  group('AiService Tests', () {
    late AiService aiService;

    setUp(() {
      aiService = AiService();
    });

    group('Initialization', () {
      test('should initialize with API key', () {
        aiService.initialize(openaiApiKey: 'test-api-key');
        expect(aiService.isAvailable, isTrue);
      });

      test('should not be available without API key', () {
        aiService.initialize();
        expect(aiService.isAvailable, isFalse);
      });
    });

    group('Document Summarization', () {
      test('should throw exception when service not available', () async {
        aiService.initialize();

        expect(
          () => aiService.summarizeDocument(
            documentId: 'test-id',
            documentText: 'Test document content',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Question & Answer', () {
      test('should throw exception when service not available', () async {
        aiService.initialize();

        expect(
          () => aiService.answerQuestion(
            documentId: 'test-id',
            documentText: 'Test document content',
            question: 'What is this document about?',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Translation', () {
      test('should throw exception when service not available', () async {
        aiService.initialize();

        expect(
          () => aiService.translateText(
            documentId: 'test-id',
            text: 'Hello world',
            sourceLanguage: TranslationLanguage.english,
            targetLanguage: TranslationLanguage.spanish,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Settings Management', () {
      test('should update settings correctly', () {
        aiService.initialize(openaiApiKey: 'test-api-key');

        aiService.updateSettings(
          model: 'gpt-4',
          temperature: 0.5,
          maxTokens: 2000,
        );

        final settings = aiService.getSettings();
        expect(settings['model'], equals('gpt-4'));
        expect(settings['temperature'], equals(0.5));
        expect(settings['maxTokens'], equals(2000));
      });

      test('should return correct settings', () {
        aiService.initialize(openaiApiKey: 'test-api-key');

        final settings = aiService.getSettings();
        expect(settings['isAvailable'], isTrue);
        expect(settings['apiKey'], equals('***'));
      });
    });

    group('Error Handling', () {
      test('should handle missing API key', () async {
        aiService.initialize();

        expect(
          () => aiService.summarizeDocument(
            documentId: 'test-id',
            documentText: 'Test document content',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Text Extraction', () {
      test('should extract text from PDF path', () async {
        final result = await aiService.extractTextFromPdf('/path/to/test.pdf');

        expect(result, isA<String>());
        expect(result, contains('placeholder'));
        expect(result, contains('/path/to/test.pdf'));
      });
    });
  });
}
