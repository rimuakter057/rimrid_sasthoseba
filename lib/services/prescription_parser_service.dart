import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/medicine.dart';
import '../models/prescription_item.dart';
import 'database_helper.dart';

class PrescriptionParserService {
  static final PrescriptionParserService instance = PrescriptionParserService._internal();
  PrescriptionParserService._internal();

  TextRecognizer? _textRecognizer;

  TextRecognizer get _recognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }

  /// Extracts text from prescription image using ML Kit OCR on mobile,
  /// with graceful platform fallback.
  Future<String> extractTextFromImage(File imageFile) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      // Graceful fallback for desktop/web testing
      return '''
1. Tab. Napa Extra 500mg - 1 + 0 + 1 (খাবার পরে) - ৫ দিন
2. Cap. Seclo 20mg - 1 + 0 + 1 (খাবার ২০ মিনিট আগে) - ১৪ দিন
3. Tab. Monas 10mg - 0 + 0 + 1 (রাতে) - ১ মাস
4. Syp. Tusca 100ml - ২ চামচ করে দিনে ৩ বার (খাবার পরে) - ৭ দিন
''';
    }

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _recognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('OCR Recognition error: $e');
      rethrow;
    }
  }

  /// Parses the raw OCR text into structured PrescriptionItem objects
  Future<List<PrescriptionItem>> parsePrescriptionText(String rawText) async {
    final lines = rawText.split('\n');
    final List<PrescriptionItem> results = [];
    final db = DatabaseHelper.instance;

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.length < 3) continue;

      // Filter out common non-prescription lines (doctor header, clinic address, etc.)
      final lower = trimmed.toLowerCase();
      if (lower.startsWith('dr.') ||
          lower.startsWith('mbbs') ||
          lower.startsWith('fcps') ||
          lower.contains('hospital') ||
          lower.contains('clinic') ||
          lower.contains('phone:') ||
          lower.contains('reg no:') ||
          lower.contains('date:') ||
          lower.contains('age:') ||
          lower.contains('patient name')) {
        continue;
      }

      // 1. Extract frequency (e.g. 1+0+1, ১+০+১, দিনে ৩ বার)
      final frequency = extractFrequency(trimmed);

      // 2. Extract meal timing (e.g. খাবার আগে, খাবার পরে)
      final mealTiming = extractMealTiming(trimmed);

      // 3. Extract duration (e.g. ৭ দিন, 14 days)
      final duration = extractDuration(trimmed);

      // 4. Extract potential medicine name candidates
      final candidateName = extractMedicineNameCandidate(trimmed);
      Medicine? matchedMed;
      String indication = '';

      if (candidateName.isNotEmpty) {
        // Search SQLite database
        final matches = await db.searchMedicineDetails(candidateName, limit: 3);
        if (matches.isNotEmpty) {
          matchedMed = matches.first;
          indication = determineIndication(matchedMed);
        }
      }

      // Add item if we matched a medicine or detected a valid prescription pattern
      if (matchedMed != null || frequency.isNotEmpty || mealTiming.isNotEmpty) {
        results.add(PrescriptionItem(
          rawText: trimmed,
          matchedMedicine: matchedMed,
          frequency: frequency,
          mealTiming: mealTiming,
          duration: duration,
          indication: indication,
        ));
      }
    }

    return results;
  }

  /// Helper to convert English or Bengali digit to int
  static int _parseDigit(String? d) {
    if (d == null || d.isEmpty) return 0;
    if (d == '০' || d == '0') return 0;
    if (d == '১' || d == '1') return 1;
    if (d == '২' || d == '2') return 2;
    if (d == '৩' || d == '3') return 3;
    return int.tryParse(d) ?? 0;
  }

  static String _toBn(int n) {
    const bn = ['০', '১', '২', '৩', '৪', '৫'];
    return bn[n.clamp(0, 5)];
  }

  /// Formats 3-time dose pattern (Morning + Noon + Night) into clear Bengali advice
  static String formatPatternExplanation(int morning, int noon, int night) {
    final bnM = _toBn(morning);
    final bnN = _toBn(noon);
    final bnE = _toBn(night);
    final pattern = '$bnM + $bnN + $bnE';

    int count = 0;
    if (morning > 0) count++;
    if (noon > 0) count++;
    if (night > 0) count++;

    if (count == 0) return pattern;

    if (morning > 0 && noon == 0 && night > 0) {
      if (morning == night) {
        return '$pattern (দিনে ২ বার — সকালে $bnMটি ও রাতে $bnEটি)';
      }
      return '$pattern (দিনে ২ বার — সকালে $bnMটি ও রাতে $bnEটি)';
    } else if (morning > 0 && noon > 0 && night > 0) {
      if (morning == 1 && noon == 1 && night == 1) {
        return '$pattern (দিনে ৩ বার — সকাল, দুপুর ও রাতে ১টি করে)';
      }
      return '$pattern (দিনে ৩ বার — সকালে $bnMটি, দুপুরে $bnNটি ও রাতে $bnEটি)';
    } else if (morning > 0 && noon == 0 && night == 0) {
      return '$pattern (দিনে ১ বার — শুধুমাত্র সকালে $bnMটি)';
    } else if (morning == 0 && noon == 0 && night > 0) {
      return '$pattern (দিনে ১ বার — শুধুমাত্র রাতে $bnEটি)';
    } else if (morning == 0 && noon > 0 && night == 0) {
      return '$pattern (দিনে ১ বার — শুধুমাত্র দুপুরে $bnNটি)';
    } else if (morning > 0 && noon > 0 && night == 0) {
      return '$pattern (দিনে ২ বার — সকালে $bnMটি ও দুপুরে $bnNটি)';
    } else if (morning == 0 && noon > 0 && night > 0) {
      return '$pattern (দিনে ২ বার — দুপুরে $bnNটি ও রাতে $bnEটি)';
    }

    return pattern;
  }

  /// Extracts dosage frequencies like 1+0+1, 1+1+1, 0+0+1, ১+০+১, দিনে ৩ বার, etc.
  String extractFrequency(String text) {
    // 1. Pattern like 1+0+1, 1-0-1, 1/0/1, 1 + 0 + 1 (English or Bengali digits)
    final regex = RegExp(r'([0-3০-৩])\s*[\+\-\/]\s*([0-3০-৩])\s*[\+\-\/]\s*([0-3০-৩])(\s*[\+\-\/]\s*([0-3০-৩]))?');
    final match = regex.firstMatch(text);
    if (match != null) {
      final m = _parseDigit(match.group(1));
      final n = _parseDigit(match.group(2));
      final e = _parseDigit(match.group(3));
      final p4 = match.group(5);

      if (p4 != null) {
        final f = _parseDigit(p4);
        return '${_toBn(m)} + ${_toBn(n)} + ${_toBn(e)} + ${_toBn(f)} (দিনে ৪ বার)';
      }

      return formatPatternExplanation(m, n, e);
    }

    // 2. Common words
    final lower = text.toLowerCase();
    if (lower.contains('দিনে ৩ বার') || lower.contains('3 times daily') || lower.contains('tid')) {
      return '১ + ১ + ১ (দিনে ৩ বার — সকাল, দুপুর ও রাতে)';
    } else if (lower.contains('দিনে ২ বার') || lower.contains('2 times daily') || lower.contains('bid')) {
      return '১ + ০ + ১ (দিনে ২ বার — সকালে ও রাতে)';
    } else if (lower.contains('দিনে ১ বার') || lower.contains('once daily') || lower.contains('qd') || lower.contains('od')) {
      return '১ + ০ + ০ (দিনে ১ বার — সকালে)';
    } else if (lower.contains('রাতে') || lower.contains('bedtime') || lower.contains('hs')) {
      return '০ + ০ + ১ (দিনে ১ বার — রাতে ঘুমানোর আগে)';
    } else if (lower.contains('সকালে') || lower.contains('morning')) {
      return '১ + ০ + ০ (দিনে ১ বার — সকালে)';
    } else if (lower.contains('প্রয়োজনে') || lower.contains('sos')) {
      return 'প্রয়োজন অনুযায়ী (ব্যথা বা জ্বর আসলে)';
    }

    return '';
  }

  /// Extracts meal timing: খাবার আগে / খাবার পরে / Before meal / After meal
  String extractMealTiming(String text) {
    final beforeMealRegex = RegExp(
      r'(খাবার|খাওয়ার|আহারের)\s*([০-৯\d]+\s*মিনিট\s*)?(আগে|পূর্বে)|খালি\s*পেটে|before\s*meal|empty\s*stomach|\bac\b',
      caseSensitive: false,
    );
    final afterMealRegex = RegExp(
      r'(খাবার|খাওয়ার|আহারের)\s*([০-৯\d]+\s*মিনিট\s*)?(পরে)|ভরা\s*পেটে|after\s*meal|with\s*food|\bpc\b',
      caseSensitive: false,
    );

    if (beforeMealRegex.hasMatch(text)) {
      return 'খাবার ২০-৩০ মিনিট আগে';
    } else if (afterMealRegex.hasMatch(text)) {
      return 'খাবার পরে (ভরা পেটে)';
    }
    return '';
  }

  /// Extracts duration: e.g. ৭ দিন, ১৪ দিন, ১ মাস, 5 days, continue
  String extractDuration(String text) {
    final regex = RegExp(
      r'(\d+|[০-৯]+)\s*(দিন|সপ্তাহ|মাস|বছর|days?|weeks?|months?)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    if (match != null) {
      return match.group(0) ?? '';
    }
    if (text.contains('চলবে') || text.toLowerCase().contains('continue')) {
      return 'নিয়মিত চলবে (Continue)';
    }
    return '';
  }

  /// Extracts the candidate medicine brand name from a raw line
  String extractMedicineNameCandidate(String line) {
    // Strip numbering: "1.", "2)", "A)", "*", "Rx"
    var clean = line.replaceFirst(RegExp(r'^\s*(\d+[\.\)]|[A-Za-z][\.\)]|\*|Rx:?|℞)\s*'), '');

    // Strip common prescription prefixes: Tab., Cap., Syp., Inj., Oint., Drop.
    clean = clean.replaceFirst(RegExp(r'^(Tab\.|Tab|Cap\.|Cap|Syp\.|Syp|Inj\.|Inj|Oint\.|Drop\.)\s*', caseSensitive: false), '');

    // Cut off before dosage symbols, hyphens, or brackets
    clean = clean.split(RegExp(r'[\-\–\—\(\[\:\,\+]'))[0].trim();

    // Remove numbers at the end (like strength 500mg, 20mg) to get the clean brand name
    final words = clean.split(RegExp(r'\s+'));
    final candidateWords = <String>[];
    for (final w in words) {
      if (RegExp(r'^\d+').hasMatch(w) || w.toLowerCase().contains('mg') || w.toLowerCase().contains('ml')) {
        // Encountered strength token, stop brand name extraction
        break;
      }
      candidateWords.add(w);
    }

    return candidateWords.join(' ').trim();
  }

  /// Determines indication (রোগের নাম / কাজের উদ্দেশ্য) in simple Bengali
  String determineIndication(Medicine med) {
    final generic = med.generic.toLowerCase();
    final dosage = med.dosage.toLowerCase();

    if (generic.contains('paracetamol')) {
      return 'জ্বর, সর্দি, মাথাব্যথা ও সাধারণ শরীর ব্যথা';
    } else if (generic.contains('omeprazole') ||
        generic.contains('esomeprazole') ||
        generic.contains('pantoprazole') ||
        generic.contains('rabeprazole')) {
      return 'গ্যাস্ট্রিক, এসিডিটি, বুক জ্বালাপোড়া ও পেটের আলসার';
    } else if (generic.contains('montelukast')) {
      return 'অ্যাজমা, শ্বাসকষ্ট, হাঁপানি ও ক্রনিক এলার্জি';
    } else if (generic.contains('cetirizine') ||
        generic.contains('fexofenadine') ||
        generic.contains('loratadine') ||
        generic.contains('bilastine') ||
        generic.contains('desloratadine')) {
      return 'এলার্জি, হাঁচি, চুলকানি ও সর্দি';
    } else if (generic.contains('azithromycin') ||
        generic.contains('cefixime') ||
        generic.contains('amoxicillin') ||
        generic.contains('ciprofloxacin') ||
        generic.contains('cefpodoxime')) {
      return 'ব্যাকটেরিয়াল ইনফেকশন ও সংক্রমণ নিরাময় (অ্যান্টিবায়োটিক)';
    } else if (generic.contains('metformin') || generic.contains('glimepiride') || generic.contains('vildagliptin')) {
      return 'রক্তে সুগারের মাত্রা নিয়ন্ত্রণ (ডায়াবেটিস)';
    } else if (generic.contains('amlodipine') ||
        generic.contains('losartan') ||
        generic.contains('telmisartan') ||
        generic.contains('bisoprolol')) {
      return 'উচ্চ রক্তচাপ নিয়ন্ত্রণ ও হৃদরোগের ঝুঁকি কমানো';
    } else if (generic.contains('domperidone')) {
      return 'বমি বমি ভাব, পেট ফাঁপা ও বদহজম';
    } else if (generic.contains('bromhexine') || generic.contains('dextromethorphan') || generic.contains('ambroxol')) {
      return 'কাশি উপশম ও কফ তরল করা';
    } else if (generic.contains('calcium') || generic.contains('vitamin')) {
      return 'হাড় মজবুত করা ও পুষ্টির ঘাটতি পূরণ';
    }

    if (dosage.contains('fever') || dosage.contains('pain')) {
      return 'ব্যথা ও জ্বর নিরাময়';
    } else if (dosage.contains('infection')) {
      return 'সংক্রমণ নিরাময়';
    }

    return 'চিকিৎসকের পরামর্শ অনুযায়ী নির্ধারিত রোগের নিরাময়';
  }

  void dispose() {
    _textRecognizer?.close();
  }
}
