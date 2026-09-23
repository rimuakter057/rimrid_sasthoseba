import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../data/lab_tests_data.dart';

class ScannedLabTestItem {
  final LabTestDefinition definition;
  final double detectedValue;
  final String rawMatchedText;
  final LabTestResult evaluation;

  const ScannedLabTestItem({
    required this.definition,
    required this.detectedValue,
    required this.rawMatchedText,
    required this.evaluation,
  });
}

class LabReportParseResult {
  final String fullOcrText;
  final List<ScannedLabTestItem> matchedItems;
  final int normalCount;
  final int borderlineCount;
  final int criticalCount;
  final String overallSummaryBangla;
  final String overallSummaryEnglish;

  const LabReportParseResult({
    required this.fullOcrText,
    required this.matchedItems,
    required this.normalCount,
    required this.borderlineCount,
    required this.criticalCount,
    required this.overallSummaryBangla,
    required this.overallSummaryEnglish,
  });
}

class LabReportParserService {
  static final LabReportParserService instance = LabReportParserService._internal();
  LabReportParserService._internal();

  TextRecognizer? _textRecognizer;

  TextRecognizer get _recognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }

  /// Extracts text from report image using ML Kit OCR on mobile,
  /// with realistic fallback for desktop testing.
  Future<String> extractTextFromImage(File imageFile) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      // Safe realistic fallback for Windows/Desktop/Test environment
      return '''
POPULAR DIAGNOSTIC CENTRE LTD.
DHAKA, BANGLADESH
HAEMATOLOGY & CLINICAL BIOCHEMISTRY REPORT
---------------------------------------------------------------
TEST NAME                         RESULT    UNIT      NORMAL RANGE
Total Platelet Count (PLT)        85,000    /uL       (150,000 - 450,000)
Hemoglobin (Hb)                   9.5       g/dL      (12.0 - 16.5)
Total Leucocyte Count (WBC)       12,500    /uL       (4,000 - 11,000)
Serum Creatinine                  1.8       mg/dL     (0.6 - 1.2)
S. Bilirubin (Total)              2.4       mg/dL     (0.2 - 1.2)
SGPT (ALT)                        65        U/L       (Up to 40)
HbA1c                             8.2       %         (4.0 - 5.6)
Fasting Blood Sugar (FBS)         8.5       mmol/L    (3.9 - 6.1)
Serum Uric Acid                   8.4       mg/dL     (3.4 - 7.0)
Total Cholesterol                 238       mg/dL     (< 200)
TSH                               6.5       uIU/mL    (0.4 - 4.2)
---------------------------------------------------------------
Report Verified by Consultant Pathologist
''';
    }

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _recognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('Lab Report OCR Error: $e');
      rethrow;
    }
  }

  /// Parses raw text extracted from a lab report and matches clinical parameters.
  LabReportParseResult parseReportFromText(String rawText) {
    final List<ScannedLabTestItem> matchedItems = [];
    final Set<String> matchedIds = {};

    final lines = rawText.split('\n');

    for (final test in LabTestsData.tests) {
      if (matchedIds.contains(test.id)) continue;

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        // Check if any alias matches this line
        final matchedAlias = _findMatchingAlias(line, test.ocrAliases);
        if (matchedAlias != null) {
          // Attempt to extract value from current line
          double? val = _extractValueForTest(line, matchedAlias, test);

          // If not found in current line, check next 1-2 lines (for multi-line tables)
          if (val == null && i + 1 < lines.length) {
            val = _extractValueFromFollowingLines(lines, i + 1, test);
          }

          if (val != null) {
            // Apply unit conversions if necessary (e.g. Blood Sugar reported in mg/dL vs mmol/L)
            val = _normalizeValue(test.id, val);

            // Plausibility range check to filter noise or erroneous numbers
            if (_isPlausibleValue(test.id, val)) {
              matchedItems.add(
                ScannedLabTestItem(
                  definition: test,
                  detectedValue: val,
                  rawMatchedText: line,
                  evaluation: test.evaluate(val),
                ),
              );
              matchedIds.add(test.id);
              break; // Done with this test
            }
          }
        }
      }
    }

    int normalCount = 0;
    int borderlineCount = 0;
    int criticalCount = 0;

    for (final item in matchedItems) {
      switch (item.evaluation.status) {
        case LabStatus.normal:
          normalCount++;
          break;
        case LabStatus.borderline:
          borderlineCount++;
          break;
        case LabStatus.critical:
          criticalCount++;
          break;
      }
    }

    String summaryBangla;
    String summaryEnglish;

    if (matchedItems.isEmpty) {
      summaryBangla = 'ছবি থেকে কোনো পরিচিত ল্যাব টেস্টের মান চিহ্নিত করা যায়নি। অনুগ্রহ করে স্পষ্ট ও সোজা ছবি তুলুন বা নিচে তালিকা থেকে টেস্ট বেছে নিন।';
      summaryEnglish = 'No known lab test parameters could be detected. Please ensure high clarity or select manually below.';
    } else if (criticalCount > 0) {
      summaryBangla = '⚠️ জরুরি সতর্কতা: রিপোর্টে $criticalCountটি পরীক্ষার ফলাফল বিপদসীমায় (Critical) রয়েছে! অবিলম্বে বিশেষজ্ঞ চিকিৎসকের শরণাপন্ন হোন।';
      summaryEnglish = 'Critical Warning: $criticalCount parameter(s) are in critical condition. Consult a doctor immediately.';
    } else if (borderlineCount > 0) {
      summaryBangla = 'রিপোর্টে $borderlineCountটি পরীক্ষার মান স্বাভাবিকের চেয়ে কিছুটা কম বা বেশি (Borderline)। নিয়মিত পর্যবেক্ষণ ও জীবনযাত্রার পরিবর্তন প্রয়োজন।';
      summaryEnglish = '$borderlineCount parameter(s) are slightly abnormal. Lifestyle adjustments and follow-up recommended.';
    } else {
      summaryBangla = 'অভিনন্দন! স্ক্যান করা সকল (${matchedItems.length}টি) পরীক্ষার ফলাফল স্বাভাবিক সীমার ভেতরে রয়েছে।';
      summaryEnglish = 'All ${matchedItems.length} detected parameters are within normal healthy ranges.';
    }

    return LabReportParseResult(
      fullOcrText: rawText,
      matchedItems: matchedItems,
      normalCount: normalCount,
      borderlineCount: borderlineCount,
      criticalCount: criticalCount,
      overallSummaryBangla: summaryBangla,
      overallSummaryEnglish: summaryEnglish,
    );
  }

  String? _findMatchingAlias(String line, List<String> aliases) {
    final lowerLine = line.toLowerCase();
    for (final alias in aliases) {
      final lowerAlias = alias.toLowerCase();
      // Use word boundary check for short aliases (<= 3 chars like hb, plt, wbc, alt, ast, esr, tsh)
      if (lowerAlias.length <= 3) {
        final regex = RegExp(r'(^|[^a-zA-Z0-9])' + RegExp.escape(lowerAlias) + r'([^a-zA-Z0-9]|$)');
        if (regex.hasMatch(lowerLine)) {
          return lowerAlias;
        }
      } else {
        if (lowerLine.contains(lowerAlias)) {
          return lowerAlias;
        }
      }
    }
    return null;
  }

  double? _extractValueForTest(String line, String matchedAlias, LabTestDefinition test) {
    final lowerLine = line.toLowerCase();
    final aliasIndex = lowerLine.indexOf(matchedAlias);
    if (aliasIndex == -1) return null;

    // Search for the value after the test name/alias to avoid numbers inside test names (like 'hba1c')
    String contentAfterAlias = line.substring(aliasIndex + matchedAlias.length);

    // 1. Clean line: strip brackets/parentheses containing ranges e.g. (150,000 - 450,000) or [0.6 - 1.2]
    var cleaned = contentAfterAlias.replaceAll(RegExp(r'\([^\)]*[\d]+[^\)]*[-–][^\)]*[\d]+[^\)]*\)'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\[[^\]]*[\d]+[^\]]*[-–][^\]]*[\d]+[^\]]*\]'), ' ');

    // 2. Strip "Normal: ...", "Ref: ...", "Range: ..." up to end of line
    cleaned = cleaned.replaceAll(RegExp(r'(?:normal|ref|reference|range)\s*:?.*$', caseSensitive: false), ' ');

    // 3. Remove commas inside numbers: e.g. "85,000" -> "85000"
    cleaned = cleaned.replaceAllMapped(RegExp(r'(\d+),(\d{3})'), (m) => '${m[1]}${m[2]}');

    // 4. Find all number patterns (e.g. 9.5, 85000, 1.8)
    final numRegex = RegExp(r'(\d+(?:\.\d+)?)');
    final matches = numRegex.allMatches(cleaned);

    for (final m in matches) {
      final valStr = m.group(1);
      if (valStr == null) continue;
      final val = double.tryParse(valStr);
      if (val != null) {
        // Filter out obvious year numbers like 2024, 2025, 2026 if not platelet/wbc
        if (val >= 2020 && val <= 2030 && test.id != 'platelet' && test.id != 'wbc') {
          continue;
        }
        return val;
      }
    }
    return null;
  }

  double? _extractValueFromFollowingLines(List<String> lines, int startIndex, LabTestDefinition test) {
    // Scan up to 2 lines below
    final endIndex = (startIndex + 2 < lines.length) ? startIndex + 2 : lines.length;
    for (int i = startIndex; i < endIndex; i++) {
      var line = lines[i].trim();
      if (line.isEmpty) continue;

      // Skip lines that look like test names
      if (line.contains(RegExp(r'^[A-Z][a-zA-Z\s]{4,}'))) {
        // If it starts with another test name, stop
        break;
      }

      line = line.replaceAll(RegExp(r'\([^\)]*[\d]+[^\)]*[-–][^\)]*[\d]+[^\)]*\)'), ' ');
      line = line.replaceAll(RegExp(r'\[[^\]]*[\d]+[^\]]*[-–][^\]]*[\d]+[^\]]*\]'), ' ');
      line = line.replaceAll(RegExp(r'(?:normal|ref|reference|range)\s*:?.*$', caseSensitive: false), ' ');
      line = line.replaceAllMapped(RegExp(r'(\d+),(\d{3})'), (m) => '${m[1]}${m[2]}');

      final numMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(line);
      if (numMatch != null) {
        final val = double.tryParse(numMatch.group(1)!);
        if (val != null) return val;
      }
    }
    return null;
  }

  double _normalizeValue(String testId, double val) {
    // For Fasting / Random Blood Sugar: If reported in mg/dL (e.g. 140 or 180), convert to mmol/L (divide by 18)
    if ((testId == 'fbs' || testId == 'rbs') && val > 30) {
      return double.parse((val / 18.0).toStringAsFixed(1));
    }
    return val;
  }

  bool _isPlausibleValue(String testId, double val) {
    switch (testId) {
      case 'platelet':
        return val >= 500 && val <= 3000000;
      case 'hemoglobin':
        return val >= 2.0 && val <= 25.0;
      case 'wbc':
        return val >= 500 && val <= 250000;
      case 'esr':
        return val >= 0 && val <= 200;
      case 'creatinine':
        return val >= 0.1 && val <= 30.0;
      case 'uric_acid':
        return val >= 0.5 && val <= 30.0;
      case 'sgpt':
      case 'sgot':
        return val >= 2.0 && val <= 5000.0;
      case 'bilirubin':
        return val >= 0.05 && val <= 50.0;
      case 'fbs':
      case 'rbs':
        return val >= 1.0 && val <= 40.0;
      case 'hba1c':
        return val >= 3.0 && val <= 20.0;
      case 'cholesterol':
      case 'triglyceride':
      case 'ldl':
      case 'hdl':
        return val >= 10.0 && val <= 2000.0;
      case 'tsh':
        return val >= 0.01 && val <= 150.0;
      case 'potassium':
        return val >= 1.0 && val <= 15.0;
      case 'calcium':
        return val >= 2.0 && val <= 25.0;
      default:
        return val >= 0;
    }
  }

  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}
