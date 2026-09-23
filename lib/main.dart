import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'localization/app_strings.dart';
import 'screens/main_dashboard_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite ffi for Windows, Linux, and macOS desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize language preference (defaults to Bangla)
  await LanguageController.instance.init();

  // Initialize notifications and Firebase messaging safely
  await NotificationService.instance.init();

  runApp(const RimridSasthosebaApp());
}

class RimridSasthosebaApp extends StatelessWidget {
  const RimridSasthosebaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageController.instance,
      builder: (context, _) {
        final strings = AppStrings(LanguageController.instance.isBangla);
        return MaterialApp(
          title: strings.appTitle,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0A6847),
              primary: const Color(0xFF0A6847),
              secondary: const Color(0xFF10B981),
              surface: Colors.white,
            ),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0A6847),
              foregroundColor: Colors.white,
              centerTitle: false,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
            ),
          ),
          home: const MainDashboardScreen(),
        );
      },
    );
  }
}
