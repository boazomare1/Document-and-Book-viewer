import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/pdf_provider.dart';
import 'providers/accessibility_provider.dart';
import 'providers/annotation_provider.dart';
// import 'providers/ai_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ModernPdfReaderApp());
}

class ModernPdfReaderApp extends StatelessWidget {
  const ModernPdfReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PdfProvider()),
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
        ChangeNotifierProvider(create: (_) => AnnotationProvider()),
        // ChangeNotifierProvider(create: (_) => AIProvider()),
      ],
      child: MaterialApp(
        title: 'Modern PDF Reader',
        debugShowCheckedModeBanner: false,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',

      // Adaptive Typography
      textTheme: Typography.material2021().englishLike.copyWith(
        displayLarge: Typography.material2021().englishLike.displayLarge
            ?.copyWith(
              fontSize: 57,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.25,
            ),
        displayMedium: Typography.material2021().englishLike.displayMedium
            ?.copyWith(
              fontSize: 45,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
        displaySmall: Typography.material2021().englishLike.displaySmall
            ?.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
        headlineLarge: Typography.material2021().englishLike.headlineLarge
            ?.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
        headlineMedium: Typography.material2021().englishLike.headlineMedium
            ?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
        headlineSmall: Typography.material2021().englishLike.headlineSmall
            ?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
        titleLarge: Typography.material2021().englishLike.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        titleMedium: Typography.material2021().englishLike.titleMedium
            ?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.15,
            ),
        titleSmall: Typography.material2021().englishLike.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: Typography.material2021().englishLike.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: Typography.material2021().englishLike.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: Typography.material2021().englishLike.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        labelLarge: Typography.material2021().englishLike.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: Typography.material2021().englishLike.labelMedium
            ?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
        labelSmall: Typography.material2021().englishLike.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF6750A4),
        unselectedItemColor: Color(0xFF79747E),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F2FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6750A4), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(size: 24, color: Color(0xFF6750A4)),

      // Chip Theme
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        backgroundColor: const Color(0xFFF7F2FA),
        selectedColor: const Color(0xFF6750A4),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        brightness: Brightness.dark,
      ),
      fontFamily: 'Roboto',

      // Adaptive Typography (same as light theme)
      textTheme: Typography.material2021().englishLike.copyWith(
        displayLarge: Typography.material2021().englishLike.displayLarge
            ?.copyWith(
              fontSize: 57,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.25,
            ),
        displayMedium: Typography.material2021().englishLike.displayMedium
            ?.copyWith(
              fontSize: 45,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
        displaySmall: Typography.material2021().englishLike.displaySmall
            ?.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
        headlineLarge: Typography.material2021().englishLike.headlineLarge
            ?.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
        headlineMedium: Typography.material2021().englishLike.headlineMedium
            ?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
        headlineSmall: Typography.material2021().englishLike.headlineSmall
            ?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
        titleLarge: Typography.material2021().englishLike.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        titleMedium: Typography.material2021().englishLike.titleMedium
            ?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.15,
            ),
        titleSmall: Typography.material2021().englishLike.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: Typography.material2021().englishLike.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: Typography.material2021().englishLike.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: Typography.material2021().englishLike.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        labelLarge: Typography.material2021().englishLike.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: Typography.material2021().englishLike.labelMedium
            ?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
        labelSmall: Typography.material2021().englishLike.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFFD0BCFF),
        unselectedItemColor: Color(0xFFCAC4D0),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2B2930),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD0BCFF), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(size: 24, color: Color(0xFFD0BCFF)),

      // Chip Theme
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        backgroundColor: const Color(0xFF2B2930),
        selectedColor: const Color(0xFF6750A4),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
