enum LabStatus { normal, borderline, critical }

class LabTestResult {
  final LabStatus status;
  final String statusTitleBangla;
  final String statusTitleEnglish;
  final String messageBangla;
  final String messageEnglish;
  final String adviceBangla;
  final String adviceEnglish;

  const LabTestResult({
    required this.status,
    required this.statusTitleBangla,
    required this.statusTitleEnglish,
    required this.messageBangla,
    required this.messageEnglish,
    required this.adviceBangla,
    required this.adviceEnglish,
  });
}

class LabTestDefinition {
  final String id;
  final String nameBangla;
  final String nameEnglish;
  final String unit;
  final String categoryBangla;
  final String descriptionBangla;
  final double minNormal;
  final double maxNormal;
  final double defaultInputValue;
  final List<String> ocrAliases;
  final LabTestResult Function(double value) evaluate;

  const LabTestDefinition({
    required this.id,
    required this.nameBangla,
    required this.nameEnglish,
    required this.unit,
    required this.categoryBangla,
    required this.descriptionBangla,
    required this.minNormal,
    required this.maxNormal,
    required this.defaultInputValue,
    required this.ocrAliases,
    required this.evaluate,
  });
}

class LabTestsData {
  static final List<LabTestDefinition> tests = [
    // ================= 1. CBC (রক্ত ও সংক্রমণ প্যানেল) =================
    // 1. Platelet Count
    LabTestDefinition(
      id: 'platelet',
      nameBangla: 'প্লাটিলেট কাউন্ট (Platelet - ডেঙ্গু)',
      nameEnglish: 'Platelet Count (CBC)',
      unit: '/µL',
      categoryBangla: 'রক্ত পরীক্ষা (CBC)',
      descriptionBangla: 'ডেঙ্গু জ্বর ও রক্তক্ষরণ প্রতিরোধে রক্ত জমাট বাঁধার প্রধান উপাদান।',
      minNormal: 150000,
      maxNormal: 450000,
      defaultInputValue: 180000,
      ocrAliases: ['platelet', 'plt', 'platelets', 'thrombocyte'],
      evaluate: (val) {
        if (val < 50000) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'বিপদসীমা (Critical Low)',
            statusTitleEnglish: 'Critical Low',
            messageBangla: 'প্লাটিলেট মারাত্মকভাবে কমে গেছে (৫০,০০০ এর নিচে)। স্বতঃস্ফূর্ত অভ্যন্তরীণ রক্তক্ষরণের ঝুঁকি রয়েছে।',
            messageEnglish: 'Platelet count is critically low below 50,000. Severe spontaneous bleeding risk.',
            adviceBangla: 'অবিলম্বে হাসপাতালে ভর্তি হোন এবং ডেঙ্গু বিশেষজ্ঞ চিকিৎসকের নিবিড় পর্যবেক্ষণে থাকুন।',
            adviceEnglish: 'Admit to a hospital immediately under dengue specialist care.',
          );
        } else if (val < 150000) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'কম (Low)',
            statusTitleEnglish: 'Below Normal Range',
            messageBangla: 'প্লাটিলেট স্বাভাবিকের চেয়ে কম। ডেঙ্গু বা ভাইরাল জ্বরের সংক্রমণ হতে পারে।',
            messageEnglish: 'Platelets are lower than normal. Potential viral or dengue infection.',
            adviceBangla: 'পর্যাপ্ত তরল খাবার, ওরস্যালাইন ও ডাবের পানি পান করুন এবং চিকিৎসকের পরামর্শে প্রতিদিন প্লাটিলেট ফলোআপ করুন।',
            adviceEnglish: 'Drink plenty of fluids, oral saline, and follow up platelet counts daily.',
          );
        } else if (val > 450000) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'উচ্চ (High)',
            statusTitleEnglish: 'High Platelets',
            messageBangla: 'প্লাটিলেট স্বাভাবিকের চেয়ে কিছুটা বেশি (Thrombocytosis)। প্রদাহ বা সংক্রমণ হতে পারে।',
            messageEnglish: 'Platelet count is higher than typical range.',
            adviceBangla: 'কোনো দীর্ঘমেয়াদী প্রদাহ বা ইনফেকশন আছে কিনা ডাক্তারের সাথে পরামর্শ করে নিশ্চিত হন।',
            adviceEnglish: 'Consult a physician to rule out reactive inflammation.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক (Normal)',
          statusTitleEnglish: 'Normal Range',
          messageBangla: 'আপনার প্লাটিলেট কাউন্ট সম্পূর্ণ নিরাপদ ও স্বাভাবিক মাত্রায় রয়েছে।',
          messageEnglish: 'Your platelet count is completely within normal safe limits.',
          adviceBangla: 'সুস্থ থাকতে নিয়মিত পুষ্টিকর খাদ্য গ্রহণ ও পর্যাপ্ত পানি পান করুন।',
          adviceEnglish: 'Maintain a balanced diet and regular hydration.',
        );
      },
    ),

    // 2. Hemoglobin
    LabTestDefinition(
      id: 'hemoglobin',
      nameBangla: 'হিমোগ্লোবিন (Hemoglobin / Hb - রক্তশূন্যতা)',
      nameEnglish: 'Hemoglobin (Hb)',
      unit: 'g/dL',
      categoryBangla: 'রক্ত পরীক্ষা (CBC)',
      descriptionBangla: 'রক্তে অক্সিজেন পরিবহনকারী প্রোটিন। কমে গেলে রক্তশূন্যতা বা অ্যানিমিয়া হয়।',
      minNormal: 12.0,
      maxNormal: 16.5,
      defaultInputValue: 13.5,
      ocrAliases: ['hemoglobin', 'haemoglobin', 'hb', 'hgb'],
      evaluate: (val) {
        if (val < 8.0) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'মারাত্মক রক্তশূন্যতা (Severe Anemia)',
            statusTitleEnglish: 'Severe Anemia',
            messageBangla: 'হিমোগ্লোবিন ৮.০ এর নিচে নেমে গেছে। শরীর চরম দুর্বল ও শ্বাসকষ্ট হতে পারে, রক্ত দেওয়ার প্রয়োজন হতে পারে।',
            messageEnglish: 'Critically low hemoglobin below 8.0 g/dL. Blood transfusion may be required.',
            adviceBangla: 'জরুরিভিত্তিতে হেমাটোলজিস্ট বা বিশেষজ্ঞ চিকিৎসকের শরণাপন্ন হোন।',
            adviceEnglish: 'Seek immediate specialist or hematology evaluation.',
          );
        } else if (val < 12.0) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'স্বাভাবিকের চেয়ে কম (Mild Anemia)',
            statusTitleEnglish: 'Mild Anemia',
            messageBangla: 'হিমোগ্লোবিন স্বাভাবিকের চেয়ে কম। ক্লান্তি, মাথা ঘোরা ও দুর্বলতা দেখা দিতে পারে।',
            messageEnglish: 'Hemoglobin is slightly lower than normal range.',
            adviceBangla: 'আয়রন ও ফলিক অ্যাসিড সমৃদ্ধ খাবার (কচু শাক, ডালিম, কলিজা, ডিম) খান এবং ডাক্তারের পরামর্শে আয়রন টেস্ট করান।',
            adviceEnglish: 'Increase iron-rich foods and consult physician for iron studies.',
          );
        } else if (val > 17.5) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'উচ্চ (Polycythemia)',
            statusTitleEnglish: 'High Hemoglobin',
            messageBangla: 'হিমোগ্লোবিন অতিরিক্ত বেশি। এতে রক্ত ঘন হয়ে রক্তনালীতে জমাট বাঁধার ঝুঁকি বাড়তে পারে।',
            messageEnglish: 'Elevated hemoglobin increases blood viscosity.',
            adviceBangla: 'পর্যাপ্ত পানি পান করুন এবং চিকিৎসকের সাথে রক্ত ঘন হওয়ার কারণ পরীক্ষা করুন।',
            adviceEnglish: 'Stay well hydrated and evaluate with your doctor.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক (Normal)',
          statusTitleEnglish: 'Normal Range',
          messageBangla: 'আপনার হিমোগ্লোবিন সম্পূর্ণ স্বাভাবিক। রক্তে অক্সিজেন সরবরাহ সঠিক রয়েছে।',
          messageEnglish: 'Your hemoglobin level is within normal healthy limits.',
          adviceBangla: 'নিয়মিত সুষম খাদ্য তালিকা বজায় রাখুন।',
          adviceEnglish: 'Continue balanced dietary habits.',
        );
      },
    ),

    // 3. WBC (Total Count)
    LabTestDefinition(
      id: 'wbc',
      nameBangla: 'শ্বেতরক্তকণিকা (WBC / TC - রোগ প্রতিরোধ)',
      nameEnglish: 'Total Leucocyte Count (WBC)',
      unit: '/µL',
      categoryBangla: 'রক্ত পরীক্ষা (CBC)',
      descriptionBangla: 'শরীরের রোগ প্রতিরোধ ও যেকোনো ব্যাকটেরিয়াল বা ভাইরাল সংক্রমণের নির্দেশক।',
      minNormal: 4000,
      maxNormal: 11000,
      defaultInputValue: 7500,
      ocrAliases: ['wbc', 'total count', 'tlc', 'leucocyte count', 'white blood cell'],
      evaluate: (val) {
        if (val > 15000) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'তীব্র ইনফেকশন (Severe Infection / Leukocytosis)',
            statusTitleEnglish: 'High Leukocytosis',
            messageBangla: 'শ্বেতরক্তকণিকা অতিরিক্ত বেশি (১৫,০০০ এর বেশি)। শরীরে কোনো ব্যাকটেরিয়াল ইনফেকশন বা তীব্র প্রদাহ রয়েছে।',
            messageEnglish: 'Significantly elevated WBC indicates acute infection or severe inflammatory response.',
            adviceBangla: 'দ্রুত চিকিৎসকের পরামর্শ নিন এবং যথাযথ অ্যান্টিবায়োটিক বা চিকিৎসা শুরু করুন।',
            adviceEnglish: 'Consult doctor promptly for targeted diagnostic workup and antibiotics.',
          );
        } else if (val > 11000) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'সামান্য বেশি (Mild Infection)',
            statusTitleEnglish: 'Mild Leukocytosis',
            messageBangla: 'শ্বেতরক্তকণিকা স্বাভাবিকের চেয়ে কিছুটা বেশি। শরীরে সাধারণ সংক্রমণ বা ঠাণ্ডা-জ্বর হতে পারে।',
            messageEnglish: 'Slightly high WBC. Mild infection or physical stress.',
            adviceBangla: 'পর্যাপ্ত বিশ্রাম নিন এবং লক্ষণ অব্যাহত থাকলে ডাক্তারের পরামর্শ নিন।',
            adviceEnglish: 'Rest, hydrate, and monitor symptoms with your doctor.',
          );
        } else if (val < 4000) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'কম (Leukopenia)',
            statusTitleEnglish: 'Low WBC',
            messageBangla: 'শ্বেতরক্তকণিকা স্বাভাবিকের চেয়ে কম। ভাইরাল সংক্রমণ বা রোগ প্রতিরোধ ক্ষমতা সাময়িক দুর্বল হতে পারে।',
            messageEnglish: 'Low WBC indicates bone marrow suppression or acute viral syndrome.',
            adviceBangla: 'ভিড় এড়িয়ে চলুন এবং বিশেষজ্ঞ চিকিৎসকের পরামর্শ নিন।',
            adviceEnglish: 'Avoid exposure to infections and consult a physician.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক (Normal)',
          statusTitleEnglish: 'Normal Range',
          messageBangla: 'আপনার শ্বেতরক্তকণিকা সম্পূর্ণ স্বাভাবিক সীমার মধ্যে রয়েছে।',
          messageEnglish: 'WBC count is within optimal normal range.',
          adviceBangla: 'রোগ প্রতিরোধ ক্ষমতা বজায় রাখতে পুষ্টিকর খাবার গ্রহণ করুন।',
          adviceEnglish: 'Maintain a healthy immune-boosting lifestyle.',
        );
      },
    ),

    // 4. ESR (Erythrocyte Sedimentation Rate)
    LabTestDefinition(
      id: 'esr',
      nameBangla: 'ইএসআর (ESR - শরীরে প্রদাহের মাত্রা)',
      nameEnglish: 'ESR (Westergren)',
      unit: 'mm/1st hr',
      categoryBangla: 'রক্ত পরীক্ষা (CBC)',
      descriptionBangla: 'শরীরে কোনো দীর্ঘমেয়াদী প্রদাহ, বাত ব্যথা বা যক্ষ্মা/ইনফেকশন আছে কিনা তা নির্দেশ করে।',
      minNormal: 0,
      maxNormal: 20,
      defaultInputValue: 12,
      ocrAliases: ['esr', 'erythrocyte sedimentation rate', 'westergren'],
      evaluate: (val) {
        if (val > 50) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'উচ্চ প্রদাহ (High Inflammation)',
            statusTitleEnglish: 'High ESR',
            messageBangla: 'ESR ৫০ এর বেশি। শরীরে তীব্র বাতজ্বর, অটোইমিউন রোগ বা দীর্ঘমেয়াদী ইনফেকশন থাকতে পারে।',
            messageEnglish: 'Markedly elevated ESR suggesting significant systemic inflammation or autoimmune disease.',
            adviceBangla: 'মেডিসিন বা বাত রোগ বিশেষজ্ঞ চিকিৎসকের শরণাপন্ন হয়ে বিস্তারিত পরীক্ষা করান।',
            adviceEnglish: 'Consult a physician or rheumatologist to evaluate root etiology.',
          );
        } else if (val > 20) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'সামান্য বৃদ্ধি (Mild Elevation)',
            statusTitleEnglish: 'Mildly Elevated',
            messageBangla: 'ESR স্বাভাবিকের চেয়ে কিছুটা বেশি। শরীরে মৃদু প্রদাহ বা রক্তশূন্যতার কারণেও হতে পারে।',
            messageEnglish: 'Slightly high ESR due to mild infection or anemia.',
            adviceBangla: 'ডাক্তারের পরামর্শ অনুযায়ী ফলোআপ করুন।',
            adviceEnglish: 'Monitor with your healthcare provider.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক (Normal)',
          statusTitleEnglish: 'Normal Range',
          messageBangla: 'ESR স্বাভাবিক। শরীরে কোনো সক্রিয় প্রদাহের লক্ষণ নেই।',
          messageEnglish: 'ESR is normal. No active severe inflammation detected.',
          adviceBangla: 'স্বাস্থ্যকর জীবনযাপন বজায় রাখুন।',
          adviceEnglish: 'Maintain overall health.',
        );
      },
    ),

    // ================= 2. KIDNEY / KFT (কিডনি ফাংশন প্যানেল) =================
    // 5. Serum Creatinine
    LabTestDefinition(
      id: 'creatinine',
      nameBangla: 'সিরাম ক্রিয়েটিনিন (Serum Creatinine - কিডনি)',
      nameEnglish: 'Serum Creatinine (KFT)',
      unit: 'mg/dL',
      categoryBangla: 'কিডনি পরীক্ষা (KFT)',
      descriptionBangla: 'কিডনির ফিল্টারিং কার্যক্ষমতা যাচাইয়ের সবচেয়ে নির্ভরযোগ্য সূচক।',
      minNormal: 0.6,
      maxNormal: 1.2,
      defaultInputValue: 0.9,
      ocrAliases: ['creatinine', 's.creatinine', 'serum creatinine', 'creat'],
      evaluate: (val) {
        if (val > 2.0) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'বিপদসীমা (Critical Kidney Risk)',
            statusTitleEnglish: 'Critical Kidney Risk',
            messageBangla: 'ক্রিয়েটিনিন ২.০ এর বেশি। কিডনি মারাত্মকভাবে ক্ষতিগ্রস্ত বা কার্যক্ষমতা আশঙ্কাজনকভাবে কমে গেছে।',
            messageEnglish: 'Serum creatinine above 2.0 mg/dL indicates acute or chronic renal failure.',
            adviceBangla: 'অবিলম্বে নেফ্রোলজিস্ট (কিডনি বিশেষজ্ঞ) চিকিৎসকের শরণাপন্ন হোন। ব্যথানাশক ওষুধ সম্পূর্ণ এড়িয়ে চলুন।',
            adviceEnglish: 'Urgent nephrology consultation required. Strictly avoid NSAID painkillers.',
          );
        } else if (val > 1.2) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'স্বাভাবিকের চেয়ে বেশি (Mild Kidney Impairment)',
            statusTitleEnglish: 'Borderline High',
            messageBangla: 'ক্রিয়েটিনিন সামান্য বেশি। উচ্চ রক্তচাপ, ডায়াবেটিস বা পানিশূন্যতার কারণে হতে পারে।',
            messageEnglish: 'Creatinine is elevated above normal. Early kidney strain.',
            adviceBangla: 'পর্যাপ্ত পানি পান করুন, প্রেশার ও ডায়াবেটিস নিয়ন্ত্রণে রাখুন এবং ডাক্তারের পরামর্শ নিন।',
            adviceEnglish: 'Ensure proper hydration, control BP and diabetes, and consult physician.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক (Normal)',
          statusTitleEnglish: 'Normal Range',
          messageBangla: 'আপনার কিডনির ফিল্টারিং ক্ষমতা সম্পূর্ণ সুস্থ ও স্বাভাবিক রয়েছে।',
          messageEnglish: 'Your kidney function is completely within healthy normal limits.',
          adviceBangla: 'প্রতিদিন পরিমিত পানি পান করুন এবং চিকিৎসকের পরামর্শ ছাড়া ব্যথার ওষুধ সেবন করবেন না।',
          adviceEnglish: 'Drink adequate water and avoid unprescribed painkiller overuse.',
        );
      },
    ),

    // 6. Blood Urea / BUN
    LabTestDefinition(
      id: 'urea',
      nameBangla: 'ব্লাড ইউরিয়া (Blood Urea / BUN - কিডনি)',
      nameEnglish: 'Blood Urea Nitrogen (BUN)',
      unit: 'mg/dL',
      categoryBangla: 'কিডনি পরীক্ষা (KFT)',
      descriptionBangla: 'প্রোটিন বিপাকের বর্জ্য যা কিডনির মাধ্যমে শরীর থেকে বের হয়ে যায়।',
      minNormal: 15,
      maxNormal: 45,
      defaultInputValue: 25,
      ocrAliases: ['blood urea', 'urea', 'bun', 'blood urea nitrogen'],
      evaluate: (val) {
        if (val > 60) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'উচ্চ ইউরিয়া (Uremia Risk)',
            statusTitleEnglish: 'Elevated Urea',
            messageBangla: 'রক্তে ইউরিয়া ৬০ এর বেশি। কিডনির বর্জ্য পরিষ্কার করার ক্ষমতা ব্যাহত হচ্ছে।',
            messageEnglish: 'Significantly high urea indicates impaired renal clearance or dehydration.',
            adviceBangla: 'কিডনি বিশেষজ্ঞ চিকিৎসকের তত্ত্বাবধানে থাকুন এবং প্রোটিন সমৃদ্ধ খাবার নিয়ন্ত্রিত রাখুন।',
            adviceEnglish: 'Consult nephrologist; manage dietary protein intake as advised.',
          );
        } else if (val > 45) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'সামান্য বেশি (Borderline)',
            statusTitleEnglish: 'Mild Elevation',
            messageBangla: 'ইউরিয়া স্বাভাবিকের চেয়ে কিছুটা বেশি। ডিহাইড্রেশন বা উচ্চ প্রোটিন ডায়েটের কারণে হতে পারে।',
            messageEnglish: 'Mildly elevated urea. Often related to dehydration.',
            adviceBangla: 'পর্যাপ্ত পানি পান করুন এবং ক্রিয়েটিনিন টেস্টের সাথে মিলিয়ে দেখুন।',
            adviceEnglish: 'Increase fluid intake and correlate with serum creatinine.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক (Normal)',
          statusTitleEnglish: 'Normal Range',
          messageBangla: 'ব্লাড ইউরিয়া স্বাভাবিক মাত্রায় রয়েছে।',
          messageEnglish: 'Blood urea is within healthy normal limits.',
          adviceBangla: 'পর্যাপ্ত তরল গ্রহণ বজায় রাখুন।',
          adviceEnglish: 'Maintain good hydration.',
        );
      },
    ),

    // 7. Serum Uric Acid
    LabTestDefinition(
      id: 'uric_acid',
      nameBangla: 'ইউরিক অ্যাসিড (Serum Uric Acid - বাত ব্যথা)',
      nameEnglish: 'Serum Uric Acid',
      unit: 'mg/dL',
      categoryBangla: 'কিডনি পরীক্ষা (KFT)',
      descriptionBangla: 'রক্তে মাত্রাতিরিক্ত বেড়ে গেলে হাত-পায়ের জয়েন্টে তীব্র বাত ব্যথা (Gout) ও কিডনিতে পাথর হতে পারে।',
      minNormal: 3.5,
      maxNormal: 7.0,
      defaultInputValue: 5.5,
      ocrAliases: ['uric acid', 'serum uric acid', 's.uric acid'],
      evaluate: (val) {
        if (val > 8.5) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'তীব্র বাত ব্যথা ও কিডনি পাথরের ঝুঁকি (Gout Risk)',
            statusTitleEnglish: 'Hyperuricemia',
            messageBangla: 'ইউরিক অ্যাসিড ৮.৫ এর বেশি। পায়ের বুড়ো আঙুল ও জয়েন্টে তীব্র প্রদাহ এবং কিডনিতে পাথর হতে পারে।',
            messageEnglish: 'Severely elevated uric acid (>8.5 mg/dL). High risk of gout flare and nephrolithiasis.',
            adviceBangla: 'চিকিৎসকের পরামর্শে ইউরিক অ্যাসিড কমানোর ওষুধ সেবন করুন। লাল মাংস, কলিজা, পুঁইশাক ও ডাল সাময়িক এড়িয়ে চলুন।',
            adviceEnglish: 'Consult doctor for urate-lowering therapy. Limit red meat, organ meats, and spinach.',
          );
        } else if (val > 7.0) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'স্বাভাবিকের চেয়ে বেশি (Mild Gout Risk)',
            statusTitleEnglish: 'Borderline High',
            messageBangla: 'ইউরিক অ্যাসিড কিছুটা বেশি। খাদ্যাভ্যাস নিয়ন্ত্রণ না করলে বাতের ব্যথা শুরু হতে পারে।',
            messageEnglish: 'Uric acid is above normal limit.',
            adviceBangla: 'প্রতিদিন অন্তত ৩ লিটার পানি পান করুন এবং চর্বিযুক্ত মাংস ও সামুদ্রিক মাছ পরিহার করুন।',
            adviceEnglish: 'Drink at least 3 liters of water daily and limit purine-rich foods.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক (Normal)',
          statusTitleEnglish: 'Normal Range',
          messageBangla: 'আপনার ইউরিক অ্যাসিডের মাত্রা সম্পূর্ণ স্বাভাবিক ও নিরাপদ।',
          messageEnglish: 'Your uric acid level is normal and safe.',
          adviceBangla: 'স্বাস্থ্যকর ও পরিমিত সুষম খাদ্য বজায় রাখুন।',
          adviceEnglish: 'Maintain a balanced nutritious diet.',
        );
      },
    ),

    // ================= 3. LIVER / LFT (লিভার ফাংশন প্যানেল) =================
    // 8. SGPT / ALT
    LabTestDefinition(
      id: 'sgpt',
      nameBangla: 'এসজিপিটি (SGPT / ALT - লিভারের প্রদাহ)',
      nameEnglish: 'SGPT / ALT (Liver Function)',
      unit: 'U/L',
      categoryBangla: 'লিভার পরীক্ষা (LFT)',
      descriptionBangla: 'লিভারের কোষের ক্ষতির প্রধান সূচক। ফ্যাটি লিভার, জন্ডিস বা ওষুধের পার্শ্বপ্রতিক্রিয়ায় বেড়ে যায়।',
      minNormal: 5,
      maxNormal: 45,
      defaultInputValue: 28,
      ocrAliases: ['sgpt', 'alt', 'alanine aminotransferase', 's.g.p.t'],
      evaluate: (val) {
        if (val > 120) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'তীব্র লিভারের ক্ষতি (Acute Liver Injury)',
            statusTitleEnglish: 'High ALT / SGPT',
            messageBangla: 'SGPT আশঙ্কাজনকভাবে বেড়ে গেছে (১২০ এর বেশি)। হেপাটাইটিস, ফ্যাটি লিভার বা ওষুধের বিষক্রিয়া হতে পারে।',
            messageEnglish: 'Significantly elevated ALT indicating active liver inflammation or acute injury.',
            adviceBangla: 'অবিলম্বে গ্যাস্ট্রোএন্টারোলজিস্ট বা হেপাটোলজিস্ট চিকিৎসকের শরণাপন্ন হোন।',
            adviceEnglish: 'Consult a hepatologist or gastroenterologist promptly for liver ultrasound and viral markers.',
          );
        } else if (val > 45) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'সামান্য বেশি (Mild Liver Inflammation)',
            statusTitleEnglish: 'Mildly Elevated',
            messageBangla: 'SGPT স্বাভাবিকের চেয়ে বেশি। ফ্যাটি লিভার, অতিরিক্ত তেলযুক্ত খাবার বা ব্যথানাশক ওষুধের কারণে হতে পারে।',
            messageEnglish: 'Mildly elevated ALT commonly due to fatty liver or medication effects.',
            adviceBangla: 'তৈলাক্ত ও ভাজাপোড়া খাবার পরিহার করুন, ওজন নিয়ন্ত্রণে রাখুন এবং চিকিৎসকের পরামর্শ নিন।',
            adviceEnglish: 'Avoid fatty/fried foods, exercise regularly, and discuss with your doctor.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক (Normal)',
          statusTitleEnglish: 'Normal Range',
          messageBangla: 'আপনার লিভারের কার্যক্ষমতা ও SGPT সম্পূর্ণ স্বাভাবিক ও সুস্থ।',
          messageEnglish: 'Your ALT / SGPT level is healthy and normal.',
          adviceBangla: 'নিয়মিত পুষ্টিকর খাদ্য গ্রহণ ও শরীরচর্চা বজায় রাখুন।',
          adviceEnglish: 'Keep up a healthy lifestyle and balanced diet.',
        );
      },
    ),

    // 9. SGOT / AST
    LabTestDefinition(
      id: 'sgot',
      nameBangla: 'এসজিওটি (SGOT / AST - লিভার ও হার্ট)',
      nameEnglish: 'SGOT / AST (Liver & Heart)',
      unit: 'U/L',
      categoryBangla: 'লিভার পরীক্ষা (LFT)',
      descriptionBangla: 'লিভার ও হৃদযন্ত্রের পেশির আঘাত বা প্রদাহ যাচাই করার এনজাইম।',
      minNormal: 5,
      maxNormal: 40,
      defaultInputValue: 24,
      ocrAliases: ['sgot', 'ast', 'aspartate aminotransferase', 's.g.o.t'],
      evaluate: (val) {
        if (val > 100) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'উচ্চ এনজাইম (Marked Elevation)',
            statusTitleEnglish: 'High AST',
            messageBangla: 'SGOT অনেক বেশি। লিভার বা মাংসপেশির তীব্র ক্ষতির লক্ষণ হতে পারে।',
            messageEnglish: 'Marked AST elevation reflects liver, heart, or muscle injury.',
            adviceBangla: 'চিকিৎসকের সাথে পরামর্শ করে SGPT ও অন্যান্য লিভার টেস্ট মিলিয়ে দেখুন।',
            adviceEnglish: 'Correlate with ALT and follow up with a physician.',
          );
        } else if (val > 40) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'সামান্য বেশি (Borderline High)',
            statusTitleEnglish: 'Slightly Elevated',
            messageBangla: 'SGOT স্বাভাবিকের চেয়ে কিছুটা বেশি।',
            messageEnglish: 'Slightly elevated AST.',
            adviceBangla: 'চিকিৎসকের পরামর্শে লিভারের স্বাস্থ্য নিয়মিত পর্যবেক্ষণ করুন।',
            adviceEnglish: 'Monitor with your physician.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক (Normal)',
          statusTitleEnglish: 'Normal Range',
          messageBangla: 'SGOT স্বাভাবিক মাত্রায় রয়েছে।',
          messageEnglish: 'AST level is normal.',
          adviceBangla: 'স্বাস্থ্যকর রুটিন অব্যাহত রাখুন।',
          adviceEnglish: 'Maintain healthy routines.',
        );
      },
    ),

    // 10. Serum Bilirubin (Jaundice)
    LabTestDefinition(
      id: 'bilirubin',
      nameBangla: 'সিরাম বিলিরুবিন (Serum Bilirubin - জন্ডিস)',
      nameEnglish: 'Serum Total Bilirubin',
      unit: 'mg/dL',
      categoryBangla: 'লিভার পরীক্ষা (LFT)',
      descriptionBangla: 'রক্তে হলুদ রঞ্জক পদার্থ। স্বাভাবিকের চেয়ে বেড়ে গেলে চোখ ও প্রস্রাব হলুদ হয়ে জন্ডিস দেখা দেয়।',
      minNormal: 0.2,
      maxNormal: 1.2,
      defaultInputValue: 0.7,
      ocrAliases: ['bilirubin', 'total bilirubin', 's.bilirubin', 't.bilirubin'],
      evaluate: (val) {
        if (val > 3.0) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'তীব্র জন্ডিস (Severe Jaundice)',
            statusTitleEnglish: 'Severe Jaundice',
            messageBangla: 'বিলিরুবিন ৩.০ এর বেশি। চোখ ও শরীর গভীর হলুদ হয়ে তীব্র জন্ডিস এবং লিভারের জটিলতা হতে পারে।',
            messageEnglish: 'Total bilirubin > 3.0 mg/dL confirms clinical jaundice requiring urgent diagnosis.',
            adviceBangla: 'অবিলম্বে চিকিৎসকের কাছে যান। কবিরাজি বা অপচিকিৎসা সম্পূর্ণ পরিহার করুন। পূর্ণ বিশ্রামে থাকুন।',
            adviceEnglish: 'Seek prompt medical attention. Avoid folk remedies and rest completely.',
          );
        } else if (val > 1.2) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'প্রাথমিক জন্ডিস (Mild Hyperbilirubinemia)',
            statusTitleEnglish: 'Mild Jaundice',
            messageBangla: 'বিলিরুবিন স্বাভাবিকের চেয়ে বেশি। প্রাথমিক জন্ডিসের লক্ষণ।',
            messageEnglish: 'Elevated bilirubin indicating early jaundice.',
            adviceBangla: 'পর্যাপ্ত বিশ্রাম নিন, বিশুদ্ধ পানি পান করুন এবং চিকিৎসকের পরামর্শে হেপাটাইটিস স্ক্রিনিং করুন।',
            adviceEnglish: 'Rest, drink clean boiled water, and get viral hepatitis tests done.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক (Normal)',
          statusTitleEnglish: 'Normal Range',
          messageBangla: 'বিলিরুবিন স্বাভাবিক। আপনার শরীরে কোনো জন্ডিসের লক্ষণ নেই।',
          messageEnglish: 'Bilirubin is within healthy limits. No jaundice detected.',
          adviceBangla: 'বিশুদ্ধ ফুটানো পানি ও পরিচ্ছন্ন খাবার গ্রহণ করুন।',
          adviceEnglish: 'Drink clean safe water and eat hygienic food.',
        );
      },
    ),

    // ================= 4. DIABETES (ডায়াবেটিস প্যানেল) =================
    // 11. Fasting Blood Sugar (FBS)
    LabTestDefinition(
      id: 'fbs',
      nameBangla: 'ফাস্টিং ব্লাড সুগার (FBS - খালি পেটে গ্লুকোজ)',
      nameEnglish: 'Fasting Blood Sugar (FBS)',
      unit: 'mmol/L',
      categoryBangla: 'ডায়াবেটিস পরীক্ষা',
      descriptionBangla: 'সকালে ৮-১০ ঘণ্টা অভুক্ত থাকার পর রক্তের গ্লুকোজ পরিমাপ।',
      minNormal: 3.9,
      maxNormal: 6.0,
      defaultInputValue: 5.2,
      ocrAliases: ['fbs', 'fasting blood sugar', 'fasting glucose', 'fbg', 'glucose fasting'],
      evaluate: (val) {
        if (val >= 7.0) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'ডায়াবেটিস নিশ্চিত (Diabetes Range)',
            statusTitleEnglish: 'Diabetes Diagnostic Range',
            messageBangla: 'খালি পেটে সুগার ৭.০ বা তার বেশি হলে তা আন্তর্জাতিক মানদণ্ডে ডায়াবেটিসের নির্দেশক।',
            messageEnglish: 'Fasting glucose >= 7.0 mmol/L is diagnostic of Diabetes Mellitus.',
            adviceBangla: 'ডায়াবেটিস বিশেষজ্ঞের শরণাপন্ন হয়ে ওষুধ বা খাদ্যাভ্যাস শুরু করুন। মিষ্টি খাবার পরিহার করুন।',
            adviceEnglish: 'Consult an endocrinologist for treatment plan and lifestyle modifications.',
          );
        } else if (val > 6.0) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'প্রি-ডায়াবেটিস (Pre-diabetes / IFG)',
            statusTitleEnglish: 'Pre-diabetes Range',
            messageBangla: 'সুগার ৬.১ থেকে ৬.৯ এর মধ্যে থাকা প্রি-ডায়াবেটিসের লক্ষণ। সতর্ক না হলে দ্রুত ডায়াবেটিসে রূপ নিতে পারে।',
            messageEnglish: 'Impaired fasting glucose indicates high risk of progression to diabetes.',
            adviceBangla: 'প্রতিদিন অন্তত ৩০ মিনিট দ্রুত হাঁটুন, ওজন কমান এবং মিষ্টি ও অতিরিক্ত ভাত খাওয়া নিয়ন্ত্রণ করুন।',
            adviceEnglish: 'Exercise 30 mins daily, control body weight, and reduce refined carbohydrates.',
          );
        } else if (val < 3.5) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'হাইপোগ্লাইসেমিয়া (Hypoglycemia / লো সুগার)',
            statusTitleEnglish: 'Low Blood Sugar',
            messageBangla: 'রক্তে সুগার মারাত্মক কমে গেছে। মাথা ঘোরা, কাঁপুনি ও সংজ্ঞাহীন হওয়ার আশঙ্কা রয়েছে।',
            messageEnglish: 'Critically low glucose. Risk of dizziness, tremors, and syncope.',
            adviceBangla: 'তাৎক্ষণিকভাবে ১ গ্লাস চিনির শরবত বা মিষ্টি খাবার গ্রহণ করুন।',
            adviceEnglish: 'Immediately consume fast-acting sugars (juice, glucose tablet) and consult doctor.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক (Normal)',
          statusTitleEnglish: 'Normal Range',
          messageBangla: 'আপনার খালি পেটের সুগার সম্পূর্ণ সুস্থ ও স্বাভাবিক।',
          messageEnglish: 'Your fasting blood glucose is in the optimal healthy range.',
          adviceBangla: 'স্বাস্থ্যকর খাদ্য ও নিয়মিত ব্যায়াম অব্যাহত রাখুন।',
          adviceEnglish: 'Continue balanced nutrition and active lifestyle.',
        );
      },
    ),

    // 12. Random Blood Sugar (RBS)
    LabTestDefinition(
      id: 'rbs',
      nameBangla: 'র্যান্ডম ব্লাড সুগার (RBS - যেকোনো সময়ের গ্লুকোজ)',
      nameEnglish: 'Random Blood Sugar (RBS)',
      unit: 'mmol/L',
      categoryBangla: 'ডায়াবেটিস পরীক্ষা',
      descriptionBangla: 'দিনের যেকোনো সময়ে খাবার খাওয়ার সাথে সম্পর্কিত না রেখে রক্তের গ্লুকোজ।',
      minNormal: 4.0,
      maxNormal: 7.8,
      defaultInputValue: 6.5,
      ocrAliases: ['rbs', 'random blood sugar', 'random glucose', 'glucose random'],
      evaluate: (val) {
        if (val >= 11.1) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'উচ্চ ডায়াবেটিস (Diabetes Confirmed)',
            statusTitleEnglish: 'High Blood Sugar',
            messageBangla: 'র্যান্ডম সুগার ১১.১ এর বেশি। ডায়াবেটিসের স্পষ্ট লক্ষণ।',
            messageEnglish: 'Random glucose >= 11.1 mmol/L indicates manifest diabetes.',
            adviceBangla: 'অবিলম্বে চিকিৎসকের কাছে যান এবং সুগার নিয়ন্ত্রণের ওষুধ শুরু করুন।',
            adviceEnglish: 'Consult a physician promptly for diabetes management.',
          );
        } else if (val > 7.8) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'সীমার চেয়ে বেশি (Borderline High)',
            statusTitleEnglish: 'Borderline',
            messageBangla: 'সুগার স্বাভাবিকের চেয়ে কিছুটা বেশি রয়েছে।',
            messageEnglish: 'Glucose is higher than standard normal limits.',
            adviceBangla: 'খালি পেটে FBS ও ৩ মাসের গড় HbA1c পরীক্ষা করে নিশ্চিত হন।',
            adviceEnglish: 'Confirm status with fasting blood glucose and HbA1c test.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক (Normal)',
          statusTitleEnglish: 'Normal Range',
          messageBangla: 'র্যান্ডম সুগার সম্পূর্ণ স্বাভাবিক রয়েছে।',
          messageEnglish: 'Random glucose is completely normal.',
          adviceBangla: 'মিষ্টি পরিমিত খান ও শরীর সচল রাখুন।',
          adviceEnglish: 'Maintain healthy habits.',
        );
      },
    ),

    // 13. HbA1c (৩ মাসের গড় সুগার)
    LabTestDefinition(
      id: 'hba1c',
      nameBangla: 'এইচবিএওয়ানসি (HbA1c - ৩ মাসের গড় সুগার)',
      nameEnglish: 'Glycated Hemoglobin (HbA1c)',
      unit: '%',
      categoryBangla: 'ডায়াবেটিস পরীক্ষা',
      descriptionBangla: 'বিগত ৩ মাসের সামগ্রিক রক্তে শর্করার গড় মাত্রা। ডায়াবেটিস নিয়ন্ত্রণের গোল্ড স্ট্যান্ডার্ড।',
      minNormal: 4.0,
      maxNormal: 5.6,
      defaultInputValue: 5.4,
      ocrAliases: ['hba1c', 'a1c', 'glycated hemoglobin', 'glycosylated hemoglobin'],
      evaluate: (val) {
        if (val >= 8.0) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'অনিয়ন্ত্রিত ডায়াবেটিস (Poorly Controlled Diabetes)',
            statusTitleEnglish: 'Uncontrolled Diabetes',
            messageBangla: 'HbA1c ৮.০% বা তার বেশি। বিগত ৩ মাসে সুগার বিপজ্জনকভাবে অনিয়ন্ত্রিত ছিল। চোখ, কিডনি ও হার্টের ক্ষতির ঝুঁকি বাড়ছে।',
            messageEnglish: 'HbA1c >= 8.0% signifies chronically poor glycemic control and elevated micro/macrovascular risks.',
            adviceBangla: 'চিকিৎসকের সাথে পরামর্শ করে ওষুধের ডোজ বা ইনসুলিন সমন্বয় করুন।',
            adviceEnglish: 'Consult doctor urgently to adjust medication, diet, or insulin therapy.',
          );
        } else if (val >= 6.5) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'ডায়াবেটিস সীমার মধ্যে (Diabetes / Moderate Control)',
            statusTitleEnglish: 'Diabetic Range',
            messageBangla: 'HbA1c ৬.৫% থেকে ৭.৯%। ডায়াবেটিসের উপস্থিতি নির্দেশ করে। সুগার আরও নিয়ন্ত্রণে রাখা প্রয়োজন।',
            messageEnglish: 'Diabetic range with moderate control.',
            adviceBangla: 'লক্ষ্যমাত্রা ৭% এর নিচে রাখার চেষ্টা করুন। হাঁটাহাঁটি ও মিষ্টি নিয়ন্ত্রণ বজায় রাখুন।',
            adviceEnglish: 'Target HbA1c < 7.0% through disciplined lifestyle and physician guidance.',
          );
        } else if (val >= 5.7) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'প্রি-ডায়াবেটিস (Pre-diabetes)',
            statusTitleEnglish: 'Pre-diabetic',
            messageBangla: '৫.৭% থেকে ৬.৪% প্রি-ডায়াবেটিস নির্দেশক। দ্রুত লাইফস্টাইল পরিবর্তন না করলে স্থায়ী ডায়াবেটিস হতে পারে।',
            messageEnglish: 'Pre-diabetes stage. High risk of converting to full diabetes.',
            adviceBangla: 'ওজন কমান ও প্রতিদিন ৩০ মিনিট শরীরচর্চা করুন। চিনিযুক্ত পানীয় সম্পূর্ণ বর্জন করুন।',
            adviceEnglish: 'Reduce body weight, exercise 30 minutes daily, eliminate sugary drinks.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক ও নিরাপদ (Normal / Non-diabetic)',
          statusTitleEnglish: 'Excellent Normal',
          messageBangla: 'আপনার HbA1c ৫.৭% এর নিচে। ডায়াবেটিসের কোনো লক্ষণ নেই।',
          messageEnglish: 'HbA1c is in the non-diabetic healthy range.',
          adviceBangla: 'স্বাস্থ্যকর অভ্যাস বজায় রাখুন।',
          adviceEnglish: 'Maintain current healthy lifestyle.',
        );
      },
    ),

    // ================= 5. LIPID PROFILE (কোলেস্টেরল ও হার্ট) =================
    // 14. Total Cholesterol
    LabTestDefinition(
      id: 'cholesterol',
      nameBangla: 'টোটাল কোলেস্টেরল (Total Cholesterol - রক্তে চর্বি)',
      nameEnglish: 'Total Cholesterol (Lipid Profile)',
      unit: 'mg/dL',
      categoryBangla: 'কোলেস্টেরল ও হার্ট',
      descriptionBangla: 'রক্তের মোট চর্বির মাত্রা। মাত্রাতিরিক্ত বাড়লে রক্তনালীতে ব্লক তৈরি হয়ে হার্ট অ্যাটাকের ঝুঁকি বাড়ে।',
      minNormal: 125,
      maxNormal: 200,
      defaultInputValue: 175,
      ocrAliases: ['cholesterol', 'total cholesterol', 's.cholesterol'],
      evaluate: (val) {
        if (val >= 240) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'উচ্চ ঝুঁকির কোলেস্টেরল (High Risk / Hyperlipidemia)',
            statusTitleEnglish: 'High Cholesterol',
            messageBangla: 'কোলেস্টেরল ২৪০ এর বেশি। রক্তনালী সরু হয়ে হৃদরোগ ও স্ট্রোকের ঝুঁকি বহুগুণ বাড়িয়ে দেয়।',
            messageEnglish: 'Total cholesterol >= 240 mg/dL carries high cardiovascular and coronary risk.',
            adviceBangla: 'হৃদরোগ বা মেডিসিন বিশেষজ্ঞের পরামর্শে স্ট্যাটিন ওষুধ ও কড়া খাদ্যাভ্যাস শুরু করুন।',
            adviceEnglish: 'Consult doctor for statin therapy and strict low-saturated-fat diet.',
          );
        } else if (val >= 200) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'সীমার চেয়ে বেশি (Borderline High)',
            statusTitleEnglish: 'Borderline High',
            messageBangla: 'কোলেস্টেরল ২০০ থেকে ২৩৯ এর মধ্যে। চর্বির মাত্রা নিয়ন্ত্রণ করা প্রয়োজন।',
            messageEnglish: 'Borderline elevated cholesterol.',
            adviceBangla: 'ঘি, মাখন, লাল মাংস ও তৈলাক্ত খাবার কমান। প্রতিদিন ৩০ মিনিট হাঁটুন।',
            adviceEnglish: 'Cut down on trans fats, butter, and red meat. Walk 30 minutes daily.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক ও নিরাপদ (Desirable / Normal)',
          statusTitleEnglish: 'Desirable Range',
          messageBangla: 'আপনার মোট কোলেস্টেরল নিরাপদ সীমার মধ্যে রয়েছে। হৃদযন্ত্র সুস্থ রাখতে সহায়ক।',
          messageEnglish: 'Total cholesterol is within desirable healthy limits.',
          adviceBangla: 'সুষম খাদ্য তালিকা ও নিয়মিত শরীরচর্চা অব্যাহত রাখুন।',
          adviceEnglish: 'Maintain healthy eating habits and regular exercise.',
        );
      },
    ),

    // 15. Triglycerides (TG)
    LabTestDefinition(
      id: 'triglycerides',
      nameBangla: 'ট্রাইগ্লিসারাইড (Triglycerides / TG - চর্বি)',
      nameEnglish: 'Serum Triglycerides (TG)',
      unit: 'mg/dL',
      categoryBangla: 'কোলেস্টেরল ও হার্ট',
      descriptionBangla: 'রক্তের অতিরিক্ত ক্যালোরি চর্বি হিসেবে জমা হওয়া। ডায়াবেটিস ও অতিরিক্ত শর্করা খেলে বাড়ে।',
      minNormal: 50,
      maxNormal: 150,
      defaultInputValue: 120,
      ocrAliases: ['triglycerides', 'triglyceride', 'tg', 's.triglycerides'],
      evaluate: (val) {
        if (val >= 300) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'মারাত্মক বেশি (Very High TG / Pancreatitis Risk)',
            statusTitleEnglish: 'Very High TG',
            messageBangla: 'ট্রাইগ্লিসারাইড ৩০০ এর বেশি। অগ্ন্যাশয়ে প্রদাহ (Pancreatitis) ও হার্ট অ্যাটাকের ঝুঁকি থাকে।',
            messageEnglish: 'Very high TG elevates risks of acute pancreatitis and cardiovascular events.',
            adviceBangla: 'চিকিৎসকের পরামর্শ অনুযায়ী ওষুধ গ্রহণ করুন। চিনি, মিষ্টি ও মিষ্টি ফল খাওয়া কঠোরভাবে সীমিত করুন।',
            adviceEnglish: 'Consult doctor for lipid-lowering medication; strictly limit sugar and simple carbs.',
          );
        } else if (val >= 150) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'সীমার চেয়ে বেশি (Borderline High)',
            statusTitleEnglish: 'Borderline',
            messageBangla: 'ট্রাইগ্লিসারাইড ১৫০ এর বেশি। অতিরিক্ত মিষ্টি, ভাত বা ফ্যাটি লিভারের কারণে হতে পারে।',
            messageEnglish: 'Elevated triglycerides.',
            adviceBangla: 'মিষ্টি, কোমল পানীয় ও ভাতের পরিমাণ কমান এবং ওজন নিয়ন্ত্রণ করুন।',
            adviceEnglish: 'Reduce refined carbohydrates, sweets, and lose excess body weight.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক (Normal)',
          statusTitleEnglish: 'Normal Range',
          messageBangla: 'ট্রাইগ্লিসারাইড স্বাভাবিক মাত্রায় রয়েছে।',
          messageEnglish: 'Triglycerides are in the normal healthy range.',
          adviceBangla: 'পরিমিত আহার ও শরীরচর্চা বজায় রাখুন।',
          adviceEnglish: 'Continue healthy habits.',
        );
      },
    ),

    // 16. LDL (খারাপ কোলেস্টেরল)
    LabTestDefinition(
      id: 'ldl',
      nameBangla: 'এলডিএল (LDL - ক্ষতিকর কোলেস্টেরল)',
      nameEnglish: 'LDL Cholesterol (Bad)',
      unit: 'mg/dL',
      categoryBangla: 'কোলেস্টেরল ও হার্ট',
      descriptionBangla: 'রক্তনালীর দেয়ালে জমা হয়ে ব্লক তৈরি করা মূল ক্ষতিকর চর্বি।',
      minNormal: 50,
      maxNormal: 100,
      defaultInputValue: 85,
      ocrAliases: ['ldl', 'ldl cholesterol', 'ldl-c'],
      evaluate: (val) {
        if (val >= 160) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'উচ্চ ঝুঁকি (High Cardiovascular Risk)',
            statusTitleEnglish: 'High LDL',
            messageBangla: 'LDL ১৬০ এর বেশি। রক্তনালীতে ব্লক তৈরি হওয়ার সর্বোচ্চ ঝুঁকি রয়েছে।',
            messageEnglish: 'High LDL significantly accelerates arterial plaque buildup.',
            adviceBangla: 'চিকিৎসকের পরামর্শে স্ট্যাটিন ওষুধ ও চর্বিমুক্ত খাদ্য শুরু করুন।',
            adviceEnglish: 'Consult cardiologist/physician for statin therapy and dietary overhaul.',
          );
        } else if (val >= 100) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'সীমার চেয়ে বেশি (Above Optimal)',
            statusTitleEnglish: 'Above Optimal',
            messageBangla: 'LDL ১০০ এর বেশি। হার্টের সুস্থতার জন্য এটি ১০০ এর নিচে রাখা ভালো।',
            messageEnglish: 'Above optimal LDL level.',
            adviceBangla: 'তেল, চর্বি ও প্রক্রিয়াজাত খাবার বর্জন করুন। ওটস ও সবুজ শাকসবজি খান।',
            adviceEnglish: 'Reduce fried foods and consume soluble fiber (oats, vegetables).',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'নিখুঁত ও নিরাপদ (Optimal)',
          statusTitleEnglish: 'Optimal Level',
          messageBangla: 'আপনার ক্ষতিকর LDL কোলেস্টেরল নিরাপদ সীমার নিচে রয়েছে।',
          messageEnglish: 'LDL is in optimal range, protecting vascular health.',
          adviceBangla: 'সুস্থ অভ্যাস অব্যাহত রাখুন।',
          adviceEnglish: 'Keep up heart-healthy living.',
        );
      },
    ),

    // ================= 6. THYROID (থাইরয়েড প্যানেল) =================
    // 17. TSH (Thyroid Stimulating Hormone)
    LabTestDefinition(
      id: 'tsh',
      nameBangla: 'টিএসএইচ (TSH - থাইরয়েড হরমোন)',
      nameEnglish: 'TSH (Thyroid Function)',
      unit: 'µIU/mL',
      categoryBangla: 'থাইরয়েড পরীক্ষা',
      descriptionBangla: 'থাইরয়েড গ্রন্থির কার্যক্ষমতা যাচাইয়ের মূল টেস্ট। হাইপো বা হাইপারথাইরয়েডিজম নির্দেশ করে।',
      minNormal: 0.4,
      maxNormal: 4.5,
      defaultInputValue: 2.1,
      ocrAliases: ['tsh', 'thyroid stimulating hormone', 's.tsh'],
      evaluate: (val) {
        if (val > 10.0) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'হাইপোথাইরয়েডিজম (Overt Hypothyroidism)',
            statusTitleEnglish: 'High TSH',
            messageBangla: 'TSH ১০ এর বেশি। থাইরয়েড গ্রন্থি যথেষ্ট হরমোন তৈরি করছে না। অতিরিক্ত ওজন বৃদ্ধি, ক্লান্তি, চুল পড়া ও বিষণ্ণতা হতে পারে।',
            messageEnglish: 'TSH > 10 confirms primary hypothyroidism requiring levothyroxine supplementation.',
            adviceBangla: 'হরমোন বিশেষজ্ঞের (Endocrinologist) পরামর্শে থাইরক্সিন ওষুধ শুরু করুন।',
            adviceEnglish: 'Consult endocrinologist for thyroid hormone replacement therapy.',
          );
        } else if (val > 4.5) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'সামান্য বৃদ্ধি (Subclinical Hypothyroidism)',
            statusTitleEnglish: 'Borderline High TSH',
            messageBangla: 'TSH স্বাভাবিকের চেয়ে কিছুটা বেশি। অলসতা বা ঠাণ্ডা লাগার অনুভূতি হতে পারে।',
            messageEnglish: 'Mildly elevated TSH indicating subclinical hypothyroidism.',
            adviceBangla: 'ডাক্তারের পরামর্শে Free T4 টেস্ট করান এবং মনিটরিংয়ে থাকুন।',
            adviceEnglish: 'Check Free T4 and evaluate with your doctor.',
          );
        } else if (val < 0.1) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'হাইপারথাইরয়েডিজম (Hyperthyroidism / অতিরিক্ত হরমোন)',
            statusTitleEnglish: 'Suppressed TSH',
            messageBangla: 'TSH অতিরিক্ত কমে গেছে। বুক ধড়ফড়, ওজন হ্রাস ও হাত কাঁপুনি হতে পারে।',
            messageEnglish: 'Suppressed TSH indicating hyperthyroidism / thyrotoxicosis.',
            adviceBangla: 'দ্রুত চিকিৎসকের পরামর্শ নিন।',
            adviceEnglish: 'Consult physician for anti-thyroid evaluation.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক (Normal)',
          statusTitleEnglish: 'Normal Range',
          messageBangla: 'আপনার থাইরয়েড হরমোন সম্পূর্ণ স্বাভাবিক ও সুষম।',
          messageEnglish: 'TSH is in optimal euthyroid range.',
          adviceBangla: 'আয়োডিনযুক্ত লবণ ও স্বাস্থ্যকর খাবার গ্রহণ অব্যাহত রাখুন।',
          adviceEnglish: 'Maintain balanced nutrition.',
        );
      },
    ),

    // ================= 7. ELECTROLYTES & NUTRIENTS (ইলেক্ট্রোলাইট ও পুষ্টি) =================
    // 18. Serum Potassium (K+)
    LabTestDefinition(
      id: 'potassium',
      nameBangla: 'সিরাম পটাশিয়াম (Serum Potassium / K+ - হার্টের ছন্দ)',
      nameEnglish: 'Serum Potassium (K+)',
      unit: 'mmol/L',
      categoryBangla: 'ইলেক্ট্রোলাইট ও খনিজ',
      descriptionBangla: 'হৃদস্পন্দনের স্বাভাবিক ছন্দ এবং পেশির সংকোচনের জন্য অত্যন্ত সংবেদনশীল ইলেক্ট্রোলাইট।',
      minNormal: 3.5,
      maxNormal: 5.1,
      defaultInputValue: 4.2,
      ocrAliases: ['potassium', 'k+', 'serum potassium', 's.potassium'],
      evaluate: (val) {
        if (val > 5.5) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'বিপজ্জনক পটাশিয়াম (Hyperkalemia / হার্ট অ্যাটাকের ঝুঁকি)',
            statusTitleEnglish: 'Dangerous Hyperkalemia',
            messageBangla: 'পটাশিয়াম ৫.৫ এর বেশি। এটি হার্টের ছন্দে মারাত্মক বিশৃঙ্খলা ও হঠাৎ কার্ডিয়াক অ্যারেস্ট ঘটাতে পারে।',
            messageEnglish: 'Potassium > 5.5 mmol/L is life-threatening due to fatal arrhythmia risk.',
            adviceBangla: 'অবিলম্বে জরুরি বিভাগে যান। প্রেশারের ওষুধ ও পটাশিয়াম সমৃদ্ধ ফল সাময়িক বন্ধ রাখুন।',
            adviceEnglish: 'Seek emergency hospital care immediately; hold potassium supplements and ACEi/ARBs.',
          );
        } else if (val < 3.2) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'পটাশিয়ামের মারাত্মক ঘাটতি (Hypokalemia)',
            statusTitleEnglish: 'Hypokalemia',
            messageBangla: 'পটাশিয়াম অনেক কমে গেছে। পেশির দুর্বলতা, প্যারালাইসিস ও বুক ধড়ফড় হতে পারে।',
            messageEnglish: 'Low potassium causing severe muscle weakness and cardiac palpitations.',
            adviceBangla: 'ডাক্তারের পরামর্শে দ্রুত ওরাল বা আইভি পটাশিয়াম গ্রহণ করুন। ডাবের পানি পান করুন।',
            adviceEnglish: 'Drink coconut water and consult doctor for potassium repletion.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক (Normal)',
          statusTitleEnglish: 'Normal Range',
          messageBangla: 'আপনার রক্তে পটাশিয়ামের মাত্রা সম্পূর্ণ নিরাপদ।',
          messageEnglish: 'Serum potassium is within normal safe range.',
          adviceBangla: 'সুষম পানীয় ও ফলমূল গ্রহণ করুন।',
          adviceEnglish: 'Maintain electrolyte balance.',
        );
      },
    ),

    // 19. Vitamin D
    LabTestDefinition(
      id: 'vitamind',
      nameBangla: 'ভিটামিন ডি (Vitamin D 25-OH - হাড় ও প্রতিরোধ)',
      nameEnglish: 'Vitamin D (25-OH)',
      unit: 'ng/mL',
      categoryBangla: 'ইলেক্ট্রোলাইট ও খনিজ',
      descriptionBangla: 'হাড়ের ঘনত্ব, রোগ প্রতিরোধ ক্ষমতা এবং ক্যালসিয়াম শোষণের অপরিহার্য ভিটামিন।',
      minNormal: 30,
      maxNormal: 100,
      defaultInputValue: 38,
      ocrAliases: ['vitamin d', '25-oh vitamin d', 'vit d', 'vit-d'],
      evaluate: (val) {
        if (val < 20) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'মারাত্মক ভিটামিন ডি ঘাটতি (Deficiency)',
            statusTitleEnglish: 'Vitamin D Deficiency',
            messageBangla: 'ভিটামিন ডি ২০ এর নিচে। হাড় ক্ষয়, জয়েন্টে ব্যথা ও দুর্বলতার জন্য দায়ী।',
            messageEnglish: 'Deficiency state (< 20 ng/mL) predisposes to osteopenia and musculoskeletal pain.',
            adviceBangla: 'চিকিৎসকের পরামর্শে উচ্চমাত্রার ভিটামিন ডি ক্যাপসুল (৪০,০০০/৮০,০০০ IU) সেবন করুন এবং গায়ে রোদ লাগান।',
            adviceEnglish: 'Consult doctor for high-dose therapeutic vitamin D replacement and daily sun exposure.',
          );
        } else if (val < 30) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'অপর্যাপ্ত (Insufficiency)',
            statusTitleEnglish: 'Insufficiency',
            messageBangla: 'ভিটামিন ডি কাঙ্ক্ষিত সীমার কিছুটা নিচে রয়েছে।',
            messageEnglish: 'Insufficient vitamin D levels (20-29 ng/mL).',
            adviceBangla: 'সকালে ১৫-২০ মিনিট গায়ে রোদ লাগান, ডিমের কুসুম ও ছোট মাছ খান।',
            adviceEnglish: 'Get 15-20 mins morning sun exposure and consume egg yolks and fortified foods.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'পর্যাপ্ত ও স্বাভাবিক (Sufficient)',
          statusTitleEnglish: 'Sufficient',
          messageBangla: 'আপনার ভিটামিন ডি স্বাভাবিক ও পর্যাপ্ত।',
          messageEnglish: 'Vitamin D is in healthy sufficient range.',
          adviceBangla: 'নিয়মিত পুষ্টিকর খাদ্য ও মুক্ত আলো-বাতাস গ্রহণ করুন।',
          adviceEnglish: 'Maintain regular sunlight exposure and balanced nutrition.',
        );
      },
    ),

    // ================= 8. URINE R/E (প্রস্রাবের পরীক্ষা) =================
    // 20. Urine Pus Cells
    LabTestDefinition(
      id: 'urine_pus',
      nameBangla: 'প্রস্রাবে পুঁজ কোষ (Urine Pus Cells - ইউটিআই/ইনফেকশন)',
      nameEnglish: 'Urine Pus Cells (Urine R/E)',
      unit: '/HPF',
      categoryBangla: 'প্রস্রাবের পরীক্ষা (Urine)',
      descriptionBangla: 'প্রস্রাবে জ্বালাপোড়া বা মূত্রনালীর ইনফেকশন (UTI) যাচাইয়ের প্রাথমিক পরীক্ষা।',
      minNormal: 0,
      maxNormal: 5,
      defaultInputValue: 2,
      ocrAliases: ['pus cells', 'pus cell', 'wbc urine', 'urine pus'],
      evaluate: (val) {
        if (val > 15) {
          return const LabTestResult(
            status: LabStatus.critical,
            statusTitleBangla: 'তীব্র মূত্রনালীর ইনফেকশন (Severe UTI)',
            statusTitleEnglish: 'Active UTI',
            messageBangla: 'পুঁজ কোষ ১৫ এর বেশি। তীব্র মূত্রনালীর ইনফেকশন (UTI)। প্রস্রাবে জ্বালাপোড়া ও তলপেটে ব্যথা হতে পারে।',
            messageEnglish: 'High pus cells indicating active urinary tract infection.',
            adviceBangla: 'চিকিৎসকের পরামর্শে ইউরিন কালচার (Urine C/S) টেস্ট করান এবং সঠিক অ্যান্টিবায়োটিক কোর্স সম্পন্ন করুন।',
            adviceEnglish: 'Get a urine culture (C/S) test done and take prescribed antibiotics under medical care.',
          );
        } else if (val > 5) {
          return const LabTestResult(
            status: LabStatus.borderline,
            statusTitleBangla: 'সামান্য ইনফেকশন (Mild UTI)',
            statusTitleEnglish: 'Mild Infection',
            messageBangla: 'পুঁজ কোষ স্বাভাবিকের চেয়ে বেশি। হালকা ইনফেকশন থাকতে পারে।',
            messageEnglish: 'Elevated pus cells reflecting early or mild urinary irritation.',
            adviceBangla: 'প্রচুর পরিমাণে পানি ও তরল পান করুন। প্রস্রাব আটকে রাখবেন না।',
            adviceEnglish: 'Drink plenty of water and do not hold urine.',
          );
        }
        return const LabTestResult(
          status: LabStatus.normal,
          statusTitleBangla: 'স্বাভাবিক ও নিরাপদ (Normal)',
          statusTitleEnglish: 'Normal Range',
          messageBangla: 'প্রস্রাবে কোনো ইনফেকশন বা পুঁজ কোষের অস্বাভাবিকতা নেই।',
          messageEnglish: 'Urine pus cells are in normal healthy limits.',
          adviceBangla: 'পরিষ্কার-পরিচ্ছন্নতা ও পর্যাপ্ত পানি পান বজায় রাখুন।',
          adviceEnglish: 'Maintain good hydration and personal hygiene.',
        );
      },
    ),
  ];

  /// Get distinct categories in Bengali
  static List<String> get categories {
    final Set<String> cats = {'সব'};
    for (final t in tests) {
      cats.add(t.categoryBangla);
    }
    return cats.toList();
  }
}
