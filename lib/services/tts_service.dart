import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/accessibility_utils.dart';

enum TTSState { playing, stopped, paused, continued }

class TTSService extends ChangeNotifier {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  FlutterTts flutterTts = FlutterTts();
  TTSState ttsState = TTSState.stopped;

  // TTS settings
  double _speechRate = 0.5;
  double _pitch = 1.0;
  double _volume = 1.0;
  String _language = 'en-US';
  String _voice = '';

  // Synchronization
  String _currentText = '';
  List<String> _words = [];
  List<String> _sentences = [];
  int _currentWordIndex = 0;
  int _currentSentenceIndex = 0;

  // Callbacks
  Function(String)? _onWordCallback;
  Function(String)? _onSentenceCallback;
  Function(TTSState)? _onStateChanged;
  Function(String)? _onError;

  // Available voices
  List<Map<String, dynamic>> _voices = [];
  List<String> _languages = [];

  // Initialize TTS
  Future<void> initialize() async {
    try {
      // Set up TTS callbacks
      flutterTts.setStartHandler(() {
        ttsState = TTSState.playing;
        _onStateChanged?.call(ttsState);
        notifyListeners();
      });

      flutterTts.setCompletionHandler(() {
        ttsState = TTSState.stopped;
        _currentWordIndex = 0;
        _currentSentenceIndex = 0;
        _onStateChanged?.call(ttsState);
        notifyListeners();
      });

      flutterTts.setCancelHandler(() {
        ttsState = TTSState.stopped;
        _currentWordIndex = 0;
        _currentSentenceIndex = 0;
        _onStateChanged?.call(ttsState);
        notifyListeners();
      });

      flutterTts.setPauseHandler(() {
        ttsState = TTSState.paused;
        _onStateChanged?.call(ttsState);
        notifyListeners();
      });

      flutterTts.setContinueHandler(() {
        ttsState = TTSState.continued;
        _onStateChanged?.call(ttsState);
        notifyListeners();
      });

      flutterTts.setErrorHandler((msg) {
        ttsState = TTSState.stopped;
        _onError?.call(msg);
        notifyListeners();
      });

      // Set default settings
      await setSpeechRate(_speechRate);
      await setPitch(_pitch);
      await setVolume(_volume);
      await setLanguage(_language);

      // Get available voices and languages
      await _loadVoices();
      await _loadLanguages();

      notifyListeners();
    } catch (e) {
      _onError?.call('Failed to initialize TTS: $e');
    }
  }

  // Load available voices
  Future<void> _loadVoices() async {
    try {
      _voices = await flutterTts.getVoices as List<Map<String, dynamic>>;
      notifyListeners();
    } catch (e) {
      _onError?.call('Failed to load voices: $e');
    }
  }

  // Load available languages
  Future<void> _loadLanguages() async {
    try {
      _languages = await flutterTts.getLanguages as List<String>;
      notifyListeners();
    } catch (e) {
      _onError?.call('Failed to load languages: $e');
    }
  }

  // Set up callbacks
  void setCallbacks({
    Function(String)? onWord,
    Function(String)? onSentence,
    Function(TTSState)? onStateChanged,
    Function(String)? onError,
  }) {
    _onWordCallback = onWord;
    _onSentenceCallback = onSentence;
    _onStateChanged = onStateChanged;
    _onError = onError;
  }

  // Speak text with synchronization
  Future<void> speak(String text) async {
    try {
      _currentText = text;
      _words =
          text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
      _sentences =
          text
              .split(RegExp(r'[.!?]+'))
              .where((sentence) => sentence.trim().isNotEmpty)
              .toList();
      _currentWordIndex = 0;
      _currentSentenceIndex = 0;

      await flutterTts.speak(text);
    } catch (e) {
      _onError?.call('Failed to speak text: $e');
    }
  }

  // Speak word by word
  Future<void> speakWordByWord(String text) async {
    try {
      _currentText = text;
      _words =
          text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
      _currentWordIndex = 0;

      for (int i = 0; i < _words.length; i++) {
        if (ttsState == TTSState.stopped) break;

        _currentWordIndex = i;
        final word = _words[i];

        _onWordCallback?.call(word);
        notifyListeners();

        await flutterTts.speak(word);
        await Future.delayed(
          Duration(milliseconds: (1000 / _speechRate).round()),
        );
      }
    } catch (e) {
      _onError?.call('Failed to speak word by word: $e');
    }
  }

  // Speak sentence by sentence
  Future<void> speakSentenceBySentence(String text) async {
    try {
      _currentText = text;
      _sentences =
          text
              .split(RegExp(r'[.!?]+'))
              .where((sentence) => sentence.trim().isNotEmpty)
              .toList();
      _currentSentenceIndex = 0;

      for (int i = 0; i < _sentences.length; i++) {
        if (ttsState == TTSState.stopped) break;

        _currentSentenceIndex = i;
        final sentence = _sentences[i];

        _onSentenceCallback?.call(sentence);
        notifyListeners();

        await flutterTts.speak(sentence);
        await Future.delayed(
          Duration(milliseconds: (2000 / _speechRate).round()),
        );
      }
    } catch (e) {
      _onError?.call('Failed to speak sentence by sentence: $e');
    }
  }

  // Stop TTS
  Future<void> stop() async {
    try {
      await flutterTts.stop();
      ttsState = TTSState.stopped;
      _currentWordIndex = 0;
      _currentSentenceIndex = 0;
      _onStateChanged?.call(ttsState);
      notifyListeners();
    } catch (e) {
      _onError?.call('Failed to stop TTS: $e');
    }
  }

  // Pause TTS
  Future<void> pause() async {
    try {
      await flutterTts.pause();
      ttsState = TTSState.paused;
      _onStateChanged?.call(ttsState);
      notifyListeners();
    } catch (e) {
      _onError?.call('Failed to pause TTS: $e');
    }
  }

  // Resume TTS
  Future<void> resume() async {
    try {
      // FlutterTts doesn't have a resume method, so we restart from current position
      if (_currentWordIndex < _words.length) {
        final remainingText = _words.skip(_currentWordIndex).join(' ');
        await flutterTts.speak(remainingText);
        ttsState = TTSState.continued;
        _onStateChanged?.call(ttsState);
        notifyListeners();
      }
    } catch (e) {
      _onError?.call('Failed to resume TTS: $e');
    }
  }

  // Set speech rate
  Future<void> setSpeechRate(double rate) async {
    try {
      _speechRate = rate.clamp(0.1, 1.0);
      await flutterTts.setSpeechRate(_speechRate);
      notifyListeners();
    } catch (e) {
      _onError?.call('Failed to set speech rate: $e');
    }
  }

  // Set pitch
  Future<void> setPitch(double pitch) async {
    try {
      _pitch = pitch.clamp(0.5, 2.0);
      await flutterTts.setPitch(_pitch);
      notifyListeners();
    } catch (e) {
      _onError?.call('Failed to set pitch: $e');
    }
  }

  // Set volume
  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      await flutterTts.setVolume(_volume);
      notifyListeners();
    } catch (e) {
      _onError?.call('Failed to set volume: $e');
    }
  }

  // Set language
  Future<void> setLanguage(String language) async {
    try {
      _language = language;
      await flutterTts.setLanguage(language);
      notifyListeners();
    } catch (e) {
      _onError?.call('Failed to set language: $e');
    }
  }

  // Set voice
  Future<void> setVoice(String voice) async {
    try {
      _voice = voice;
      await flutterTts.setVoice({"name": voice, "locale": _language});
      notifyListeners();
    } catch (e) {
      _onError?.call('Failed to set voice: $e');
    }
  }

  // Get current word
  String get currentWord {
    if (_words.isNotEmpty && _currentWordIndex < _words.length) {
      return _words[_currentWordIndex];
    }
    return '';
  }

  // Get current sentence
  String get currentSentence {
    if (_sentences.isNotEmpty && _currentSentenceIndex < _sentences.length) {
      return _sentences[_currentSentenceIndex];
    }
    return '';
  }

  // Get progress percentage
  double get progressPercentage {
    if (_words.isEmpty) return 0.0;
    return (_currentWordIndex / _words.length) * 100;
  }

  // Get sentence progress percentage
  double get sentenceProgressPercentage {
    if (_sentences.isEmpty) return 0.0;
    return (_currentSentenceIndex / _sentences.length) * 100;
  }

  // Get available voices
  List<Map<String, dynamic>> get voices => _voices;

  // Get available languages
  List<String> get languages => _languages;

  // Get current settings
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  double get volume => _volume;
  String get language => _language;
  String get voice => _voice;

  // Check if TTS is supported
  Future<bool> get isSupported async {
    try {
      final result = await flutterTts.isLanguageAvailable(_language);
      return result == 1;
    } catch (e) {
      return false;
    }
  }

  // Get TTS state
  TTSState get state => ttsState;

  // Check if playing
  bool get isPlaying => ttsState == TTSState.playing;

  // Check if paused
  bool get isPaused => ttsState == TTSState.paused;

  // Check if stopped
  bool get isStopped => ttsState == TTSState.stopped;

  // Dispose
  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}

// TTS controller for managing TTS state
class TTSController extends ChangeNotifier {
  final TTSService _ttsService = TTSService();

  // TTS state
  bool _isEnabled = false;
  bool _isWordByWord = false;
  bool _isSentenceBySentence = false;
  double _speed = 0.5;
  String _selectedVoice = '';
  String _selectedLanguage = 'en-US';

  // Getter methods
  bool get isEnabled => _isEnabled;
  bool get isWordByWord => _isWordByWord;
  bool get isSentenceBySentence => _isSentenceBySentence;
  double get speed => _speed;
  String get selectedVoice => _selectedVoice;
  String get selectedLanguage => _selectedLanguage;
  TTSState get ttsState => _ttsService.state;
  bool get isPlaying => _ttsService.isPlaying;
  bool get isPaused => _ttsService.isPaused;
  bool get isStopped => _ttsService.isStopped;
  String get currentWord => _ttsService.currentWord;
  String get currentSentence => _ttsService.currentSentence;
  double get progressPercentage => _ttsService.progressPercentage;
  double get sentenceProgressPercentage =>
      _ttsService.sentenceProgressPercentage;
  List<Map<String, dynamic>> get voices => _ttsService.voices;
  List<String> get languages => _ttsService.languages;

  // Initialize TTS controller
  Future<void> initialize() async {
    await _ttsService.initialize();
    _ttsService.setCallbacks(
      onWord: (word) {
        notifyListeners();
      },
      onSentence: (sentence) {
        notifyListeners();
      },
      onStateChanged: (state) {
        notifyListeners();
      },
      onError: (error) {
        notifyListeners();
      },
    );
  }

  // Enable/disable TTS
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      stop();
    }
    notifyListeners();
  }

  // Set word-by-word mode
  void setWordByWord(bool enabled) {
    _isWordByWord = enabled;
    if (enabled) {
      _isSentenceBySentence = false;
    }
    notifyListeners();
  }

  // Set sentence-by-sentence mode
  void setSentenceBySentence(bool enabled) {
    _isSentenceBySentence = enabled;
    if (enabled) {
      _isWordByWord = false;
    }
    notifyListeners();
  }

  // Set speed
  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await _ttsService.setSpeechRate(speed);
    notifyListeners();
  }

  // Set voice
  Future<void> setVoice(String voice) async {
    _selectedVoice = voice;
    await _ttsService.setVoice(voice);
    notifyListeners();
  }

  // Set language
  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    await _ttsService.setLanguage(language);
    notifyListeners();
  }

  // Speak text
  Future<void> speak(String text) async {
    if (!_isEnabled) return;

    if (_isWordByWord) {
      await _ttsService.speakWordByWord(text);
    } else if (_isSentenceBySentence) {
      await _ttsService.speakSentenceBySentence(text);
    } else {
      await _ttsService.speak(text);
    }
  }

  // Stop TTS
  Future<void> stop() async {
    await _ttsService.stop();
  }

  // Pause TTS
  Future<void> pause() async {
    await _ttsService.pause();
  }

  // Resume TTS
  Future<void> resume() async {
    await _ttsService.resume();
  }

  // Toggle play/pause
  Future<void> togglePlayPause(String text) async {
    if (isPlaying) {
      await pause();
    } else if (isPaused) {
      await resume();
    } else {
      await speak(text);
    }
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}
