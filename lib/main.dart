import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/transaction_provider.dart';
import 'screens/login_screen.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

// Only import Firebase Analytics on non-Windows platforms
// On Windows, this import will fail gracefully
import 'package:firebase_analytics/firebase_analytics.dart'
    show FirebaseAnalytics, FirebaseAnalyticsObserver;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Get navigator observers - only include Firebase Analytics on non-Windows platforms
  static List<NavigatorObserver> _getNavigatorObservers() {
    // Check for "native" Windows (not web running on Windows)
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      return [];
    }

    // For non-Windows platforms (and Web), try to initialize Firebase Analytics
    try {
      final analytics = FirebaseAnalytics.instance;
      return [
        FirebaseAnalyticsObserver(analytics: analytics),
      ];
    } on PlatformException catch (e) {
      // Catch PlatformException specifically
      debugPrint('Firebase Analytics PlatformException: ${e.message}');
      return [];
    } catch (e) {
      // Catch any other errors
      debugPrint('Firebase Analytics error: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: MaterialApp(
        title: 'Crane Service App',
        debugShowCheckedModeBanner: false,
        navigatorObservers: _getNavigatorObservers(),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1), // Modern Indigo
            primary: const Color(0xFF6366F1),
            secondary: const Color(0xFF8B5CF6), // Purple accent
            tertiary: const Color(0xFFEC4899), // Pink accent
            brightness: Brightness.light,
            background: const Color(0xFFF8FAFC),
            surface: Colors.white,
            surfaceContainerHighest: const Color(0xFFF1F5F9),
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E293B),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withOpacity(0.1),
            titleTextStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Color(0xFF1E293B),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF6366F1)),
          ),
          fontFamily: 'Inter',
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: Color(0xFF0F172A),
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Color(0xFF1E293B),
            ),
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: Color(0xFF1E293B),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Color(0xFF6366F1), width: 2.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Color(0xFFEF4444), width: 2.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            labelStyle: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shadowColor: Colors.transparent,
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.shade100, width: 1),
            ),
            shadowColor: Colors.black.withOpacity(0.05),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: Colors.grey.shade100,
            selectedColor: const Color(0xFF6366F1).withOpacity(0.15),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
