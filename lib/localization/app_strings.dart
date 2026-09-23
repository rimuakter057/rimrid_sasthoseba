import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  static final LanguageController instance = LanguageController._internal();
  LanguageController._internal();

  static const String _prefKey = 'selected_language';
  bool _isBangla = true; // Initially Bangla as requested

  bool get isBangla => _isBangla;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null) {
        _isBangla = (saved == 'bn');
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> toggleLanguage() async {
    _isBangla = !_isBangla;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, _isBangla ? 'bn' : 'en');
    } catch (_) {}
  }

  Future<void> setBangla(bool value) async {
    if (_isBangla == value) return;
    _isBangla = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, _isBangla ? 'bn' : 'en');
    } catch (_) {}
  }

  /// Converts English digits to Bengali digits when in Bangla mode
  String formatNumber(int number) {
    if (!_isBangla) return number.toString();
    const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final s = number.toString();
    final sb = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final charCode = s.codeUnitAt(i);
      if (charCode >= 48 && charCode <= 57) {
        sb.write(bnDigits[charCode - 48]);
      } else {
        sb.writeCharCode(charCode);
      }
    }
    return sb.toString();
  }
}

class AppStrings {
  final bool isBangla;
  const AppStrings(this.isBangla);

  // App Title & Tagline
  String get appTitle => isBangla ? 'রিমরিদ স্বাস্থ্যসেবা' : 'Rimrid Healthcare';
  String get appSubtitle => isBangla ? 'সম্পূর্ণ অফলাইন ওষুধের তথ্যভাণ্ডার' : 'Complete Offline Medicine Database';
  String get offlineBadge => isBangla ? '১০০% অফলাইন' : '100% Offline';

  // Search & Filters
  String get searchHint => isBangla
      ? 'ওষুধের নাম বা জেনেরিক লিখুন (যেমন: Napa, Seclo)...'
      : 'Search by brand or generic (e.g. Napa, Seclo)...';
  String get popularLabel => isBangla ? 'সাধারণ ওষুধ:' : 'Popular:';
  String searchResultsCount(int count) => isBangla
      ? 'খোঁজার ফলাফল (${LanguageController.instance.formatNumber(count)} টি)'
      : 'Search Results ($count items)';
  String get recentPopularTitle => isBangla ? 'সর্বশেষ / জনপ্রিয় ওষুধসমূহ' : 'Recent & Popular Medicines';
  String totalMedicines(int count) => isBangla
      ? 'মোট ওষুধ: ${LanguageController.instance.formatNumber(count)} টি'
      : 'Total: $count medicines';

  // Empty State
  String get notFoundTitle => isBangla ? 'কোনো ওষুধ খুঁজে পাওয়া যায়নি' : 'No Medicines Found';
  String get notFoundSubtitle => isBangla
      ? 'বানান সঠিক আছে কিনা যাচাই করুন অথবা জেনেরিক নাম লিখে চেষ্টা করুন।'
      : 'Please check the spelling or try searching with the generic name.';

  // Labels
  String get genericLabel => isBangla ? 'জেনেরিক:' : 'Generic:';
  String get genericHeading => isBangla ? 'জেনেরিক নাম (Generic)' : 'Generic Name';
  String get companyLabel => isBangla ? 'কোম্পানি:' : 'Company:';
  String get companyHeading => isBangla ? 'কোম্পানি / প্রস্তুতকারক' : 'Manufacturer';
  String get strengthLabel => isBangla ? 'শক্তি / Power:' : 'Strength:';
  String get dosagePreviewLabel => isBangla ? 'খাওয়ার নিয়ম:' : 'Dosage:';
  String get dosageHeading => isBangla ? 'খাওয়ার নিয়ম ও সেবনবিধি (Dosage)' : 'Dosage & Administration';
  String get sideEffectsPreviewLabel => isBangla ? 'পার্শ্বপ্রতিক্রিয়া:' : 'Side Effects:';
  String get sideEffectsHeading => isBangla ? 'পার্শ্বপ্রতিক্রিয়া (Side Effects)' : 'Side Effects & Warnings';
  String get noData => isBangla ? 'তথ্য নেই' : 'Not available';
  String get offlineDataTag => isBangla ? 'অফলাইন তথ্য' : 'Offline Data';

  // Actions & Buttons
  String get largeFont => isBangla ? 'বড় হরফ' : 'Large Font';
  String get normalFont => isBangla ? 'স্বাভাবিক' : 'Normal Font';
  String get copyTooltip => isBangla ? 'কপি করুন' : 'Copy';
  String copiedMessage(String item) => isBangla ? '$item কপি করা হয়েছে' : '$item copied to clipboard';
  String get languageSwitchLabel => isBangla ? 'EN' : 'বাং';
  String get languageSwitchTooltip => isBangla ? 'Switch to English' : 'বাংলায় পরিবর্তন করুন';

  // Disclaimer & Guidelines
  String get defaultDosageAdvice => isBangla
      ? 'নির্দিষ্ট সেবনবিধির জন্য চিকিৎসকের পরামর্শ নিন অথবা রেজিস্টার্ড চিকিৎসকের প্রেসক্রিপশন অনুসরণ করুন।'
      : 'Consult a registered physician or follow the doctor prescription for dosage instructions.';
  String get defaultSideEffectsAdvice => isBangla
      ? 'সাধারণত নিরাপদ এবং পার্শ্বপ্রতিক্রিয়া মৃদু। কোনো অস্বাভাবিক লক্ষণ দেখা দিলে অবিলম্বে ডাক্তারের সাথে যোগাযোগ করুন।'
      : 'Generally safe and mild. If any unusual symptoms occur, contact a doctor immediately.';
  String get medicalWarning => isBangla
      ? 'সতর্কতা: যেকোনো ওষুধ গ্রহণের আগে সর্বদা রেজিস্টার্ড চিকিৎসকের পরামর্শ নিন। নিজ থেকে কোনো ওষুধের মাত্রা পরিবর্তন করবেন না।'
      : 'Warning: Always consult a registered physician before taking medication. Never alter drug doses on your own.';

  // Database Initialization View
  String get dbInitTitle => isBangla ? 'ডাটাবেস তৈরি করা হচ্ছে...' : 'Setting up offline database...';
  String get dbInitDefaultStatus => isBangla
      ? 'ওষুধের তালিকা ও সেবনবিধি অফলাইনে সংরক্ষণ করা হচ্ছে।'
      : 'Saving medicines list and dosage guidelines offline.';
  String percentCompleted(int percent) => isBangla
      ? '${LanguageController.instance.formatNumber(percent)}% সম্পন্ন'
      : '$percent% completed';
  String get dbInitNote => isBangla
      ? 'এটি শুধুমাত্র একবার সম্পন্ন করতে হবে। এরপর কোনো ইন্টারনেট সংযোগ ছাড়াই সব ওষুধ খুঁজতে পারবেন।'
      : 'This setup is only needed once. Afterwards, you can search all medicines completely offline.';

  // Prescription Scanner Strings
  String get scanPrescriptionButton => isBangla ? 'প্রেসক্রিপশন স্ক্যান' : 'Scan Prescription';
  String get prescriptionScannerTitle => isBangla ? 'প্রেসক্রিপশন রিডার' : 'Prescription Reader';
  String get scanFromCamera => isBangla ? 'ক্যামেরা দিয়ে তুলুন' : 'Take with Camera';
  String get scanFromGallery => isBangla ? 'গ্যালারি থেকে নিন' : 'Choose from Gallery';
  String get scanningInProgress => isBangla ? 'প্রেসক্রিপশন পড়া হচ্ছে...' : 'Reading prescription...';
  String get scanningSubtitle => isBangla
      ? 'ওষুধের নাম, খাওয়ার নিয়ম ও রোগের বিবরণ মেলানো হচ্ছে'
      : 'Matching medicines, dosage rules, and indications';
  String detectedMedicinesCount(int count) => isBangla
      ? 'শনাক্তকৃত ওষুধ (${LanguageController.instance.formatNumber(count)} টি)'
      : 'Detected Medicines ($count)';
  String get scheduleLabel => isBangla ? 'সেবনবিধি / কতবার খাবেন:' : 'Dosage Frequency:';
  String get mealTimingLabel => isBangla ? 'খাওয়ার নিয়ম:' : 'Meal Instruction:';
  String get durationLabel => isBangla ? 'কতদিন চলবে:' : 'Duration:';
  String get indicationLabel => isBangla ? 'যে রোগের জন্য ওষুধ:' : 'Used For / Condition:';
  String get originalLineLabel => isBangla ? 'প্রেসক্রিপশনের লাইন:' : 'Prescription line:';
  String get viewFullDetailsBtn => isBangla ? 'সম্পূর্ণ বিস্তারিত দেখুন' : 'View Full Details';
  String get noPrescriptionDetected => isBangla ? 'কোনো ওষুধ শনাক্ত করা যায়নি' : 'No medicines detected';
  String get noPrescriptionHint => isBangla
      ? 'প্রেসক্রিপশনের ছবিটি পর্যাপ্ত আলোতে সোজাভাবে তুলে আবার চেষ্টা করুন।'
      : 'Please take a clearer, well-lit photo of the prescription and try again.';
  String get scannerInstructionTitle => isBangla
      ? 'ডাক্তারের প্রেসক্রিপশন আপলোড করুন'
      : 'Upload Doctor Prescription';
  String get scannerInstructionBody => isBangla
      ? 'ছবি তুললে আমাদের সিস্টেম প্রেসক্রিপশনের লেখা পড়ে কোন ওষুধ কোন রোগের জন্য এবং দিনে কতবার খেতে হবে তা বের করে দিবে।'
      : 'Upload a prescription photo to automatically identify medicine names, intake frequencies, meal timings, and indications.';
}
