import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  static const String _defaultLocale = 'en';
  static const String _localeKey = 'app_locale';

  Locale _currentLocale = const Locale(_defaultLocale);
  Map<String, Map<String, String>> _translations = {};
  bool _isInitialized = false;

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('fr'), // French
    Locale('de'), // German
    Locale('it'), // Italian
    Locale('pt'), // Portuguese
    Locale('ru'), // Russian
    Locale('zh'), // Chinese
    Locale('ja'), // Japanese
    Locale('ko'), // Korean
    Locale('ar'), // Arabic
    Locale('hi'), // Hindi
  ];

  // Initialize localization service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load saved locale
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localeKey);

      if (savedLocale != null) {
        _currentLocale = Locale(savedLocale);
      }

      // Load translations
      await _loadTranslations();

      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize localization service: $e');
    }
  }

  // Load translations from JSON files
  Future<void> _loadTranslations() async {
    try {
      for (final locale in supportedLocales) {
        final languageCode = locale.languageCode;
        final translationData = await _loadTranslationFile(languageCode);
        _translations[languageCode] = translationData;
      }
    } catch (e) {
      print('Failed to load translations: $e');
    }
  }

  // Load translation file
  Future<Map<String, String>> _loadTranslationFile(String languageCode) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/translations/$languageCode.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      return Map<String, String>.from(jsonMap);
    } catch (e) {
      // Fallback to English if translation file not found
      if (languageCode != 'en') {
        return await _loadTranslationFile('en');
      }
      return {};
    }
  }

  // Get current locale
  Locale get currentLocale => _currentLocale;

  // Get supported locales
  List<Locale> get supportedLocalesList => supportedLocales;

  // Change locale
  Future<void> changeLocale(Locale newLocale) async {
    if (!supportedLocales.contains(newLocale)) {
      throw Exception('Unsupported locale: ${newLocale.languageCode}');
    }

    _currentLocale = newLocale;

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, newLocale.languageCode);
  }

  // Get localized string
  String getString(String key, [Map<String, String>? args]) {
    try {
      final languageCode = _currentLocale.languageCode;
      final translations =
          _translations[languageCode] ?? _translations['en'] ?? {};

      String value = translations[key] ?? key;

      // Replace arguments
      if (args != null) {
        for (final entry in args.entries) {
          value = value.replaceAll('{${entry.key}}', entry.value);
        }
      }

      return value;
    } catch (e) {
      return key;
    }
  }

  // Get localized string with pluralization
  String getPluralString(String key, int count, [Map<String, String>? args]) {
    try {
      final languageCode = _currentLocale.languageCode;
      final translations =
          _translations[languageCode] ?? _translations['en'] ?? {};

      // Handle pluralization based on language
      String pluralKey = key;
      if (count != 1) {
        pluralKey = '${key}_plural';
      }

      String value = translations[pluralKey] ?? translations[key] ?? key;

      // Replace count placeholder
      value = value.replaceAll('{count}', count.toString());

      // Replace other arguments
      if (args != null) {
        for (final entry in args.entries) {
          value = value.replaceAll('{${entry.key}}', entry.value);
        }
      }

      return value;
    } catch (e) {
      return key;
    }
  }

  // Get localized date format
  String formatDate(DateTime date) {
    try {
      final languageCode = _currentLocale.languageCode;

      switch (languageCode) {
        case 'en':
          return '${date.month}/${date.day}/${date.year}';
        case 'es':
          return '${date.day}/${date.month}/${date.year}';
        case 'fr':
          return '${date.day}/${date.month}/${date.year}';
        case 'de':
          return '${date.day}.${date.month}.${date.year}';
        case 'zh':
          return '${date.year}年${date.month}月${date.day}日';
        case 'ja':
          return '${date.year}年${date.month}月${date.day}日';
        case 'ko':
          return '${date.year}년 ${date.month}월 ${date.day}일';
        case 'ar':
          return '${date.day}/${date.month}/${date.year}';
        default:
          return '${date.month}/${date.day}/${date.year}';
      }
    } catch (e) {
      return date.toString();
    }
  }

  // Get localized time format
  String formatTime(DateTime time) {
    try {
      final languageCode = _currentLocale.languageCode;

      switch (languageCode) {
        case 'en':
          return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
        case 'es':
          return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
        case 'fr':
          return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
        case 'de':
          return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
        case 'zh':
          return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
        case 'ja':
          return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
        case 'ko':
          return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
        case 'ar':
          return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
        default:
          return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return time.toString();
    }
  }

  // Get localized number format
  String formatNumber(num number) {
    try {
      final languageCode = _currentLocale.languageCode;

      switch (languageCode) {
        case 'en':
          return number.toString();
        case 'es':
          return number.toString().replaceAll('.', ',');
        case 'fr':
          return number.toString().replaceAll('.', ',');
        case 'de':
          return number.toString().replaceAll('.', ',');
        case 'it':
          return number.toString().replaceAll('.', ',');
        case 'pt':
          return number.toString().replaceAll('.', ',');
        case 'ru':
          return number.toString().replaceAll('.', ',');
        default:
          return number.toString();
      }
    } catch (e) {
      return number.toString();
    }
  }

  // Get localized file size
  String formatFileSize(int bytes) {
    try {
      final languageCode = _currentLocale.languageCode;
      final units = _getFileSizeUnits(languageCode);

      if (bytes < 1024) {
        return '${bytes} ${units['B']}';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} ${units['KB']}';
      } else if (bytes < 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ${units['MB']}';
      } else {
        return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} ${units['GB']}';
      }
    } catch (e) {
      return '${bytes} B';
    }
  }

  // Get file size units for different languages
  Map<String, String> _getFileSizeUnits(String languageCode) {
    switch (languageCode) {
      case 'en':
        return {'B': 'B', 'KB': 'KB', 'MB': 'MB', 'GB': 'GB'};
      case 'es':
        return {'B': 'B', 'KB': 'KB', 'MB': 'MB', 'GB': 'GB'};
      case 'fr':
        return {'B': 'o', 'KB': 'Ko', 'MB': 'Mo', 'GB': 'Go'};
      case 'de':
        return {'B': 'B', 'KB': 'KB', 'MB': 'MB', 'GB': 'GB'};
      case 'it':
        return {'B': 'B', 'KB': 'KB', 'MB': 'MB', 'GB': 'GB'};
      case 'pt':
        return {'B': 'B', 'KB': 'KB', 'MB': 'MB', 'GB': 'GB'};
      case 'ru':
        return {'B': 'Б', 'KB': 'КБ', 'MB': 'МБ', 'GB': 'ГБ'};
      case 'zh':
        return {'B': '字节', 'KB': 'KB', 'MB': 'MB', 'GB': 'GB'};
      case 'ja':
        return {'B': 'バイト', 'KB': 'KB', 'MB': 'MB', 'GB': 'GB'};
      case 'ko':
        return {'B': '바이트', 'KB': 'KB', 'MB': 'MB', 'GB': 'GB'};
      case 'ar':
        return {'B': 'بايت', 'KB': 'ك.ب', 'MB': 'م.ب', 'GB': 'ج.ب'};
      case 'hi':
        return {'B': 'बाइट', 'KB': 'KB', 'MB': 'MB', 'GB': 'GB'};
      default:
        return {'B': 'B', 'KB': 'KB', 'MB': 'MB', 'GB': 'GB'};
    }
  }

  // Get language name
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      case 'zh':
        return '中文';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'ar':
        return 'العربية';
      case 'hi':
        return 'हिन्दी';
      default:
        return languageCode;
    }
  }

  // Get country name
  String getCountryName(String countryCode) {
    switch (countryCode) {
      case 'US':
        return 'United States';
      case 'GB':
        return 'United Kingdom';
      case 'ES':
        return 'Spain';
      case 'FR':
        return 'France';
      case 'DE':
        return 'Germany';
      case 'IT':
        return 'Italy';
      case 'PT':
        return 'Portugal';
      case 'RU':
        return 'Russia';
      case 'CN':
        return 'China';
      case 'JP':
        return 'Japan';
      case 'KR':
        return 'South Korea';
      case 'SA':
        return 'Saudi Arabia';
      case 'IN':
        return 'India';
      default:
        return countryCode;
    }
  }

  // Check if RTL (Right-to-Left) language
  bool isRTL() {
    return _currentLocale.languageCode == 'ar' ||
        _currentLocale.languageCode == 'he' ||
        _currentLocale.languageCode == 'fa';
  }

  // Get text direction
  TextDirection getTextDirection() {
    return isRTL() ? TextDirection.rtl : TextDirection.ltr;
  }

  // Get localized currency symbol
  String getCurrencySymbol() {
    switch (_currentLocale.languageCode) {
      case 'en':
        return '\$';
      case 'es':
        return '€';
      case 'fr':
        return '€';
      case 'de':
        return '€';
      case 'it':
        return '€';
      case 'pt':
        return '€';
      case 'ru':
        return '₽';
      case 'zh':
        return '¥';
      case 'ja':
        return '¥';
      case 'ko':
        return '₩';
      case 'ar':
        return 'ر.س';
      case 'hi':
        return '₹';
      default:
        return '\$';
    }
  }

  // Get localized currency format
  String formatCurrency(num amount) {
    final symbol = getCurrencySymbol();
    final formattedNumber = formatNumber(amount);

    if (isRTL()) {
      return '$formattedNumber $symbol';
    } else {
      return '$symbol$formattedNumber';
    }
  }

  // Get localized month name
  String getMonthName(int month) {
    final languageCode = _currentLocale.languageCode;

    switch (languageCode) {
      case 'en':
        return _getEnglishMonthName(month);
      case 'es':
        return _getSpanishMonthName(month);
      case 'fr':
        return _getFrenchMonthName(month);
      case 'de':
        return _getGermanMonthName(month);
      default:
        return _getEnglishMonthName(month);
    }
  }

  String _getEnglishMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  String _getSpanishMonthName(int month) {
    switch (month) {
      case 1:
        return 'Enero';
      case 2:
        return 'Febrero';
      case 3:
        return 'Marzo';
      case 4:
        return 'Abril';
      case 5:
        return 'Mayo';
      case 6:
        return 'Junio';
      case 7:
        return 'Julio';
      case 8:
        return 'Agosto';
      case 9:
        return 'Septiembre';
      case 10:
        return 'Octubre';
      case 11:
        return 'Noviembre';
      case 12:
        return 'Diciembre';
      default:
        return '';
    }
  }

  String _getFrenchMonthName(int month) {
    switch (month) {
      case 1:
        return 'Janvier';
      case 2:
        return 'Février';
      case 3:
        return 'Mars';
      case 4:
        return 'Avril';
      case 5:
        return 'Mai';
      case 6:
        return 'Juin';
      case 7:
        return 'Juillet';
      case 8:
        return 'Août';
      case 9:
        return 'Septembre';
      case 10:
        return 'Octobre';
      case 11:
        return 'Novembre';
      case 12:
        return 'Décembre';
      default:
        return '';
    }
  }

  String _getGermanMonthName(int month) {
    switch (month) {
      case 1:
        return 'Januar';
      case 2:
        return 'Februar';
      case 3:
        return 'März';
      case 4:
        return 'April';
      case 5:
        return 'Mai';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'Dezember';
      default:
        return '';
    }
  }

  // Get localized day name
  String getDayName(int day) {
    final languageCode = _currentLocale.languageCode;

    switch (languageCode) {
      case 'en':
        return _getEnglishDayName(day);
      case 'es':
        return _getSpanishDayName(day);
      case 'fr':
        return _getFrenchDayName(day);
      case 'de':
        return _getGermanDayName(day);
      default:
        return _getEnglishDayName(day);
    }
  }

  String _getEnglishDayName(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _getSpanishDayName(int day) {
    switch (day) {
      case 1:
        return 'Lunes';
      case 2:
        return 'Martes';
      case 3:
        return 'Miércoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }

  String _getFrenchDayName(int day) {
    switch (day) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return '';
    }
  }

  String _getGermanDayName(int day) {
    switch (day) {
      case 1:
        return 'Montag';
      case 2:
        return 'Dienstag';
      case 3:
        return 'Mittwoch';
      case 4:
        return 'Donnerstag';
      case 5:
        return 'Freitag';
      case 6:
        return 'Samstag';
      case 7:
        return 'Sonntag';
      default:
        return '';
    }
  }

  // Check if initialized
  bool get isInitialized => _isInitialized;
}
