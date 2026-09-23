import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rimrid_sasthoseba/localization/app_strings.dart';
import 'package:rimrid_sasthoseba/main.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  });

  testWidgets('RimridSasthosebaApp starts in Bangla by default and toggles to English', (WidgetTester tester) async {
    // Ensure default is Bangla
    LanguageController.instance.setBangla(true);

    await tester.pumpWidget(const RimridSasthosebaApp());
    await tester.pump();

    // Verify initial Bangla text
    expect(find.text('রিমরিদ স্বাস্থ্যসেবা'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget); // Toggle shows 'EN' to switch to English

    // Tap language toggle
    await tester.tap(find.text('EN'));
    await tester.pump(const Duration(milliseconds: 200));

    // Verify English text
    expect(find.text('Rimrid Healthcare'), findsOneWidget);
    expect(find.text('বাং'), findsOneWidget); // Toggle shows 'বাং' to switch back to Bangla
  });
}
