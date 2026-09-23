import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller for managing the active language (Bangla vs English)
/// and persisting preferences across app sessions.
class LanguageController extends ChangeNotifier {
  static final LanguageController instance = LanguageController._internal();
  LanguageController._internal();

  static const String _prefKey = 'selected_language';
  bool _isBangla = true; // Default Bangla as requested

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

  /// Formats date into DD/MM/YYYY with Bengali digits when in Bangla mode
  String formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final formatted = '$d/$m/$y';
    if (!_isBangla) return formatted;
    const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final sb = StringBuffer();
    for (var i = 0; i < formatted.length; i++) {
      final charCode = formatted.codeUnitAt(i);
      if (charCode >= 48 && charCode <= 57) {
        sb.write(bnDigits[charCode - 48]);
      } else {
        sb.writeCharCode(charCode);
      }
    }
    return sb.toString();
  }
}

/// Compact, reusable AppBar language toggle widget
class LanguageToggleButton extends StatelessWidget {
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;

  const LanguageToggleButton({
    super.key,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageController.instance,
      builder: (context, _) {
        final isBangla = LanguageController.instance.isBangla;
        final strings = AppStrings(isBangla);

        return Tooltip(
          message: strings.languageSwitchTooltip,
          child: InkWell(
            onTap: () => LanguageController.instance.toggleLanguage(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderColor ?? Colors.white.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.translate_rounded,
                    color: textColor ?? Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isBangla ? 'EN' : 'বাং',
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Centralized localization dictionary for the entire Rimrid Sasthoseba application.
class AppStrings {
  final bool isBangla;
  const AppStrings(this.isBangla);

  // Helper delegates
  String formatNumber(int number) => LanguageController.instance.formatNumber(number);
  String formatDate(DateTime dt) => LanguageController.instance.formatDate(dt);

  // =========================================================================
  // 1. App Title, Navigation & Dashboard
  // =========================================================================
  String get appTitle => isBangla ? 'রিমরিদ স্বাস্থ্যসেবা' : 'Rimrid Healthcare';
  String get appSubtitle => isBangla ? 'সম্পূর্ণ অফলাইন ওষুধের তথ্যভাণ্ডার' : 'Complete Offline Medicine Database';
  String get offlineBadge => isBangla ? '১০০% অফলাইন' : '100% Offline';

  // Bottom Navigation Bar
  String get navMedicines => isBangla ? 'ওষুধ' : 'Medicines';
  String get navInteractions => isBangla ? 'বিক্রিয়া' : 'Interactions';
  String get navLabTests => isBangla ? 'ল্যাব টেস্ট' : 'Lab Tests';
  String get navFirstAid => isBangla ? 'ফার্স্ট এইড' : 'First Aid';
  String get navEmergency => isBangla ? 'জরুরি সেবা' : 'Emergency';

  // Common UI Actions
  String get ok => isBangla ? 'ঠিক আছে' : 'OK';
  String get cancel => isBangla ? 'বাতিল' : 'Cancel';
  String get save => isBangla ? 'সংরক্ষণ' : 'Save';
  String get saveAction => isBangla ? 'সংরক্ষণ করুন' : 'Save';
  String get edit => isBangla ? 'সম্পাদনা' : 'Edit';
  String get delete => isBangla ? 'মুছুন' : 'Delete';
  String get close => isBangla ? 'বন্ধ করুন' : 'Close';
  String get add => isBangla ? 'যোগ' : 'Add';
  String get addAction => isBangla ? 'যোগ করুন' : 'Add';
  String get call => isBangla ? 'কল' : 'Call';
  String get search => isBangla ? 'অনুসন্ধান' : 'Search';
  String get all => isBangla ? 'সকল' : 'All';
  String get reset => isBangla ? 'রিসেট' : 'Reset';
  String get help => isBangla ? 'সহায়িকা' : 'Help';
  String get copy => isBangla ? 'কপি' : 'Copy';
  String get enter => isBangla ? 'প্রবেশ করুন' : 'Open';
  String get openGuide => isBangla ? 'নির্দেশিকা দেখুন' : 'View Guide';
  String get clearAll => isBangla ? 'সব মুছুন' : 'Clear all';
  String get notAvailable => isBangla ? 'তথ্য নেই' : 'Not available';

  // Language Switch
  String get languageSwitchLabel => isBangla ? 'EN' : 'বাং';
  String get languageSwitchTooltip => isBangla ? 'Switch to English' : 'বাংলায় পরিবর্তন করুন';

  // =========================================================================
  // 2. Home Screen & Medicine Search
  // =========================================================================
  String get searchHint => isBangla
      ? 'ওষুধের নাম বা জেনেরিক লিখুন (যেমন: Napa, Seclo)...'
      : 'Search by brand or generic (e.g. Napa, Seclo)...';
  String get popularLabel => isBangla ? 'সাধারণ ওষুধ:' : 'Popular:';
  String searchResultsCount(int count) => isBangla
      ? 'খোঁজার ফলাফল (${formatNumber(count)} টি)'
      : 'Search Results ($count items)';
  String get recentPopularTitle => isBangla ? 'সর্বশেষ / জনপ্রিয় ওষুধসমূহ' : 'Recent & Popular Medicines';
  String totalMedicines(int count) => isBangla
      ? 'মোট ওষুধ: ${formatNumber(count)} টি'
      : 'Total: $count medicines';

  String get notFoundTitle => isBangla ? 'কোনো ওষুধ খুঁজে পাওয়া যায়নি' : 'No Medicines Found';
  String get notFoundSubtitle => isBangla
      ? 'বানান সঠিক আছে কিনা যাচাই করুন অথবা জেনেরিক নাম লিখে চেষ্টা করুন।'
      : 'Please check the spelling or try searching with the generic name.';

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

  String get largeFont => isBangla ? 'বড় হরফ' : 'Large Font';
  String get normalFont => isBangla ? 'স্বাভাবিক' : 'Normal Font';
  String get copyTooltip => isBangla ? 'কপি করুন' : 'Copy';
  String copiedMessage(String item) => isBangla ? '$item কপি করা হয়েছে' : '$item copied to clipboard';

  String get defaultDosageAdvice => isBangla
      ? 'নির্দিষ্ট সেবনবিধির জন্য চিকিৎসকের পরামর্শ নিন অথবা রেজিস্টার্ড চিকিৎসকের প্রেসক্রিপশন অনুসরণ করুন।'
      : 'Consult a registered physician or follow the doctor prescription for dosage instructions.';
  String get defaultSideEffectsAdvice => isBangla
      ? 'সাধারণত নিরাপদ এবং পার্শ্বপ্রতিক্রিয়া মৃদু। কোনো অস্বাভাবিক লক্ষণ দেখা দিলে অবিলম্বে ডাক্তারের সাথে যোগাযোগ করুন।'
      : 'Generally safe and mild. If any unusual symptoms occur, contact a doctor immediately.';
  String get medicalWarning => isBangla
      ? 'সতর্কতা: যেকোনো ওষুধ গ্রহণের আগে সর্বদা রেজিস্টার্ড চিকিৎসকের পরামর্শ নিন। নিজ থেকে কোনো ওষুধের মাত্রা পরিবর্তন করবেন না।'
      : 'Warning: Always consult a registered physician before taking medication. Never alter drug doses on your own.';

  String get dbInitTitle => isBangla ? 'ডাটাবেস তৈরি করা হচ্ছে...' : 'Setting up offline database...';
  String get dbInitDefaultStatus => isBangla
      ? 'ওষুধের তালিকা ও সেবনবিধি অফলাইনে সংরক্ষণ করা হচ্ছে।'
      : 'Saving medicines list and dosage guidelines offline.';
  String percentCompleted(int percent) => isBangla
      ? '${formatNumber(percent)}% সম্পন্ন'
      : '$percent% completed';
  String get dbInitNote => isBangla
      ? 'এটি শুধুমাত্র একবার সম্পন্ন করতে হবে। এরপর কোনো ইন্টারনেট সংযোগ ছাড়াই সব ওষুধ খুঁজতে পারবেন।'
      : 'This setup is only needed once. Afterwards, you can search all medicines completely offline.';

  String get scanPrescriptionButton => isBangla ? 'প্রেসক্রিপশন স্ক্যান' : 'Scan Prescription';
  String get medicineReminderTooltip => isBangla ? 'ওষুধের রিমাইন্ডার' : 'Medicine Reminders';

  // =========================================================================
  // 3. Drug Interaction Checker
  // =========================================================================
  String get interactionTitle => isBangla ? 'ড্রাগ ইন্টারঅ্যাকশন চেকার' : 'Drug Interaction Checker';
  String get interactionSearchHeader => isBangla
      ? 'একসাথে খাওয়ার ওষুধগুলো সার্চ করে যোগ করুন:'
      : 'Search and add medicines you take together:';
  String get interactionSearchHint => isBangla
      ? 'ওষুধের নাম লিখুন (যেমন: Napa, Seclo, Histacin)...'
      : 'Type medicine name (e.g. Napa, Seclo)...';
  String get interactionQuickAdd => isBangla ? 'দ্রুত যোগ করুন: ' : 'Quick add: ';
  String interactionMatchesFound(int count) => isBangla
      ? '${formatNumber(count)}টি ওষুধ পাওয়া গেছে'
      : '$count medicines found';
  String get interactionAddAll => isBangla ? 'সবগুলো যোগ করুন' : 'Add All';
  String interactionNotFound(String query) => isBangla
      ? '"$query" পাওয়া যায়নি। বানান সঠিক আছে কিনা দেখুন (যেমন: saclo এর বদলে seclo লিখুন) অথবা কমা ছাড়া একটি একটি করে লিখুন।'
      : 'No medicines matched "$query". Please verify the spelling.';
  String interactionSelectedCount(int count) => isBangla
      ? 'নির্বাচিত ওষুধ (${formatNumber(count)} টি):'
      : 'Selected Medicines ($count):';
  String get interactionEmptyTitle => isBangla ? 'ড্রাগ ইন্টারঅ্যাকশন পরীক্ষা করুন' : 'Check Drug Interactions';
  String get interactionEmptyBody => isBangla
      ? 'আপনি যে ওষুধগুলো একসাথে খান, সেগুলো উপরের সার্চবারে একটি একটি করে অথবা কমা (,) দিয়ে লিখে যোগ করুন। কোনো ক্ষতিকর বিক্রিয়া আছে কিনা তা আমরা পরীক্ষা করে দেব।'
      : 'Add two or more medicines you take together to verify whether they can be safely combined or have harmful drug conflicts.';
  String get interactionAddAnotherTitle => isBangla ? 'আরও অন্তত ১টি ওষুধ যোগ করুন' : 'Add at least one more medicine';
  String get interactionAddAnotherBody => isBangla
      ? 'ইন্টারঅ্যাকশন বা বিক্রিয়া পরীক্ষা করতে কমপক্ষে ২টি ওষুধের প্রয়োজন হয়।'
      : 'At least 2 medications are required to analyze mutual drug interactions.';
  String get interactionSafeTitle => isBangla ? 'কোনো পরিচিত মারাত্মক সংঘাত পাওয়া যায়নি' : 'No Known Severe Conflicts Detected';
  String interactionSafeBody(int count) => isBangla
      ? 'আমাদের ডাটাবেজের ২২+ টি প্রধান ক্লিনিক্যাল ক্লাস ও জেনেরিকের মেডিকেল নিয়মের ভিত্তিতে আপনার নির্বাচিত ${formatNumber(count)}টি ওষুধের মধ্যে কোনো পরিচিত মারাত্মক বিক্রিয়া বা দ্বন্দ্ব নেই।'
      : 'Based on 22+ primary clinical classes and drug interaction rules, no known critical conflicts were found among your selected $count medicines.';
  String get interactionMedicalNoteTitle => isBangla ? 'মেডিকেল সতর্কতা ও পরামর্শ' : 'Medical Safety Note';
  String get interactionMedicalNoteBody => isBangla
      ? 'এই অ্যাপটি একটি বৈজ্ঞানিক সহায়ক নির্দেশিকা এবং কখনোই ডাক্তারের সরাসরি পরামর্শের বিকল্প নয়। প্রতিটি মানুষের বয়স, কিডনি বা লিভারের অবস্থা অনুযায়ী ওষুধের প্রভাব ভিন্ন হতে পারে। নতুন কোনো ওষুধ শুরু করার আগে সর্বদা চিকিৎসকের প্রেসক্রিপশন মেনে চলুন।'
      : 'This tool is a clinical guide and does not substitute a licensed physician. Individual tolerance varies based on age, renal, and liver conditions. Always follow your doctor\'s prescription.';

  // =========================================================================
  // 4. Lab Report Analyzer & Test Directory
  // =========================================================================
  String get labReportTitle => isBangla ? 'ল্যাব টেস্ট ও রিপোর্ট অ্যানালাইজার' : 'Lab Test & Report Analyzer';
  String get labScanTab => isBangla ? 'কাগজের রিপোর্ট স্ক্যান' : 'Scan Lab Report';
  String get labDirectoryTab => isBangla ? 'টেস্ট ডিরেক্টরি (২০+)' : 'Test Directory (20+)';
  String get labBannerTitle => isBangla ? 'ল্যাব রিপোর্টের ছবি স্ক্যান করুন' : 'Scan Paper Lab Report';
  String get labBannerSubtitle => isBangla
      ? 'পপুলার, ইবনে সিনা বা যেকোনো ডায়াগনস্টিক সেন্টারের রিপোর্ট সহজে বুঝুন'
      : 'Instantly decode reports from Popular, Ibn Sina, or any diagnostic center';
  String get labSampleButton => isBangla ? 'নমুনা রিপোর্ট দিয়ে ট্রাই করুন' : 'Try with Sample Report';
  String get labCameraBtn => isBangla ? 'ক্যামেরা দিয়ে তুলুন' : 'Take with Camera';
  String get labGalleryBtn => isBangla ? 'গ্যালারি থেকে নিন' : 'Choose from Gallery';
  String get labScanningProgress => isBangla ? 'রিপোর্ট বিশ্লেষণ করা হচ্ছে...' : 'Analyzing lab report...';
  String get labScanningSubtitle => isBangla
      ? 'ওষুধ, ল্যাব টেস্ট প্যারামিটার ও রেফারেন্স ভ্যালু মেলানো হচ্ছে'
      : 'Matching lab parameters, test results, and reference ranges';
  String labScanError(String error) => isBangla
      ? 'রিপোর্ট স্ক্যানে সমস্যা হয়েছে: $error'
      : 'Error scanning report: $error';
  String get labOcrPreviewTitle => isBangla ? 'OCR টেক্সট প্রিভিউ' : 'OCR Text Preview';
  String get labNoOcrText => isBangla ? 'কোনো টেক্সট পাওয়া যায়নি' : 'No readable text detected';
  String get labSaveAndReevaluate => isBangla ? 'সংরক্ষণ ও পুনঃবিশ্লেষণ' : 'Save & Re-evaluate';
  String get labEditValue => isBangla ? 'মান পরিবর্তন' : 'Edit Value';
  String get labTestSearchHint => isBangla ? 'ল্যাব টেস্ট খুঁজুন (যেমন: Platelet, Creatinine, Hb)...' : 'Search test (e.g. Platelet, Creatinine, Hb)...';
  String get labValueCalculator => isBangla ? 'ল্যাব ভ্যালু ক্যালকুলেটর ও বিশ্লেষণ:' : 'Lab Value Calculator & Clinical Analysis:';
  String get labEnterValuePrompt => isBangla ? 'রিপোর্টের টেস্ট রেজাল্ট লিখুন:' : 'Enter test result value:';
  String get labEvaluateButton => isBangla ? 'ফলাফল বিশ্লেষণ করুন' : 'Analyze Result';
  String get labCategoryAll => isBangla ? 'সব' : 'All';

  // =========================================================================
  // 5. Emergency Hub & SOS 999
  // =========================================================================
  String get emergencyHubTitle => isBangla ? 'জরুরি সেবা ও রক্ত সন্ধান' : 'Emergency & Blood Hub';
  String get emergencySosCardTitle => isBangla ? '🚨 জরুরি এসওএস ও হটলাইন (৯৯৯ / ১৬২৬৩)' : 'Emergency SOS & 999 Hotline';
  String get emergencySosCardSubtitle => isBangla
      ? 'অ্যাম্বুলেন্স, পুলিশ, সরকারি ফ্রি ডাক্তার ও পরিবারের জরুরি নম্বরে ১-ট্যাপে সরাসরি কল করুন।'
      : 'Instant emergency call to 999, doctor helpline 16263, and family emergency contacts.';
  String get emergencyBloodCardTitle => isBangla ? '🩸 জরুরি রক্তের সন্ধান ও ব্লাড ব্যাংক' : 'Emergency Blood Bank Directory';
  String get emergencyBloodCardSubtitle => isBangla
      ? 'রক্তের গ্রুপ ও বিভাগ অনুযায়ী রেড ক্রিসেন্ট, কোয়ান্টাম, সন্ধানী ও বাঁধনের সরাসরি নম্বর।'
      : 'Find blood banks and donor organizations across all 8 divisions with 1-tap dial.';
  String get emergencyExpiryCardTitle => isBangla ? '📦 ঘরের ওষুধের মেয়াদোত্তীর্ণ ট্র্যাকার' : 'Home Medicine Expiry Cabinet';
  String get emergencyExpiryCardSubtitle => isBangla
      ? 'বাসার ড্রয়ারে থাকা ওষুধের মেয়াদ শেষ হওয়ার আগে নোটিফিকেশন ও নষ্ট ওষুধ অপসারণের ট্র্যাকার।'
      : 'Track expiration dates of household medicines to prevent taking expired drugs.';

  String get sosScreenTitle => isBangla ? 'জরুরি এসওএস ও হেল্পলাইন' : 'Emergency SOS & Hotlines';
  String get sosBigButtonTapPrompt => isBangla ? 'জরুরি প্রয়োজনে এক ট্যাপে ৯৯৯ ডায়াল করুন' : 'Tap for instant 999 National Emergency';
  String get sosBigButtonServicesText => isBangla
      ? 'অ্যাম্বুলেন্স, পুলিশ বা ফায়ার সার্ভিস দ্রুত পৌঁছাবে'
      : 'Connects to ambulance, fire service, and police';
  String get sosFamilyContactTitle => isBangla ? 'পরিবারের জরুরি নম্বর' : 'Emergency Family Contact';
  String get sosNoNumberSaved => isBangla ? 'কোনো নম্বর সেট করা নেই' : 'No number saved';
  String get sosHotlinesListTitle => isBangla ? 'জরুরি সরকারি স্বাস্থ্য হটলাইনসমূহ:' : 'National Emergency Hotlines:';
  String get sosGuardianDialogTitle => isBangla ? 'জরুরি পরিচিতজনের নম্বর' : 'Emergency Contact Number';
  String get sosGuardianPhoneHint => isBangla ? 'মোবাইল নম্বর লিখুন (যেমন: 017XXXXXXXX)' : 'Enter phone number (e.g. 017XXXXXXXX)';
  String get sosGuardianSavedMessage => isBangla ? 'জরুরি অভিভাবকের নম্বর সংরক্ষণ করা হয়েছে' : 'Emergency contact number saved successfully';
  String sosCallFailedMessage(String phone) => isBangla ? 'কল করা যায়নি: $phone' : 'Unable to place call: $phone';

  // =========================================================================
  // 6. Blood Directory Screen
  // =========================================================================
  String get bloodFinderTitle => isBangla ? 'জরুরি রক্তের সন্ধান ও ব্লাড ব্যাংক' : 'Emergency Blood Finder';
  String get bloodSelectGroup => isBangla ? 'রক্তের গ্রুপ নির্বাচন করুন:' : 'Select Blood Group:';
  String get bloodSelectDivision => isBangla ? 'বিভাগ: ' : 'Division: ';
  String bloodCentersFound(int count) => isBangla
      ? 'ব্লাড ব্যাংক ও ডোনার সেন্টার (${formatNumber(count)} টি)'
      : 'Blood Centers Found ($count)';
  String get bloodNoCentersInRegion => isBangla
      ? 'এই বিভাগে কোনো তথ্য পাওয়া যায়নি'
      : 'No blood centers found in this region';
  String bloodCallDirect(String phone) => isBangla
      ? 'সরাসরি কল করুন ($phone)'
      : 'Call Now ($phone)';

  // Divisions mapping
  String get divisionAll => isBangla ? 'সকল' : 'All';
  String get divisionDhaka => isBangla ? 'ঢাকা' : 'Dhaka';
  String get divisionChittagong => isBangla ? 'চট্টগ্রাম' : 'Chattogram';
  String get divisionRajshahi => isBangla ? 'রাজশাহী' : 'Rajshahi';
  String get divisionKhulna => isBangla ? 'খুলনা' : 'Khulna';
  String get divisionBarishal => isBangla ? 'বরিশাল' : 'Barishal';
  String get divisionSylhet => isBangla ? 'সিলেট' : 'Sylhet';
  String get divisionRangpur => isBangla ? 'রংপুর' : 'Rangpur';
  String get divisionMymensingh => isBangla ? 'ময়মনসিংহ' : 'Mymensingh';

  // =========================================================================
  // 7. First Aid & Child Health Hub
  // =========================================================================
  String get firstAidHubTitle => isBangla ? 'প্রাথমিক চিকিৎসা ও শিশু স্বাস্থ্য' : 'First Aid & Child Health';
  String get firstAidGuideCardTitle => isBangla ? 'জরুরি প্রাথমিক চিকিৎসা (ফার্স্ট এইড)' : 'Emergency First Aid Guide';
  String get firstAidGuideCardSubtitle => isBangla
      ? 'আগুনে পোড়া, সাপে কাটা, গলায় কিছু আটকে যাওয়া ও স্ট্রোকের লক্ষণ চেনার ১০০% অফলাইন নির্দেশিকা।'
      : '100% offline lifesaver guidelines for burns, snake bite, choking, and stroke.';
  String get childVaccineCardTitle => isBangla ? 'শিশুর টিকাদান সূচি (EPI Tracker)' : 'Child EPI Vaccination Tracker';
  String get childVaccineCardSubtitle => isBangla
      ? 'জন্মের সময় থেকে ১৫ মাস পর্যন্ত সরকারি নিয়মে সব টিকার তারিখ গণনা ও সম্পূর্ণ করার ট্র্যাকার।'
      : 'Track mandatory child vaccination dates from birth up to 15 months.';
  String get firstAidScreenTitle => isBangla ? 'জরুরি প্রাথমিক চিকিৎসা (ফার্স্ট এইড)' : 'First Aid Lifesaver Guide';
  String get whatToDo => isBangla ? 'কী করবেন (করণীয়):' : 'What to DO:';
  String get whatNotToDo => isBangla ? 'যা ভুলেও করবেন না (বর্জনীয়):' : 'What NOT to do:';
  String get emergencyTip => isBangla ? 'জরুরি লাইফসেভার টিপ:' : 'Emergency Lifesaver Tip:';

  // =========================================================================
  // 8. Vaccination Tracker Screen
  // =========================================================================
  String get vaccineTrackerTitle => isBangla ? 'শিশুর টিকাদান সূচি (EPI Tracker)' : 'Child EPI Vaccination Tracker';
  String get childBirthDateLabel => isBangla ? 'শিশুর জন্মতারিখ:' : 'Child Date of Birth:';
  String get changeDateBtn => isBangla ? 'তারিখ পরিবর্তন' : 'Change Date';
  String get dueDateLabel => isBangla ? 'নির্ধারিত তারিখ:' : 'Due Date:';
  String get overdueTag => isBangla ? 'বাকি আছে' : 'Overdue';

  // =========================================================================
  // 9. Medicine Expiry Cabinet Screen
  // =========================================================================
  String get expiryTrackerTitle => isBangla ? 'ঘরের ওষুধের মেয়াদোত্তীর্ণ ট্র্যাকার' : 'Medicine Expiry Tracker';
  String get addMedicineFab => isBangla ? 'নতুন ওষুধ যোগ' : 'Add Medicine';
  String get emptyCabinetTitle => isBangla ? 'আপনার ঘরের বক্স খালি' : 'Your cabinet is empty';
  String get emptyCabinetSubtitle => isBangla
      ? 'বাসার ড্রয়ার বা বক্সে রাখা ওষুধের নাম ও এক্সপায়ারি ডেট যোগ করুন। মেয়াদ শেষ হওয়ার আগে অ্যাপ সতর্ক করবে।'
      : 'Add medicines stored at home with their expiry dates to track safety.';
  String get addCabinetDialogTitle => isBangla ? 'গৃহস্থালী ওষুধ যোগ করুন' : 'Add Medicine to Cabinet';
  String get medNameLabel => isBangla ? 'ওষুধের নাম (যেমন: Napa 500mg)' : 'Medicine Name';
  String get expiryLabel => isBangla ? 'মেয়াদ শেষ:' : 'Expiry:';
  String get setDateBtn => isBangla ? 'তারিখ দিন' : 'Set Date';
  String get statusGood => isBangla ? 'মেয়াদ ঠিক আছে' : 'Good';
  String get statusExpired => isBangla ? 'মেয়াদোত্তীর্ণ (ফেলে দিন)' : 'Expired! Discard';
  String statusExpiringSoon(int days) => isBangla
      ? 'শীঘ্রই শেষ হবে (${formatNumber(days)} দিন)'
      : 'Expiring ($days days)';

  // =========================================================================
  // 10. Medicine Reminder & Routine Screen
  // =========================================================================
  String get reminderTitle => isBangla ? 'ওষুধের রিমাইন্ডার ও রুটিন' : 'Medicine Reminders & Routine';
  String get testNotificationTooltip => isBangla ? 'টেস্ট নোটিফিকেশন' : 'Test notification';
  String get addReminderFab => isBangla ? 'নতুন রিমাইন্ডার' : 'Add Reminder';
  String get todayMedProgress => isBangla ? 'আজকের ওষুধ খাওয়ার অগ্রগতি' : 'Today\'s Medication Progress';
  String progressStatus(int taken, int total) => isBangla
      ? '${formatNumber(taken)} / ${formatNumber(total)} সম্পন্ন'
      : '$taken / $total Taken';
  String get reminderBannerHelp => isBangla
      ? 'সময়মতো ওষুধ খেলে অ্যালার্ম বাজবে। খাওয়ার পর "খেয়েছি" চাপুন।'
      : 'Reminders notify on schedule. Tap "Mark Taken" when ingested.';
  String get testNotificationBannerPrompt => isBangla
      ? 'নোটিফিকেশন ও অ্যালার্ম চেক করতে চান?'
      : 'Want to verify notification sound & popup?';
  String get testNowBtn => isBangla ? 'এখনই টেস্ট' : 'Test Now';
  String get testNotificationSentMsg => isBangla
      ? 'টেস্ট নোটিফিকেশন পাঠানো হয়েছে! ফোনের নোটিফিকেশন বার চেক করুন।'
      : 'Test notification sent! Check your notification tray.';
  String get noActiveRemindersTitle => isBangla ? 'কোনো সক্রিয় রিমাইন্ডার নেই' : 'No Active Reminders';
  String get noActiveRemindersSubtitle => isBangla
      ? 'নিচের "নতুন রিমাইন্ডার" বোতামে চাপ দিয়ে প্রতিদিনের ওষুধ খাওয়ার সময় সেট করুন।'
      : 'Tap "Add Reminder" button below to schedule daily medicine alarms.';
  String get takenTodayTag => isBangla ? 'আজকে খাওয়া হয়েছে' : 'Taken Today';
  String get markTakenAction => isBangla ? 'খেয়েছি (Mark Taken)' : 'Mark as Taken';

  // Reminder Modals & Actions
  String get resetStatusDialogTitle => isBangla ? 'স্ট্যাটাস রিসেট করবেন?' : 'Reset Taken Status?';
  String get resetStatusDialogBody => isBangla
      ? 'ভুলবশত কি "খেয়েছি" চাপ লেগেছিল? আপনি চাইলে এটিকে পুনরায় না-খাওয়া অবস্থায় ফিরিয়ে নিতে পারেন।'
      : 'Did you mark this by mistake? You can reset it back to pending.';
  String get yesResetBtn => isBangla ? 'হ্যাঁ, রিসেট করুন' : 'Reset';
  String reminderTakenSuccess(String name) => isBangla
      ? '✅ $name ওষুধটি খাওয়া সম্পন্ন হয়েছে'
      : '✅ $name marked as taken';
  String reminderDeletedSuccess(String name) => isBangla
      ? '$name রিমাইন্ডার মুছে ফেলা হয়েছে'
      : '$name reminder has been deleted';

  String get addReminderSheetTitle => isBangla ? '🔔 নতুন ওষুধের রিমাইন্ডার' : '🔔 Add Medicine Reminder';
  String get medNameFieldLabel => isBangla ? 'ওষুধের নাম:' : 'Medicine Name:';
  String get medNameFieldHint => isBangla ? 'যেমন: Napa 500mg, Seclo 20mg...' : 'e.g. Napa 500mg, Seclo 20mg...';
  String get dosageFieldLabel => isBangla ? 'পরিমাণ বা মাত্রা (Dosage):' : 'Dosage / Quantity:';
  String get dosageFieldHint => isBangla ? 'যেমন: ১টি ট্যাবলেট, ২ চামচ...' : 'e.g. 1 Tablet, 2 Spoonfuls...';
  String get mealTimingFieldLabel => isBangla ? 'খাওয়ার নিয়ম:' : 'Meal Instruction:';
  String get mealBefore => isBangla ? 'খাবারের আগে' : 'Before meal';
  String get mealAfter => isBangla ? 'খাবারের পরে' : 'After meal';
  String get mealWith => isBangla ? 'খাবারের সাথে' : 'With meal';
  String get setTimeFieldLabel => isBangla ? 'সময় নির্ধারণ করুন:' : 'Set Reminder Time:';
  String get slotMorning => isBangla ? 'সকাল' : 'Morning';
  String get slotNoon => isBangla ? 'দুপুর' : 'Noon';
  String get slotNight => isBangla ? 'রাত' : 'Night';
  String get customTimeChoice => isBangla ? 'পছন্দমতো সময়' : 'Custom Time';
  String get saveReminderBtn => isBangla ? 'রিমাইন্ডার সেভ করুন' : 'Save Reminder';
  String get reminderSaveError => isBangla
      ? 'অনুগ্রহ করে ওষুধের নাম ও অন্তত একটি সময় নির্বাচন করুন'
      : 'Please enter medicine name and select a reminder time';
  String get reminderSaveSuccess => isBangla
      ? 'নতুন রিমাইন্ডার সফলভাবে সেট করা হয়েছে'
      : 'New reminder scheduled successfully';

  // =========================================================================
  // 11. Prescription Scanner & Details
  // =========================================================================
  String get prescriptionScannerTitle => isBangla ? 'প্রেসক্রিপশন রিডার' : 'Prescription Reader';
  String get scanFromCamera => isBangla ? 'ক্যামেরা দিয়ে তুলুন' : 'Take with Camera';
  String get scanFromGallery => isBangla ? 'গ্যালারি থেকে নিন' : 'Choose from Gallery';
  String get scanningInProgress => isBangla ? 'প্রেসক্রিপশন পড়া হচ্ছে...' : 'Reading prescription...';
  String get scanningSubtitle => isBangla
      ? 'ওষুধের নাম, খাওয়ার নিয়ম ও রোগের বিবরণ মেলানো হচ্ছে'
      : 'Matching medicines, dosage rules, and indications';
  String detectedMedicinesCount(int count) => isBangla
      ? 'শনাক্তকৃত ওষুধ (${formatNumber(count)} টি)'
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
  String get prescriptionHelpTitle => isBangla ? 'প্রেসক্রিপশন স্ক্যান সহায়িকা' : 'Prescription Scanner Guide';
  String get prescriptionHelpBody => isBangla
      ? '১. ভালো আলোতে প্রেসক্রিপশনের স্পষ্ট ছবি তুলুন।\n'
        '২. প্রিন্ট করা প্রেসক্রিপশন শতভাগ নির্ভুলভাবে পড়া যায়।\n'
        '৩. শনাক্ত হওয়া যেকোনো ওষুধের উপর ট্যাপ করে তার সম্পূর্ণ খাওয়ার নিয়ম, জেনেরিক এবং পার্শ্বপ্রতিক্রিয়া দেখতে পারবেন।\n'
        '৪. এটি সম্পূর্ণ অফলাইনে কাজ করে।'
      : '1. Take a well-lit and clear photo of the prescription.\n'
        '2. Printed prescriptions achieve near-perfect OCR accuracy.\n'
        '3. Tap any detected medicine to inspect generic details and full indications.\n'
        '4. Works 100% offline without internet.';
  String get ocrTextPreviewTitle => isBangla ? 'OCR টেক্সট প্রিভিউ' : 'OCR Text Preview';
  String get setReminderForMed => isBangla ? '🔔 এই ওষুধের রিমাইন্ডার সেট করুন' : '🔔 Set Reminder for this Medicine';
}
