import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/medicine.dart';
import '../models/medicine_reminder.dart';

class DatabaseHelper {
  static const String _dbName = 'rimrid_medicine.db';
  static const int _dbVersion = 2;
  static const String tableName = 'medicines';
  static const String remindersTable = 'reminders';

  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brand_name TEXT NOT NULL,
        generic TEXT,
        manufacturer TEXT,
        strength TEXT,
        dosage_form TEXT,
        dosage TEXT,
        side_effects TEXT
      )
    ''');

    // Indexes for fast instant lookup on both Brand Name and Generic Name
    await db.execute('CREATE INDEX idx_med_brand ON $tableName (brand_name COLLATE NOCASE);');
    await db.execute('CREATE INDEX idx_med_generic ON $tableName (generic COLLATE NOCASE);');

    await _createRemindersTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createRemindersTable(db);
    }
  }

  Future<void> _createRemindersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $remindersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicine_name TEXT NOT NULL,
        dosage TEXT,
        meal_timing TEXT,
        time_hour INTEGER NOT NULL,
        time_minute INTEGER NOT NULL,
        is_morning INTEGER DEFAULT 0,
        is_noon INTEGER DEFAULT 0,
        is_night INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        last_taken_date TEXT
      )
    ''');
  }

  /// Check whether the database has already been populated with CSV records
  Future<bool> isDatabasePopulated() async {
    try {
      final db = await database;
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
      );
      return (count ?? 0) > 0;
    } catch (_) {
      return false;
    }
  }

  /// Total count of medicines in the database
  Future<int> getMedicineCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
    );
    return count ?? 0;
  }

  /// Cleans raw HTML tags, list items, breaks, and entities from dataset descriptions
  static String cleanHtml(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    String text = raw;

    // Convert line breaks and paragraph ends
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</(p|div|tr|h[1-6])>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '• ');
    text = text.replaceAll(RegExp(r'</li>', caseSensitive: false), '\n');

    // Strip remaining HTML tags
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');

    // Replace HTML entities
    text = text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#160;', ' ');

    // Clean whitespace and excessive empty lines
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
    text = text.replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n');
    return text.trim();
  }

  /// Reads CSV files from assets/medicine/ and populates SQLite database
  Future<void> populateDatabaseFromCsv({
    void Function(double progress, String status)? onProgress,
  }) async {
    final db = await database;

    // Notify: Loading generic data
    onProgress?.call(0.1, 'জেনেরিক ও সেবনবিধির তথ্য লোড করা হচ্ছে...');

    final genericMap = <String, Map<String, String>>{};
    try {
      final genericCsvString = await rootBundle.loadString('assets/medicine/generic.csv');
      final genericRows = const CsvToListConverter(shouldParseNumbers: false).convert(genericCsvString);

      // generic.csv columns:
      // index 1: generic name
      // index 9: dosage description
      // index 10: administration description (খাওয়ার নিয়ম)
      // index 13: side effects description (পার্শ্বপ্রতিক্রিয়া)
      for (final row in genericRows.skip(1)) {
        if (row.length > 13) {
          final genericName = row[1].toString().trim().toLowerCase();
          final dosageDesc = cleanHtml(row[9].toString());
          final adminDesc = cleanHtml(row[10].toString());
          final sideEffects = cleanHtml(row[13].toString());

          String fullDosage = '';
          if (adminDesc.isNotEmpty && dosageDesc.isNotEmpty) {
            fullDosage = 'খাওয়ার নিয়ম:\n$adminDesc\n\nমাত্রা ও সেবনবিধি:\n$dosageDesc';
          } else if (adminDesc.isNotEmpty) {
            fullDosage = adminDesc;
          } else {
            fullDosage = dosageDesc;
          }

          genericMap[genericName] = {
            'dosage': fullDosage,
            'side_effects': sideEffects,
          };
        }
      }
    } catch (e) {
      // In case generic.csv is optional or missing
      // ignore and continue with medicine.csv
    }

    onProgress?.call(0.35, 'ওষুধের তালিকা লোড করা হচ্ছে...');

    final medCsvString = await rootBundle.loadString('assets/medicine/medicine.csv');
    final medRows = const CsvToListConverter(shouldParseNumbers: false).convert(medCsvString);

    if (medRows.length <= 1) return;

    final totalRows = medRows.length - 1;
    const chunkSize = 1000;

    onProgress?.call(0.5, 'ডাটাবেসে তথ্য সংরক্ষণ করা হচ্ছে...');

    for (var i = 1; i < medRows.length; i += chunkSize) {
      final batch = db.batch();
      final end = (i + chunkSize < medRows.length) ? i + chunkSize : medRows.length;

      for (var j = i; j < end; j++) {
        final row = medRows[j];
        if (row.length < 8) continue;

        // medicine.csv columns:
        // 1: brand name
        // 4: dosage form (Tablet, Syrup, etc.)
        // 5: generic
        // 6: strength
        // 7: manufacturer
        final brandName = row[1].toString().trim();
        final dosageForm = row[4].toString().trim();
        final generic = row[5].toString().trim();
        final strength = row[6].toString().trim();
        final manufacturer = row[7].toString().trim();

        // Retrieve mapped dosage and side-effects from generic
        final genInfo = genericMap[generic.toLowerCase()];
        final dosage = genInfo?['dosage'] ?? '';
        final sideEffects = genInfo?['side_effects'] ?? '';

        batch.insert(tableName, {
          'brand_name': brandName,
          'generic': generic,
          'manufacturer': manufacturer,
          'strength': strength,
          'dosage_form': dosageForm,
          'dosage': dosage,
          'side_effects': sideEffects,
        });
      }

      await batch.commit(noResult: true);

      final progress = 0.5 + ((end - 1) / totalRows) * 0.5;
      onProgress?.call(
        progress,
        'সংরক্ষণ হচ্ছে: $end / $totalRows টি ওষুধ...',
      );
    }

    onProgress?.call(1.0, 'সম্পন্ন হয়েছে!');
  }

  /// Offline search function searching brand_name or generic using SQLite LIKE
  /// Results are prioritized: Exact brand match -> Prefix brand match -> Generic matches
  Future<List<Medicine>> searchMedicineDetails(String query, {int limit = 50}) async {
    final db = await database;
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      // Default to returning top 30 common/popular medicines
      final results = await db.query(
        tableName,
        limit: 30,
        orderBy: 'brand_name ASC',
      );
      return results.map((m) => Medicine.fromMap(m)).toList();
    }

    final wildQuery = '%$cleanQuery%';
    final prefixQuery = '$cleanQuery%';

    var results = await db.rawQuery('''
      SELECT * FROM $tableName 
      WHERE brand_name LIKE ? OR generic LIKE ?
      ORDER BY 
        CASE 
          WHEN LOWER(brand_name) = LOWER(?) THEN 1
          WHEN LOWER(brand_name) LIKE LOWER(?) THEN 2
          WHEN LOWER(generic) LIKE LOWER(?) THEN 3
          ELSE 4
        END,
        brand_name ASC
      LIMIT ?
    ''', [wildQuery, wildQuery, cleanQuery, prefixQuery, prefixQuery, limit]);

    // If no direct matches, try phonetic & spelling variations (e.g. saclo -> seclo, histasin -> histacin)
    if (results.isEmpty) {
      final variations = _generateSpellingVariations(cleanQuery);
      for (final alt in variations) {
        final altWild = '%$alt%';
        final altPrefix = '$alt%';
        final altResults = await db.rawQuery('''
          SELECT * FROM $tableName 
          WHERE brand_name LIKE ? OR generic LIKE ?
          ORDER BY 
            CASE 
              WHEN LOWER(brand_name) = LOWER(?) THEN 1
              WHEN LOWER(brand_name) LIKE LOWER(?) THEN 2
              WHEN LOWER(generic) LIKE LOWER(?) THEN 3
              ELSE 4
            END,
            brand_name ASC
          LIMIT ?
        ''', [altWild, altWild, alt, altPrefix, altPrefix, limit]);

        if (altResults.isNotEmpty) {
          results = altResults;
          break;
        }
      }
    }

    return results.map((m) => Medicine.fromMap(m)).toList();
  }

  /// Generates phonetic and common Bengali-English spelling variations
  static List<String> _generateSpellingVariations(String term) {
    final lower = term.toLowerCase().trim();
    final variations = <String>{};

    // saclo <-> seclo
    if (lower.contains('saclo')) variations.add(lower.replaceAll('saclo', 'seclo'));
    if (lower.contains('seclo')) variations.add(lower.replaceAll('seclo', 'saclo'));

    // histasin <-> histacin, sin <-> cin
    if (lower.contains('histasin')) variations.add(lower.replaceAll('histasin', 'histacin'));
    if (lower.contains('histacin')) variations.add(lower.replaceAll('histacin', 'histasin'));
    if (lower.contains('sin')) variations.add(lower.replaceAll('sin', 'cin'));
    if (lower.contains('cin')) variations.add(lower.replaceAll('cin', 'sin'));

    // a <-> e
    if (lower.startsWith('sa')) variations.add('se${lower.substring(2)}');
    if (lower.contains('a')) variations.add(lower.replaceAll('a', 'e'));
    if (lower.contains('e')) variations.add(lower.replaceAll('e', 'a'));

    // i <-> e (e.g. paracitamol <-> paracetamol)
    if (lower.contains('cita')) variations.add(lower.replaceAll('cita', 'ceta'));
    if (lower.contains('i')) variations.add(lower.replaceAll('i', 'e'));

    // ph <-> f
    if (lower.contains('ph')) variations.add(lower.replaceAll('ph', 'f'));
    if (lower.contains('f')) variations.add(lower.replaceAll('f', 'ph'));

    // k <-> c
    if (lower.contains('k')) variations.add(lower.replaceAll('k', 'c'));
    if (lower.contains('c')) variations.add(lower.replaceAll('c', 'k'));

    // Prefix stem if 4+ characters
    if (lower.length >= 4) {
      variations.add(lower.substring(0, lower.length - 1));
      variations.add(lower.substring(0, 4));
    }

    variations.remove(lower);
    return variations.toList();
  }

  /// Fetch a single medicine by its ID
  Future<Medicine?> getMedicineById(int id) async {
    final db = await database;
    final results = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return Medicine.fromMap(results.first);
    }
    return null;
  }

  // ==================== REMINDER CRUD METHODS ====================

  /// Insert a new medicine reminder
  Future<int> insertReminder(MedicineReminder reminder) async {
    final db = await database;
    await _createRemindersTable(db);
    return await db.insert(remindersTable, reminder.toMap());
  }

  /// Get all medicine reminders sorted by morning/noon/night and time
  Future<List<MedicineReminder>> getAllReminders() async {
    final db = await database;
    await _createRemindersTable(db);
    final results = await db.query(
      remindersTable,
      orderBy: 'time_hour ASC, time_minute ASC',
    );
    return results.map((m) => MedicineReminder.fromMap(m)).toList();
  }

  /// Update an existing reminder
  Future<int> updateReminder(MedicineReminder reminder) async {
    final db = await database;
    if (reminder.id == null) return 0;
    return await db.update(
      remindersTable,
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  /// Delete a reminder by ID
  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete(
      remindersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Toggle active state of a reminder
  Future<void> toggleReminderActive(int id, bool isActive) async {
    final db = await database;
    await db.update(
      remindersTable,
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Mark reminder as taken today
  Future<void> markReminderTaken(int id, DateTime date) async {
    final db = await database;
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    await db.update(
      remindersTable,
      {'last_taken_date': dateStr},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Unmark reminder taken status (reset back to not taken)
  Future<void> unmarkReminderTaken(int id) async {
    final db = await database;
    await db.update(
      remindersTable,
      {'last_taken_date': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
