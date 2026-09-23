import '../models/medicine.dart';

enum InteractionRisk { severe, moderate, minor }

/// High-level Pharmacological / Therapeutic Classes
enum DrugClass {
  nsaid,
  bloodThinner,
  paracetamol,
  opioid,
  fluoroquinolone,
  macrolide,
  cationAntacid,
  aceArb,
  potassiumSparing,
  loopThiazideDiuretic,
  digoxin,
  nitrate,
  pde5Inhibitor,
  statin,
  ppi,
  antidiabetic,
  betaBlocker,
  thyroidHormone,
  sedative,
  antihistamine,
  antifungalAzole,
  xanthine,
  ssriAntidepressant,
  calciumChannelBlocker,
  methotrexate,
  unknown,
}

class InteractionAlert {
  final Medicine med1;
  final Medicine med2;
  final InteractionRisk risk;
  final String titleBangla;
  final String titleEnglish;
  final String explanationBangla;
  final String explanationEnglish;
  final String managementBangla;
  final String managementEnglish;

  const InteractionAlert({
    required this.med1,
    required this.med2,
    required this.risk,
    required this.titleBangla,
    required this.titleEnglish,
    required this.explanationBangla,
    required this.explanationEnglish,
    required this.managementBangla,
    required this.managementEnglish,
  });
}

class InteractionRule {
  final List<DrugClass> classGroup1;
  final List<DrugClass> classGroup2;
  final List<String>? specificDrugs1;
  final List<String>? specificDrugs2;
  final InteractionRisk risk;
  final String titleBangla;
  final String titleEnglish;
  final String explanationBangla;
  final String explanationEnglish;
  final String managementBangla;
  final String managementEnglish;

  const InteractionRule({
    required this.classGroup1,
    required this.classGroup2,
    this.specificDrugs1,
    this.specificDrugs2,
    required this.risk,
    required this.titleBangla,
    required this.titleEnglish,
    required this.explanationBangla,
    required this.explanationEnglish,
    required this.managementBangla,
    required this.managementEnglish,
  });
}

class InteractionService {
  static final InteractionService instance = InteractionService._internal();
  InteractionService._internal();

  /// Identifies the drug classes a medicine belongs to based on its generic ingredient
  List<DrugClass> identifyClasses(Medicine med) {
    final gen = med.generic.toLowerCase();
    final List<DrugClass> classes = [];

    // 1. Paracetamol
    if (gen.contains('paracetamol') || gen.contains('acetaminophen')) {
      classes.add(DrugClass.paracetamol);
    }

    // 2. NSAID
    if (gen.contains('aspirin') ||
        gen.contains('naproxen') ||
        gen.contains('diclofenac') ||
        gen.contains('ibuprofen') ||
        gen.contains('ketorolac') ||
        gen.contains('aceclofenac') ||
        gen.contains('etoricoxib') ||
        gen.contains('meloxicam') ||
        gen.contains('indomethacin') ||
        gen.contains('mefenamic') ||
        gen.contains('piroxicam')) {
      classes.add(DrugClass.nsaid);
    }

    // 3. Blood Thinner (Anticoagulants / Antiplatelets)
    if (gen.contains('clopidogrel') ||
        gen.contains('warfarin') ||
        gen.contains('rivaroxaban') ||
        gen.contains('apixaban') ||
        gen.contains('heparin') ||
        gen.contains('ticagrelor') ||
        gen.contains('prasugrel') ||
        gen.contains('dabigatran')) {
      classes.add(DrugClass.bloodThinner);
    }

    // 4. Opioids
    if (gen.contains('tramadol') ||
        gen.contains('morphine') ||
        gen.contains('codeine') ||
        gen.contains('fentanyl') ||
        gen.contains('pethidine') ||
        gen.contains('tapentadol')) {
      classes.add(DrugClass.opioid);
    }

    // 5. Fluoroquinolones
    if (gen.contains('ciprofloxacin') ||
        gen.contains('levofloxacin') ||
        gen.contains('moxifloxacin') ||
        gen.contains('ofloxacin') ||
        gen.contains('gatifloxacin')) {
      classes.add(DrugClass.fluoroquinolone);
    }

    // 6. Macrolides
    if (gen.contains('azithromycin') ||
        gen.contains('clarithromycin') ||
        gen.contains('erythromycin') ||
        gen.contains('roxithromycin')) {
      classes.add(DrugClass.macrolide);
    }

    // 7. Cations & Antacids
    if (gen.contains('calcium') ||
        gen.contains('magnesium') ||
        gen.contains('aluminum') ||
        gen.contains('antacid') ||
        gen.contains('iron') ||
        gen.contains('ferrous') ||
        gen.contains('sucralfate') ||
        gen.contains('zinc')) {
      classes.add(DrugClass.cationAntacid);
    }

    // 8. ACE Inhibitors & ARBs
    if (gen.contains('losartan') ||
        gen.contains('valsartan') ||
        gen.contains('telmisartan') ||
        gen.contains('ramipril') ||
        gen.contains('enalapril') ||
        gen.contains('captopril') ||
        gen.contains('candesartan') ||
        gen.contains('olmesartan')) {
      classes.add(DrugClass.aceArb);
    }

    // 9. Potassium Sparing Diuretics & Supplements
    if (gen.contains('spironolactone') ||
        gen.contains('eplerenone') ||
        gen.contains('amiloride') ||
        gen.contains('potassium')) {
      classes.add(DrugClass.potassiumSparing);
    }

    // 10. Loop & Thiazide Diuretics
    if (gen.contains('furosemide') ||
        gen.contains('torsemide') ||
        gen.contains('hydrochlorothiazide') ||
        gen.contains('indapamide') ||
        gen.contains('chlorthalidone')) {
      classes.add(DrugClass.loopThiazideDiuretic);
    }

    // 11. Digoxin
    if (gen.contains('digoxin')) {
      classes.add(DrugClass.digoxin);
    }

    // 12. Nitrates
    if (gen.contains('nitroglycerin') ||
        gen.contains('isosorbide') ||
        gen.contains('glyceryl trinitrate')) {
      classes.add(DrugClass.nitrate);
    }

    // 13. PDE5 Inhibitors
    if (gen.contains('sildenafil') ||
        gen.contains('tadalafil') ||
        gen.contains('vardenafil')) {
      classes.add(DrugClass.pde5Inhibitor);
    }

    // 14. Statins
    if (gen.contains('atorvastatin') ||
        gen.contains('simvastatin') ||
        gen.contains('rosuvastatin') ||
        gen.contains('pravastatin') ||
        gen.contains('lovastatin')) {
      classes.add(DrugClass.statin);
    }

    // 15. PPIs
    if (gen.contains('omeprazole') ||
        gen.contains('esomeprazole') ||
        gen.contains('pantoprazole') ||
        gen.contains('rabeprazole') ||
        gen.contains('lansoprazole') ||
        gen.contains('dexlansoprazole')) {
      classes.add(DrugClass.ppi);
    }

    // 16. Antidiabetic
    if (gen.contains('metformin') ||
        gen.contains('glimepiride') ||
        gen.contains('gliclazide') ||
        gen.contains('glibenclamide') ||
        gen.contains('linagliptin') ||
        gen.contains('sitagliptin') ||
        gen.contains('vildagliptin') ||
        gen.contains('empagliflozin') ||
        gen.contains('dapagliflozin') ||
        gen.contains('insulin')) {
      classes.add(DrugClass.antidiabetic);
    }

    // 17. Beta Blockers
    if (gen.contains('atenolol') ||
        gen.contains('propranolol') ||
        gen.contains('metoprolol') ||
        gen.contains('bisoprolol') ||
        gen.contains('carvedilol') ||
        gen.contains('nebivolol') ||
        gen.contains('labetalol')) {
      classes.add(DrugClass.betaBlocker);
    }

    // 18. Thyroid Hormone
    if (gen.contains('levothyroxine') || gen.contains('thyroxine')) {
      classes.add(DrugClass.thyroidHormone);
    }

    // 19. Sedatives / Benzodiazepines
    if (gen.contains('diazepam') ||
        gen.contains('clonazepam') ||
        gen.contains('alprazolam') ||
        gen.contains('lorazepam') ||
        gen.contains('midazolam') ||
        gen.contains('bromazepam') ||
        gen.contains('clobazam') ||
        gen.contains('zolpidem')) {
      classes.add(DrugClass.sedative);
    }

    // 20. Antihistamines
    if (gen.contains('cetirizine') ||
        gen.contains('levocetirizine') ||
        gen.contains('loratadine') ||
        gen.contains('desloratadine') ||
        gen.contains('fexofenadine') ||
        gen.contains('rupatadine') ||
        gen.contains('bilastine') ||
        gen.contains('chlorpheniramine') ||
        gen.contains('diphenhydramine') ||
        gen.contains('promethazine') ||
        gen.contains('ebastine') ||
        gen.contains('ketotifen')) {
      classes.add(DrugClass.antihistamine);
    }

    // 21. Azole Antifungals
    if (gen.contains('fluconazole') ||
        gen.contains('itraconazole') ||
        gen.contains('ketoconazole') ||
        gen.contains('voriconazole')) {
      classes.add(DrugClass.antifungalAzole);
    }

    // 22. Xanthines
    if (gen.contains('theophylline') ||
        gen.contains('aminophylline') ||
        gen.contains('doxofylline')) {
      classes.add(DrugClass.xanthine);
    }

    // 23. SSRIs & Antidepressants
    if (gen.contains('fluoxetine') ||
        gen.contains('escitalopram') ||
        gen.contains('sertraline') ||
        gen.contains('paroxetine') ||
        gen.contains('duloxetine') ||
        gen.contains('venlafaxine')) {
      classes.add(DrugClass.ssriAntidepressant);
    }

    // 24. CCB
    if (gen.contains('amlodipine') ||
        gen.contains('nifedipine') ||
        gen.contains('diltiazem') ||
        gen.contains('verapamil') ||
        gen.contains('cilnidipine')) {
      classes.add(DrugClass.calciumChannelBlocker);
    }

    // 25. Methotrexate
    if (gen.contains('methotrexate')) {
      classes.add(DrugClass.methotrexate);
    }

    if (classes.isEmpty) {
      classes.add(DrugClass.unknown);
    }

    return classes;
  }

  /// Friendly Bengali and English titles for drug classes
  String getDrugClassLabel(DrugClass c, bool isBangla) {
    switch (c) {
      case DrugClass.nsaid:
        return isBangla ? 'ব্যথানাশক (NSAID)' : 'Painkiller (NSAID)';
      case DrugClass.bloodThinner:
        return isBangla ? 'রক্ত তরলকারী (Blood Thinner)' : 'Blood Thinner';
      case DrugClass.paracetamol:
        return isBangla ? 'প্যারাসিটামল' : 'Paracetamol';
      case DrugClass.opioid:
        return isBangla ? 'তীব্র ব্যথানাশক (Opioid)' : 'Opioid Analgesic';
      case DrugClass.fluoroquinolone:
        return isBangla ? 'কুইনোলোন অ্যান্টিবায়োটিক' : 'Fluoroquinolone Antibiotic';
      case DrugClass.macrolide:
        return isBangla ? 'ম্যাক্রোলাইড অ্যান্টিবায়োটিক' : 'Macrolide Antibiotic';
      case DrugClass.cationAntacid:
        return isBangla ? 'এন্টাসিড / খনিজ ক্যালসিয়াম' : 'Antacid / Mineral';
      case DrugClass.aceArb:
        return isBangla ? 'রক্তচাপ নিয়ন্ত্রণ (ACEi/ARB)' : 'Blood Pressure (ACEi/ARB)';
      case DrugClass.potassiumSparing:
        return isBangla ? 'পটাশিয়াম সংরক্ষণকারী' : 'Potassium-Sparing';
      case DrugClass.loopThiazideDiuretic:
        return isBangla ? 'মূত্রবর্ধক (Diuretic)' : 'Diuretic';
      case DrugClass.digoxin:
        return isBangla ? 'হৃদরোগের ওষুধ (Digoxin)' : 'Cardiac Glycoside';
      case DrugClass.nitrate:
        return isBangla ? 'হৃদযন্ত্রের নাইট্রেট' : 'Nitrate Vasodilator';
      case DrugClass.pde5Inhibitor:
        return isBangla ? 'ভাসোডিলেটর (PDE5)' : 'PDE5 Inhibitor';
      case DrugClass.statin:
        return isBangla ? 'কোলেস্টেরল কমানোর ওষুধ (Statin)' : 'Statin (Cholesterol)';
      case DrugClass.ppi:
        return isBangla ? 'গ্যাস্ট্রিকের ওষুধ (PPI)' : 'Gastric Acid Reducer (PPI)';
      case DrugClass.antidiabetic:
        return isBangla ? 'ডায়াবেটিসের ওষুধ' : 'Antidiabetic';
      case DrugClass.betaBlocker:
        return isBangla ? 'বিটা-ব্লকার রক্তচাপ' : 'Beta Blocker';
      case DrugClass.thyroidHormone:
        return isBangla ? 'থাইরয়েড হরমোন' : 'Thyroid Hormone';
      case DrugClass.sedative:
        return isBangla ? 'ঘুম / প্রশান্তিদায়ক ওষুধ' : 'Sedative / Anxiolytic';
      case DrugClass.antihistamine:
        return isBangla ? 'অ্যালার্জির ওষুধ' : 'Antihistamine';
      case DrugClass.antifungalAzole:
        return isBangla ? 'ছত্রাকবিরোধী (Antifungal)' : 'Azole Antifungal';
      case DrugClass.xanthine:
        return isBangla ? 'হাঁপানি / শ্বাসনালী প্রসারক' : 'Bronchodilator (Xanthine)';
      case DrugClass.ssriAntidepressant:
        return isBangla ? 'মন বা স্নায়ুর ওষুধ (SSRI)' : 'Antidepressant (SSRI)';
      case DrugClass.calciumChannelBlocker:
        return isBangla ? 'ক্যালসিয়াম চ্যানেল ব্লকার' : 'Calcium Channel Blocker';
      case DrugClass.methotrexate:
        return isBangla ? 'মেথোট্রেক্সেট' : 'Methotrexate';
      case DrugClass.unknown:
        return isBangla ? 'ওষুধ' : 'Medicine';
    }
  }

  /// Comprehensive Clinical Class-to-Class Interaction Rules
  static final List<InteractionRule> _rules = [
    // 1. NSAIDs + Blood Thinners
    const InteractionRule(
      classGroup1: [DrugClass.nsaid],
      classGroup2: [DrugClass.bloodThinner],
      risk: InteractionRisk.severe,
      titleBangla: 'রক্তক্ষরণের মারাত্মক ঝুঁকি (Severe Bleeding)',
      titleEnglish: 'Severe Hemorrhage / Bleeding Risk',
      explanationBangla: 'ব্যথানাশক ওষুধ রক্ত জমাট বাঁধার ওষুধকে মাত্রাতিরিক্ত তরল করে পেট, পাকস্থলী বা মস্তিষ্কে অভ্যন্তরীণ রক্তক্ষরণ ঘটাতে পারে।',
      explanationEnglish: 'Combining NSAIDs with blood thinners severely elevates gastrointestinal and systemic hemorrhage risks.',
      managementBangla: 'একসাথে খাওয়া সম্পূর্ণ নিষেধ। ব্যথা হলে চিকিৎসকের পরামর্শে শুধু প্যারাসিটামল ব্যবহার করুন।',
      managementEnglish: 'Avoid concurrent use. Use Paracetamol for pain or consult your doctor for safer alternatives.',
    ),

    // 2. Double Paracetamol (Duplicate Overdosage)
    const InteractionRule(
      classGroup1: [DrugClass.paracetamol],
      classGroup2: [DrugClass.paracetamol],
      risk: InteractionRisk.severe,
      titleBangla: 'একই জাতীয় ওষুধের দ্বৈত মাত্রা (Overdose / Liver Damage)',
      titleEnglish: 'Duplicate Paracetamol Therapy Risk',
      explanationBangla: 'ভিন্ন কোম্পানির ব্র্যান্ড হলেও দুটোই প্যারাসিটামল। একসাথে খেলে লিভারের মারাত্মক ক্ষতি বা লিভার বিকল হতে পারে।',
      explanationEnglish: 'Both selected medicines contain Paracetamol. Concurrent use can lead to acute hepatotoxicity.',
      managementBangla: 'যেকোনো একটি ওষুধ সেবন করুন। দিনে ৪ গ্রামের (৮টি ৫০০ মিগ্রা ট্যাবলেট) বেশি কখনোই খাবেন না।',
      managementEnglish: 'Take only one brand. Never exceed 4,000 mg (8 x 500mg tablets) within 24 hours.',
    ),

    // 3. Double NSAID (Duplicate Painkillers)
    const InteractionRule(
      classGroup1: [DrugClass.nsaid],
      classGroup2: [DrugClass.nsaid],
      risk: InteractionRisk.severe,
      titleBangla: 'দ্বৈত ব্যথানাশক / পেটে আলসারের মারাত্মক ঝুঁকি (Duplicate NSAIDs)',
      titleEnglish: 'Duplicate NSAID Toxicity Risk',
      explanationBangla: 'দুটি ভিন্ন ব্যথানাশক একসাথে খেলে ব্যথানাশক কার্যকারিতা বাড়ে না, বরং পেটে মারাত্মক গ্যাস্ট্রিক আলসার, রক্তবমি এবং কিডনি বিকল হতে পারে।',
      explanationEnglish: 'Taking multiple NSAIDs concurrently provides no added analgesia but drastically increases gastrointestinal ulceration, perforation, and acute renal failure.',
      managementBangla: 'একসাথে একাধিক ব্যথানাশক কখনোই খাবেন না। চিকিৎসকের পরামর্শে যেকোনো একটি মাত্র নির্দিষ্ট মাত্রায় গ্রহণ করুন।',
      managementEnglish: 'Never take two NSAIDs together. Use only one as prescribed by your physician.',
    ),

    // 4. Double Antihistamine (Excessive Sedation)
    const InteractionRule(
      classGroup1: [DrugClass.antihistamine],
      classGroup2: [DrugClass.antihistamine],
      risk: InteractionRisk.moderate,
      titleBangla: 'দ্বৈত অ্যালার্জির ওষুধ / তীব্র তন্দ্রাচ্ছন্নতা (Duplicate Antihistamine)',
      titleEnglish: 'Duplicate Antihistamine Therapy',
      explanationBangla: 'একসাথে দুটি অ্যালার্জির ওষুধ খেলে অতিরিক্ত ঘুমভাব, মুখ শুকিয়ে যাওয়া, চোখে ঝাপসা দেখা এবং মস্তিষ্কের বিভ্রান্তি তৈরি হতে পারে।',
      explanationEnglish: 'Concurrent antihistamines compound anticholinergic burden, leading to excessive drowsiness and cognitive impairment.',
      managementBangla: 'যেকোনো একটি অ্যালার্জির ওষুধ চিকিৎসকের নির্দেশিত সময়ে সেবন করুন।',
      managementEnglish: 'Take only one antihistamine at a time unless specifically guided by a specialist.',
    ),

    // 5. Double PPI (Duplicate Gastric Acid Reducers)
    const InteractionRule(
      classGroup1: [DrugClass.ppi],
      classGroup2: [DrugClass.ppi],
      risk: InteractionRisk.moderate,
      titleBangla: 'একই জাতীয় গ্যাস্ট্রিকের ওষুধের দ্বৈত মাত্রা (Duplicate PPI)',
      titleEnglish: 'Duplicate Proton Pump Inhibitor (PPI)',
      explanationBangla: 'ভিন্ন ব্র্যান্ড হলেও দুটোই ওমেপ্রাজল বা এসোমেপ্রাজল জাতীয় গ্যাস্ট্রিকের ক্যাপসুল। একসাথে খেলে পেটের স্বাভাবিক অ্যাসিড শূন্য হয়ে হজমে ও পুষ্টি শোষণে ব্যাঘাত ঘটে।',
      explanationEnglish: 'Both medications suppress gastric acid. Taking duplicates provides no added benefit and raises risks of micronutrient malabsorption.',
      managementBangla: 'যেকোনো একটি ব্র্যান্ড বেছে নিন এবং প্রতিদিন সকালে খাবার ৩০ মিনিট পূর্বে একটি মাত্র গ্রহণ করুন।',
      managementEnglish: 'Use only one PPI once daily 30 minutes before breakfast.',
    ),

    // 6. Fluoroquinolones + Antacids/Calcium/Iron
    const InteractionRule(
      classGroup1: [DrugClass.fluoroquinolone],
      classGroup2: [DrugClass.cationAntacid],
      risk: InteractionRisk.moderate,
      titleBangla: 'অ্যান্টিবায়োটিকের শোষণ সম্পূর্ণ বন্ধ (Absorption Block)',
      titleEnglish: 'Impaired Fluoroquinolone Absorption',
      explanationBangla: 'এন্টাসিড, ক্যালসিয়াম বা আয়রন ট্যাবলেটের খনিজ উপাদান পেটে অ্যান্টিবায়োটিককে বেঁধে ফেলে (Chelation), ফলে ওষুধ রক্তে প্রবেশই করতে পারে না।',
      explanationEnglish: 'Polyvalent cations in antacids, iron, or calcium bind fluoroquinolones, preventing therapeutic systemic absorption.',
      managementBangla: 'অ্যান্টিবায়োটিক খাওয়ার অন্তত ২ ঘণ্টা আগে অথবা ৪ ঘণ্টা পরে এন্টাসিড বা ক্যালসিয়াম গ্রহণ করুন।',
      managementEnglish: 'Take the antibiotic at least 2 hours before or 4 hours after taking antacids, calcium, or iron.',
    ),

    // 7. Thyroid Hormone (Levothyroxine) + Cations / Antacids / Iron
    const InteractionRule(
      classGroup1: [DrugClass.thyroidHormone],
      classGroup2: [DrugClass.cationAntacid],
      risk: InteractionRisk.severe,
      titleBangla: 'থাইরক্সিন ওষুধের শোষণ ব্যর্থতা (Levothyroxine Inactivation)',
      titleEnglish: 'Severe Inactivation of Levothyroxine',
      explanationBangla: 'ক্যালসিয়াম, আয়রন বা এন্টাসিড থাইরক্সিনের শোষণ প্রায় বন্ধ করে দেয়। ফলে নিয়মিত ওষুধ খেয়েও রক্তে থাইরয়েডের ঘাটতি ঠিক হয় না।',
      explanationEnglish: 'Calcium, iron, and antacids bind levothyroxine in the gut, leading to persistent clinical hypothyroidism.',
      managementBangla: 'থাইরক্সিন সবসময় সকালে খালি পেটে এক গ্লাস পানিসহ খাবেন। ক্যালসিয়াম বা অ্যান্টাসিড তার অন্তত ৪ ঘণ্টা পরে খাবেন।',
      managementEnglish: 'Take levothyroxine on an empty stomach with plain water. Separate calcium and iron by at least 4 hours.',
    ),

    // 8. ACE Inhibitors / ARBs + Potassium Sparing Diuretics
    const InteractionRule(
      classGroup1: [DrugClass.aceArb],
      classGroup2: [DrugClass.potassiumSparing],
      risk: InteractionRisk.severe,
      titleBangla: 'রক্তে পটাশিয়াম বেড়ে জীবনঘাতী হৃদস্পন্দন (Hyperkalemia)',
      titleEnglish: 'Dangerous Hyperkalemia Risk',
      explanationBangla: 'উভয় ওষুধ কিডনি দিয়ে পটাশিয়াম বের হওয়া বন্ধ করে দেয়। রক্তে পটাশিয়াম অতিরিক্ত বেড়ে গেলে হঠাৎ হৃদস্পন্দনের ছন্দপতন ও হার্ট অ্যাটাক হতে পারে।',
      explanationEnglish: 'Both drug classes retain potassium, predisposing patients to fatal cardiac arrhythmias.',
      managementBangla: 'চিকিৎসকের নিবিড় তত্ত্বাবধানে রক্তের সিরাম পটাশিয়াম ও ক্রিয়েটিনিন টেস্ট নিয়মিত মনিটর করুন।',
      managementEnglish: 'Requires strict serum potassium and renal function monitoring under physician guidance.',
    ),

    // 9. Nitrates + PDE5 Inhibitors (Sildenafil / Tadalafil)
    const InteractionRule(
      classGroup1: [DrugClass.nitrate],
      classGroup2: [DrugClass.pde5Inhibitor],
      risk: InteractionRisk.severe,
      titleBangla: 'মারাত্মক রক্তচাপ পতন ও জীবনঘাতী হার্ট অ্যাটাক (Fatal Hypotension)',
      titleEnglish: 'Profound Vasodilation & Fatal Hypotension Risk',
      explanationBangla: 'এই দুটি ওষুধ একসাথে রক্তনালী অতিমাত্রায় প্রসারিত করে রক্তচাপ শূন্যের কোঠায় নামিয়ে দেয়, যা তাৎক্ষণিক জীবনঘাতী হতে পারে।',
      explanationEnglish: 'Co-administration causes sudden, profound, and refractory systemic vasodilation and hypotension.',
      managementBangla: 'হৃদরোগীদের জন্য এই কম্বিনেশন সম্পূর্ণ নিষিদ্ধ ও বিপজ্জনক। কখনোই একসাথে সেবন করবেন না।',
      managementEnglish: 'Concurrent use is strictly contraindicated. Seek emergency care if accidental co-ingestion occurs.',
    ),

    // 10. Statins + Macrolides
    const InteractionRule(
      classGroup1: [DrugClass.statin],
      classGroup2: [DrugClass.macrolide],
      risk: InteractionRisk.severe,
      titleBangla: 'মাংসপেশির মারাত্মক ক্ষয় ও কিডনি ক্ষতি (Rhabdomyolysis)',
      titleEnglish: 'Acute Rhabdomyolysis & Statin Toxicity',
      explanationBangla: 'ম্যাক্রোলাইড অ্যান্টিবায়োটিক স্ট্যাটিনের স্বাভাবিক বিপাক আটকে দেয়, ফলে রক্তে কোলেস্টেরল কমানোর ওষুধ বিষাক্ত হয়ে পেশি গলিয়ে কিডনি ধ্বংস করতে পারে।',
      explanationEnglish: 'Macrolides strongly inhibit CYP3A4-mediated statin metabolism, triggering severe muscle breakdown (rhabdomyolysis).',
      managementBangla: 'অ্যান্টিবায়োটিকের কোর্স চলার দিনগুলোতে চিকিৎসকের পরামর্শে স্ট্যাটিন সাময়িকভাবে স্থগিত রাখতে হয়।',
      managementEnglish: 'Consult doctor; statin therapy is generally paused temporarily during the antibiotic course.',
    ),

    // 11. Statins + Azole Antifungals
    const InteractionRule(
      classGroup1: [DrugClass.statin],
      classGroup2: [DrugClass.antifungalAzole],
      risk: InteractionRisk.severe,
      titleBangla: 'স্ট্যাটিন বিষক্রিয়া ও পেশির ধ্বংস (Statin + Antifungal Risk)',
      titleEnglish: 'Severe Statin Overexposure with Azole Antifungals',
      explanationBangla: 'ফ্লুকোনাজোল বা ইট্রাকোনাজোল লিভারের এনজাইম বন্ধ করে রক্তে স্ট্যাটিনের ঘনত্ব বিপজ্জনক মাত্রায় বাড়িয়ে দেয়।',
      explanationEnglish: 'Azole antifungals impair statin clearance, drastically raising serum drug concentrations and toxic myopathy risk.',
      managementBangla: 'ছত্রাকবিরোধী কোর্স চলার সময় চিকিৎসকের পরামর্শ ছাড়া স্ট্যাটিন গ্রহণ করবেন না।',
      managementEnglish: 'Do not co-administer without physician dosage adjustment or temporary suspension.',
    ),

    // 12. Omeprazole / Esomeprazole + Clopidogrel
    const InteractionRule(
      classGroup1: [DrugClass.ppi],
      classGroup2: [DrugClass.bloodThinner],
      specificDrugs1: ['omeprazole', 'esomeprazole'],
      specificDrugs2: ['clopidogrel'],
      risk: InteractionRisk.moderate,
      titleBangla: 'রক্ত তরল করার কার্যকারিতা হ্রাস (Antiplatelet Attenuation)',
      titleEnglish: 'Reduced Antiplatelet Efficacy of Clopidogrel',
      explanationBangla: 'ওমেপ্রাজল লিভারের CYP2C19 এনজাইম ব্লক করে ক্লোপিডোগ্রেলের রক্ত জমাট বাঁধার প্রতিরোধ ক্ষমতা উল্লেখযোগ্যভাবে কমিয়ে দেয়।',
      explanationEnglish: 'Omeprazole competitively inhibits CYP2C19 bioactivation of clopidogrel, diminishing its cardioprotective effect.',
      managementBangla: 'গ্যাস্ট্রিকের জন্য ওমেপ্রাজলের বিকল্প হিসেবে প্যান্টোপ্রাজল (Pantoprazole) ব্যবহারে এই সংঘাত থাকে না।',
      managementEnglish: 'Switching to Pantoprazole is recommended as it has minimal CYP2C19 interaction.',
    ),

    // 13. Antidiabetic (Sulfonylurea/Insulin) + Beta Blockers
    const InteractionRule(
      classGroup1: [DrugClass.antidiabetic],
      classGroup2: [DrugClass.betaBlocker],
      risk: InteractionRisk.severe,
      titleBangla: 'নীরব হাইপোগ্লাইসেমিয়া / সুগার কমে অজ্ঞান হওয়া (Masked Hypoglycemia)',
      titleEnglish: 'Masking of Hypoglycemia Symptoms',
      explanationBangla: 'রক্তে সুগার মারাত্মক কমে গেলে শরীর বুক ধড়ফড় ও হাত কাঁপুনি দিয়ে সতর্ক করে। কিন্তু বিটা-ব্লকার এই লক্ষণগুলো ঢেকে ফেলে, ফলে রোগী না বুঝেই সংজ্ঞাহীন হতে পারেন।',
      explanationEnglish: 'Beta blockers mask sympathetic warning signs of acute hypoglycemia (tachycardia, tremor), prolonging dangerous hypoglycemic episodes.',
      managementBangla: 'ডায়াবেটিসের রোগীদের রক্তের গ্লুকোজ নিয়মিত গ্লুকোমিটার দিয়ে মেপে দেখতে হবে এবং মাথা ঘোরালে দ্রুত মিষ্টি বা শরবত খেতে হবে।',
      managementEnglish: 'Frequently monitor blood glucose levels; understand sweating may be the only remaining sign of low sugar.',
    ),

    // 14. Metformin + NSAIDs
    const InteractionRule(
      classGroup1: [DrugClass.antidiabetic],
      classGroup2: [DrugClass.nsaid],
      specificDrugs1: ['metformin'],
      risk: InteractionRisk.severe,
      titleBangla: 'কিডনির ক্ষতি ও রক্তে প্রাণঘাতী অ্যাসিডোসিস (Lactic Acidosis)',
      titleEnglish: 'Renal Impairment & Lactic Acidosis Risk',
      explanationBangla: 'ব্যথানাশক ওষুধ কিডনির রক্তপ্রবাহ কমিয়ে মেটফর্মিন নিষ্কাশন আটকে দেয়। ফলে রক্তে মারাত্মক ল্যাকটিক অ্যাসিড জমে জীবন সংশয় হতে পারে।',
      explanationEnglish: 'NSAID-induced renal hypoperfusion impairs metformin excretion, predisposing elderly patients to life-threatening lactic acidosis.',
      managementBangla: 'ডায়াবেটিসে মেটফর্মিন খেলে তীব্র ব্যথানাশক এড়িয়ে চলুন। চিকিৎসকের পরামর্শ ছাড়া ব্যথার ওষুধ খাবেন না।',
      managementEnglish: 'Avoid concurrent NSAIDs with Metformin; consult your doctor for safe analgesic alternatives.',
    ),

    // 15. Sedatives (Benzodiazepines) + Antihistamines / Opioids
    const InteractionRule(
      classGroup1: [DrugClass.sedative],
      classGroup2: [DrugClass.antihistamine, DrugClass.opioid],
      risk: InteractionRisk.severe,
      titleBangla: 'তীব্র শ্বাসকষ্ট ও মস্তিষ্কের অবসাদ (Severe CNS & Respiratory Depression)',
      titleEnglish: 'Severe Respiratory Depression & CNS Collapse',
      explanationBangla: 'ঘুমের ওষুধের সাথে তীব্র ব্যথানাশক বা অ্যালার্জির ওষুধ একসাথে খেলে শ্বাসযন্ত্র হঠাৎ বন্ধ হয়ে কোমায় চলে যাওয়ার চরম ঝুঁকি থাকে।',
      explanationEnglish: 'Concomitant administration compounds central nervous system sedation and respiratory drive suppression.',
      managementBangla: 'একসাথে কোনো অবস্থাতেই খাবেন না। চিকিৎসকের নিবিড় নির্দেশনা ছাড়া ঘুমের ওষুধ ও ট্রামাডল বা কড়া কাশির সিরাপ মেশাবেন না।',
      managementEnglish: 'Strictly avoid co-ingestion unless monitored in a specialized clinical setting.',
    ),

    // 16. Opioid (Tramadol) + SSRI Antidepressants
    const InteractionRule(
      classGroup1: [DrugClass.opioid],
      classGroup2: [DrugClass.ssriAntidepressant],
      specificDrugs1: ['tramadol'],
      risk: InteractionRisk.severe,
      titleBangla: 'সেরোটোনিন সিন্ড্রোম ও খিঁচুনি (Serotonin Syndrome)',
      titleEnglish: 'Serotonin Syndrome & Seizure Risk',
      explanationBangla: 'ট্রামাডল এবং বিষণ্ণতার ওষুধ একসাথে মস্তিষ্কে সেরোটোনিনের মাত্রা বিপজ্জনকভাবে বাড়িয়ে খিঁচুনি, তীব্র জ্বর ও বিভ্রান্তি ঘটায়।',
      explanationEnglish: 'Combining tramadol with serotonergic antidepressants triggers excessive serotonin accumulation, causing muscle rigidity and seizures.',
      managementBangla: 'এই কম্বিনেশন পরিহার করুন এবং ব্যথার বিকল্প ওষুধ নিয়ে চিকিৎসকের পরামর্শ নিন।',
      managementEnglish: 'Avoid concurrent use; seek medical guidance for safer pain management.',
    ),

    // 17. Digoxin + Loop / Thiazide Diuretics
    const InteractionRule(
      classGroup1: [DrugClass.digoxin],
      classGroup2: [DrugClass.loopThiazideDiuretic],
      risk: InteractionRisk.severe,
      titleBangla: 'ডিগক্সিন বিষক্রিয়া ও হার্ট ফেইলিউর (Digoxin Toxicity via Hypokalemia)',
      titleEnglish: 'Diuretic-Induced Digoxin Toxicity',
      explanationBangla: 'মূত্রবর্ধক ওষুধ প্রস্রাবের মাধ্যমে পটাশিয়াম বের করে দেয়। রক্তে পটাশিয়াম কমলে ডিগক্সিন অতিরিক্ত বিষাক্ত হয়ে হৃদযন্ত্রের মারাত্মক ছন্দপতন ঘটায়।',
      explanationEnglish: 'Diuretic-induced hypokalemia sensitizes the myocardium to digoxin, precipitating lethal cardiac toxicity.',
      managementBangla: 'চিকিৎসকের পরামর্শ অনুযায়ী পটাশিয়াম সাপ্লিমেন্ট গ্রহণ ও রক্তের ইলেক্ট্রোলাইট নিয়মিত পরীক্ষা করান।',
      managementEnglish: 'Requires serum potassium supplementation and strict digoxin level monitoring.',
    ),

    // 18. Macrolides + Fluoroquinolones
    const InteractionRule(
      classGroup1: [DrugClass.macrolide],
      classGroup2: [DrugClass.fluoroquinolone],
      risk: InteractionRisk.severe,
      titleBangla: 'হৃদযন্ত্রের ছন্দের বিপজ্জনক ব্যাঘাত (Dangerous QT Prolongation)',
      titleEnglish: 'Additive QT Prolongation & Arrhythmia Risk',
      explanationBangla: 'উভয় অ্যান্টিবায়োটিক হার্টের বৈদ্যুতিক তরঙ্গ প্রসারিত করে আকস্মিক মারাত্মক কার্ডিয়াক অ্যারেস্টের ঝুঁকি বহুগুণ বাড়িয়ে দেয়।',
      explanationEnglish: 'Concurrent use exerts additive cardiac repolarization prolongation, increasing risks of Torsades de Pointes.',
      managementBangla: 'একসাথে দুটি ভিন্ন গ্রুপের এই অ্যান্টিবায়োটিক ব্যবহার করা মারাত্মক বিপজ্জনক ও নিষিদ্ধ।',
      managementEnglish: 'Avoid concurrent administration of these two antibiotic classes.',
    ),

    // 19. Xanthine (Theophylline) + Fluoroquinolones (Ciprofloxacin)
    const InteractionRule(
      classGroup1: [DrugClass.xanthine],
      classGroup2: [DrugClass.fluoroquinolone],
      risk: InteractionRisk.severe,
      titleBangla: 'থিওফাইলিন বিষক্রিয়া ও খিঁচুনি (Theophylline Toxicity)',
      titleEnglish: 'Severe Theophylline Toxicity',
      explanationBangla: 'সিপ্রোফ্লক্সাসিন হাঁপানির ওষুধের বিপাক আটকে দেয়, ফলে রক্তে থিওফাইলিনের মাত্রা মাত্রাতিরিক্ত হয়ে বমি, অনিয়মিত হৃদস্পন্দন ও খিঁচুনি হতে পারে।',
      explanationEnglish: 'Ciprofloxacin inhibits CYP1A2, drastically reducing theophylline clearance and causing neurotoxicity and seizures.',
      managementBangla: 'হাঁপানির রোগীর জন্য সিপ্রোফ্লক্সাসিনের বদলে ভিন্ন অ্যান্টিবায়োটিক ব্যবহার করা আবশ্যক।',
      managementEnglish: 'Select an alternative antibiotic with no CYP1A2 inhibitory profile.',
    ),

    // 20. Methotrexate + NSAIDs
    const InteractionRule(
      classGroup1: [DrugClass.methotrexate],
      classGroup2: [DrugClass.nsaid],
      risk: InteractionRisk.severe,
      titleBangla: 'মেথোট্রেক্সেট বিষক্রিয়া ও অস্থিমজ্জা ধ্বংস (Methotrexate Toxicity)',
      titleEnglish: 'Fatal Bone Marrow Suppression Risk',
      explanationBangla: 'ব্যথানাশক ওষুধ কিডনি দিয়ে মেথোট্রেক্সেট বের হওয়া বন্ধ করে দেয়, যার ফলে রক্তে এর মাত্রা বেড়ে শ্বেতরক্তকণিকা শূন্য হয়ে রক্তশূন্যতা ও সংক্রমণ তৈরি হয়।',
      explanationEnglish: 'NSAIDs reduce renal methotrexate clearance, causing severe pancytopenia and gastrointestinal mucosal ulceration.',
      managementBangla: 'বাত ব্যথার রোগী মেথোট্রেক্সেট চলাকালীন চিকিৎসকের লিখিত অনুমোদন ছাড়া কোনো ব্যথানাশক খাবেন না।',
      managementEnglish: 'Avoid concurrent NSAID administration without specialist oncology or rheumatology clearance.',
    ),

    // 21. CCB (Diltiazem/Verapamil) + Beta Blockers
    const InteractionRule(
      classGroup1: [DrugClass.calciumChannelBlocker],
      classGroup2: [DrugClass.betaBlocker],
      specificDrugs1: ['diltiazem', 'verapamil'],
      risk: InteractionRisk.severe,
      titleBangla: 'হৃদস্পন্দন মারাত্মক কমে হার্ট ব্লক (Bradycardia & Heart Block)',
      titleEnglish: 'Profound Bradycardia and Complete Heart Block Risk',
      explanationBangla: 'উভয় ওষুধ হৃদস্পন্দনের গতি কমায়। একসাথে দিলে হার্ট রেট মাত্রাতিরিক্ত কমে হার্ট ফেইলিউর বা ব্র্যাডিকার্ডিয়া হতে পারে।',
      explanationEnglish: 'Combined negative inotropic and dromotropic effects can precipitate acute heart failure or AV block.',
      managementBangla: 'এই কম্বিনেশন হৃদরোগ বিশেষজ্ঞের সুনির্দিষ্ট তদারকি ছাড়া সেবন করা সম্পূর্ণ নিষিদ্ধ।',
      managementEnglish: 'Avoid combination unless specifically titrated and monitored by an electrophysiologist.',
    ),

    // 22. Statin + Calcium Channel Blocker (Amlodipine)
    const InteractionRule(
      classGroup1: [DrugClass.statin],
      classGroup2: [DrugClass.calciumChannelBlocker],
      specificDrugs1: ['simvastatin', 'atorvastatin'],
      specificDrugs2: ['amlodipine'],
      risk: InteractionRisk.moderate,
      titleBangla: 'পেশিব্যথা ও স্ট্যাটিন ঘনত্ব বৃদ্ধি (Increased Statin Exposure)',
      titleEnglish: 'Elevated Statin Levels & Myopathy Risk',
      explanationBangla: 'আমলোডিপিন শরীরে স্ট্যাটিনের রক্তঘনত্ব বাড়িয়ে পেশিব্যথা ও দুর্বলতা তৈরি করতে পারে।',
      explanationEnglish: 'Amlodipine modestly elevates statin exposure, increasing risk of muscle aching and mild myopathy.',
      managementBangla: 'একসাথে প্রেসক্রাইব করা হলে স্ট্যাটিনের ডোজ চিকিৎসকের পরামর্শে পরিমিত রাখা উচিত (যেমন সিমভাস্টাটিন ২০ মিগ্রার বেশি নয়)।',
      managementEnglish: 'Dosage limits may apply; consult your doctor if unexplainable muscle soreness develops.',
    ),
  ];

  /// Checks a list of selected medicines against all class-based interaction rules
  List<InteractionAlert> analyzeInteractions(List<Medicine> medicines) {
    final List<InteractionAlert> alerts = [];

    if (medicines.length < 2) return alerts;

    for (var i = 0; i < medicines.length; i++) {
      for (var j = i + 1; j < medicines.length; j++) {
        final medA = medicines[i];
        final medB = medicines[j];
        final genA = medA.generic.toLowerCase();
        final genB = medB.generic.toLowerCase();

        final classesA = identifyClasses(medA);
        final classesB = identifyClasses(medB);

        for (final rule in _rules) {
          // Check if rule matches class groups
          final matchClassesDirect = classesA.any((cA) => rule.classGroup1.contains(cA)) &&
              classesB.any((cB) => rule.classGroup2.contains(cB));
          final matchClassesReverse = classesB.any((cB) => rule.classGroup1.contains(cB)) &&
              classesA.any((cA) => rule.classGroup2.contains(cA));

          if (!matchClassesDirect && !matchClassesReverse) continue;

          // Check specific drug constraints if defined
          if (rule.specificDrugs1 != null) {
            final hasSpec1A = rule.specificDrugs1!.any((d) => genA.contains(d));
            final hasSpec1B = rule.specificDrugs1!.any((d) => genB.contains(d));
            if (!hasSpec1A && !hasSpec1B) continue;
          }

          if (rule.specificDrugs2 != null) {
            final hasSpec2A = rule.specificDrugs2!.any((d) => genA.contains(d));
            final hasSpec2B = rule.specificDrugs2!.any((d) => genB.contains(d));
            if (!hasSpec2A && !hasSpec2B) continue;
          }

          // Matched! Add alert
          alerts.add(InteractionAlert(
            med1: medA,
            med2: medB,
            risk: rule.risk,
            titleBangla: rule.titleBangla,
            titleEnglish: rule.titleEnglish,
            explanationBangla: rule.explanationBangla,
            explanationEnglish: rule.explanationEnglish,
            managementBangla: rule.managementBangla,
            managementEnglish: rule.managementEnglish,
          ));
          break; // Matched first highest-priority rule for this pair
        }
      }
    }

    return alerts;
  }
}
