class EmergencyContact {
  final String titleBangla;
  final String titleEnglish;
  final String number;
  final String descriptionBangla;
  final String descriptionEnglish;
  final String category; // 'hotline', 'blood', 'police', 'ambulance'

  const EmergencyContact({
    required this.titleBangla,
    required this.titleEnglish,
    required this.number,
    required this.descriptionBangla,
    required this.descriptionEnglish,
    required this.category,
  });
}

class BloodBankInfo {
  final String name;
  final String division;
  final String district;
  final String phone;
  final String address;
  final List<String> availableGroups;

  const BloodBankInfo({
    required this.name,
    required this.division,
    required this.district,
    required this.phone,
    required this.address,
    required this.availableGroups,
  });
}

class FirstAidGuide {
  final String titleBangla;
  final String titleEnglish;
  final String iconName;
  final List<String> dosBangla;
  final List<String> dontsBangla;
  final List<String> dosEnglish;
  final List<String> dontsEnglish;
  final String emergencyTipBangla;
  final String emergencyTipEnglish;

  const FirstAidGuide({
    required this.titleBangla,
    required this.titleEnglish,
    required this.iconName,
    required this.dosBangla,
    required this.dontsBangla,
    required this.dosEnglish,
    required this.dontsEnglish,
    required this.emergencyTipBangla,
    required this.emergencyTipEnglish,
  });
}

class EmergencyData {
  static const List<EmergencyContact> nationalHotlines = [
    EmergencyContact(
      titleBangla: '৯৯৯ - জাতীয় জরুরি সেবা',
      titleEnglish: '999 - National Emergency',
      number: '999',
      descriptionBangla: 'পুলিশ, ফায়ার সার্ভিস ও অ্যাম্বুলেন্স সেবা (সম্পূর্ণ টোল-ফ্রি)',
      descriptionEnglish: 'Police, Fire Service & Ambulance (Toll-Free)',
      category: 'hotline',
    ),
    EmergencyContact(
      titleBangla: '১৬২৬৩ - স্বাস্থ্য বাতায়ন',
      titleEnglish: '16263 - Shastho Batayon',
      number: '16263',
      descriptionBangla: '২৪ ঘণ্টা সরকারি রেজিস্টার্ড ডাক্তারের ফ্রি স্বাস্থ্য পরামর্শ',
      descriptionEnglish: '24/7 Free Medical Advice by Registered Doctors',
      category: 'hotline',
    ),
    EmergencyContact(
      titleBangla: '১০৬৫৫ - আইইডিসিআর',
      titleEnglish: '10655 - IEDCR',
      number: '10655',
      descriptionBangla: 'সংক্রামক রোগ ও মহামারি জরুরি হটলাইন',
      descriptionEnglish: 'Infectious Disease & Epidemic Control',
      category: 'hotline',
    ),
    EmergencyContact(
      titleBangla: '৩৩৩ - জাতীয় তথ্য সেবা',
      titleEnglish: '333 - Citizen Information',
      number: '333',
      descriptionBangla: 'সরকারি স্বাস্থ্য ও জরুরি তথ্য সেবা',
      descriptionEnglish: 'Government Relief & Emergency Health Support',
      category: 'hotline',
    ),
    EmergencyContact(
      titleBangla: '১০৯ - নারী ও শিশু সহায়তা',
      titleEnglish: '109 - Women & Child Helpline',
      number: '109',
      descriptionBangla: 'নারী ও শিশু নির্যাতন প্রতিরোধে সার্বক্ষণিক সেবা',
      descriptionEnglish: '24/7 Prevention of Violence Against Women & Children',
      category: 'hotline',
    ),
  ];

  static const List<BloodBankInfo> verifiedBloodBanks = [
    // Dhaka
    BloodBankInfo(
      name: 'কোয়ান্টাম ব্লাড ল্যাব (Quantum Blood Lab)',
      division: 'ঢাকা',
      district: 'ঢাকা',
      phone: '01714010869',
      address: '৩১/১, শান্তিবাগ, ঢাকা',
      availableGroups: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
    ),
    BloodBankInfo(
      name: 'বাংলাদেশ রেড ক্রিসেন্ট ব্লাড সেন্টার',
      division: 'ঢাকা',
      district: 'ঢাকা',
      phone: '029352226',
      address: '৭/৫ আওরঙ্গজেব রোড, মোহাম্মদপুর, ঢাকা',
      availableGroups: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
    ),
    BloodBankInfo(
      name: 'সন্ধানী (ঢাকা মেডিকেল কলেজ ইউনিট)',
      division: 'ঢাকা',
      district: 'ঢাকা',
      phone: '0255165088',
      address: 'ঢাকা মেডিকেল কলেজ হাসপাতাল',
      availableGroups: ['A+', 'B+', 'O+', 'AB+'],
    ),
    BloodBankInfo(
      name: 'বাঁধন (ঢাকা বিশ্ববিদ্যালয় কেন্দ্রীয় অফিস)',
      division: 'ঢাকা',
      district: 'ঢাকা',
      phone: '01534982674',
      address: 'টিএসসি (নিচতলা), ঢাকা বিশ্ববিদ্যালয়',
      availableGroups: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
    ),
    // Chittagong
    BloodBankInfo(
      name: 'সন্ধানী (চট্টগ্রাম মেডিকেল কলেজ ইউনিট)',
      division: 'চট্টগ্রাম',
      district: 'চট্টগ্রাম',
      phone: '031616891',
      address: 'চট্টগ্রাম মেডিকেল কলেজ হাসপাতাল',
      availableGroups: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
    ),
    BloodBankInfo(
      name: 'রেড ক্রিসেন্ট ব্লাড সেন্টার (চট্টগ্রাম)',
      division: 'চট্টগ্রাম',
      district: 'চট্টগ্রাম',
      phone: '031620935',
      address: 'আন্দরকিল্লা, চট্টগ্রাম',
      availableGroups: ['A+', 'B+', 'O+', 'AB+'],
    ),
    // Rajshahi
    BloodBankInfo(
      name: 'সন্ধানী (রাজশাহী মেডিকেল কলেজ ইউনিট)',
      division: 'রাজশাহী',
      district: 'রাজশাহী',
      phone: '0721772150',
      address: 'রাজশাহী মেডিকেল কলেজ হাসপাতাল',
      availableGroups: ['A+', 'B+', 'O+', 'AB+'],
    ),
    // Sylhet
    BloodBankInfo(
      name: 'সন্ধানী (সিলেট এম.এ.জি ওসমানী মেডিকেল ইউনিট)',
      division: 'সিলেট',
      district: 'সিলেট',
      phone: '0821713005',
      address: 'ওসমানী মেডিকেল কলেজ, সিলেট',
      availableGroups: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
    ),
    // Khulna
    BloodBankInfo(
      name: 'সন্ধানী (খুলনা মেডিকেল কলেজ ইউনিট)',
      division: 'খুলনা',
      district: 'খুলনা',
      phone: '041761509',
      address: 'খুলনা মেডিকেল কলেজ হাসপাতাল',
      availableGroups: ['A+', 'B+', 'O+', 'AB+'],
    ),
    // Barisal
    BloodBankInfo(
      name: 'সন্ধানী (শের-ই-বাংলা মেডিকেল কলেজ ইউনিট)',
      division: 'বরিশাল',
      district: 'বরিশাল',
      phone: '0431217354',
      address: 'শেবাচিম হাসপাতাল, বরিশাল',
      availableGroups: ['A+', 'B+', 'O+', 'AB+'],
    ),
    // Rangpur
    BloodBankInfo(
      name: 'সন্ধানী (রংপুর মেডিকেল কলেজ ইউনিট)',
      division: 'রংপুর',
      district: 'রংপুর',
      phone: '052162330',
      address: 'রংপুর মেডিকেল কলেজ হাসপাতাল',
      availableGroups: ['A+', 'B+', 'O+', 'AB+'],
    ),
    // Mymensingh
    BloodBankInfo(
      name: 'সন্ধানী (ময়মনসিংহ মেডিকেল কলেজ ইউনিট)',
      division: 'ময়মনসিংহ',
      district: 'ময়মনসিংহ',
      phone: '09166063',
      address: 'মমেক হাসপাতাল, ময়মনসিংহ',
      availableGroups: ['A+', 'B+', 'O+', 'AB+'],
    ),
  ];

  static const List<FirstAidGuide> firstAidGuides = [
    FirstAidGuide(
      titleBangla: 'আগুনে পোড়া (Burns)',
      titleEnglish: 'Burns & Scalds',
      iconName: 'local_fire_department_rounded',
      dosBangla: [
        'পোড়া জায়গায় অবিলম্বে ১০ থেকে ২০ মিনিট পরিষ্কার সাধারণ পানি ঢালুন।',
        'পরিষ্কার ভেজা কাপড় দিয়ে আলতো করে ঢেকে দিন।',
        'রোগীকে প্রচুর পানি ও খাবার স্যালাইন পান করান।',
        'তীব্র পোড়া হলে দ্রুত নিকটস্থ বার্ন ইউনিটে বা হাসপাতালে নিন।',
      ],
      dontsBangla: [
        'পোড়া জায়গায় ডিম, টুথপেস্ট, মাটি বা ঘি লাগাবেন না।',
        'পোড়ার ফোসকা ভুলেও ফাটাবেন না বা খোঁচাবেন না।',
        'বরফ সরাসরি পোড়া ক্ষতে ঘষবেন না (এতে টিস্যুর ক্ষতি হয়)।',
      ],
      dosEnglish: [
        'Pour clean cool water over the burn for 10-20 minutes immediately.',
        'Cover loosely with a clean, damp cloth.',
        'Provide oral rehydration saline (ORS) or plenty of water.',
        'Seek emergency hospital care for severe or large burns.',
      ],
      dontsEnglish: [
        'Do not apply toothpaste, raw eggs, butter, or mud.',
        'Do not burst or puncture burn blisters.',
        'Do not apply ice directly to burned skin.',
      ],
      emergencyTipBangla: 'পানি ঢালাই আগুনে পোড়ার সবচেয়ে বড় চিকিৎসা। প্রথম ১৫ মিনিট পানি ঢাললে ক্ষতের গভীরতা অনেক কমে যায়।',
      emergencyTipEnglish: 'Running cool water for 15 minutes prevents deeper tissue burn and saves skin.',
    ),
    FirstAidGuide(
      titleBangla: 'গলায় খাবার/বস্তু আটকে যাওয়া (Choking)',
      titleEnglish: 'Choking & Airway Obstruction',
      iconName: 'warning_amber_rounded',
      dosBangla: [
        'রোগীকে জোরে জোরে কাশতে উৎসাহিত করুন।',
        'রোগীর পিঠে দুই কাঁধের মাঝখানে হাতের তালু দিয়ে ৫ বার চাপড় দিন (Back Blows)।',
        'পেটের নাভির ঠিক উপরে দুই হাত দিয়ে পেছনের দিক থেকে ধরে ভেতরের ও উপরের দিকে চাপ দিন (Heimlich Maneuver)।',
      ],
      dontsBangla: [
        'রোগী কথা বলতে পারলে পেটে অযথা চাপ দেবেন না।',
        'মুখে অন্ধভাবে আঙুল দিয়ে টেনে বের করার চেষ্টা করবেন না (বস্তুটি আরও ভেতরে ঢুকতে পারে)।',
      ],
      dosEnglish: [
        'Encourage the person to cough forcefully.',
        'Give up to 5 sharp back blows between shoulder blades.',
        'Perform abdominal thrusts (Heimlich maneuver) just above the navel.',
      ],
      dontsEnglish: [
        'Do not interfere if the person can cough or speak.',
        'Never perform blind finger sweeps in the mouth.',
      ],
      emergencyTipBangla: 'রোগী জ্ঞান হারালে অবিলম্বে মেঝেতে শুইয়ে সিপিআর শুরু করুন এবং ৯৯৯-এ কল করুন।',
      emergencyTipEnglish: 'If unconscious, lay flat and begin chest compressions immediately while calling 999.',
    ),
    FirstAidGuide(
      titleBangla: 'সাপে কাটা (Snake Bite)',
      titleEnglish: 'Snake Bite',
      iconName: 'pest_control_rounded',
      dosBangla: [
        'রোগীকে সম্পূর্ণ শান্ত ও স্থির রাখুন (নড়াচড়া করলে বিষ দ্রুত ছড়ায়)।',
        'যে অঙ্গে কেটেছে (হাত বা পা) সেটি কাঠের চ্যাটাই বা স্কেল দিয়ে সম্পূর্ণ স্থির রাখুন।',
        'দ্রুততম সময়ে সরকারি উপজেলা বা জেলা সদর হাসপাতালে নিয়ে যান (অ্যান্টিভেনম সরকারি হাসপাতালে ফ্রি পাওয়া যায়)।',
      ],
      dontsBangla: [
        'দড়ি বা তার দিয়ে শক্ত বাঁধন (Tourniquet) দেবেন না (এতে অঙ্গ পচে যেতে পারে)।',
        'কাটা জায়গায় ব্লেড দিয়ে কাটবেন না বা মুখ দিয়ে রক্ত চুষবেন না।',
        'ওঝা বা কবিরাজের কাছে নিয়ে গিয়ে সময় নষ্ট করবেন না।',
      ],
      dosEnglish: [
        'Keep the victim calm, reassuring them and immobilizing the bitten limb.',
        'Splint the limb loosely with a wooden stick or cloth.',
        'Rush directly to a government hospital (Free Anti-venom is available).',
      ],
      dontsEnglish: [
        'Do NOT tie tight ropes or tourniquets (causes gangrene).',
        'Do NOT incise with blades or try to suck out venom.',
        'Do NOT waste precious time with traditional quacks/ojhas.',
      ],
      emergencyTipBangla: 'সরকারি প্রতিটি উপজেলা ও জেলা হাসপাতালে সাপের বিষের অ্যান্টিভেনম সম্পূর্ণ বিনামূল্যে থাকে। ১ ঘণ্টার মধ্যে পৌঁছান।',
      emergencyTipEnglish: 'Government hospitals provide anti-venom free of charge. Reach within 1-2 hours.',
    ),
    FirstAidGuide(
      titleBangla: 'স্ট্রোকের লক্ষণ চেনার FAST নিয়ম',
      titleEnglish: 'Stroke FAST Protocol',
      iconName: 'psychology_rounded',
      dosBangla: [
        'F (Face): রোগীকে হাসতে বলুন—মুখের একপাশ বাঁকা হয়ে যাচ্ছে কিনা লক্ষ্য করুন।',
        'A (Arms): দুই হাত উপরে তুলতে বলুন—এক হাত দুর্বল হয়ে নেমে যাচ্ছে কিনা দেখুন।',
        'S (Speech): একটি সহজ বাক্য বলতে বলুন—কথা জড়িয়ে যাচ্ছে কিনা বা অস্পষ্ট কিনা দেখুন।',
        'T (Time): উপরের যেকোনো লক্ষণ দেখা দিলে ১ মিনিটও দেরি না করে অবিলম্বে নিকটস্থ নিউরোলজি/মেডিকেল হাসপাতালে নিন।',
      ],
      dontsBangla: [
        'রোগীকে পানি, শরবত বা মুখে কোনো ওষুধ খাওয়াবেন না (ফুসফুসে চলে গিয়ে দম বন্ধ হতে পারে)।',
        'ঘুম পাড়িয়ে বা ঘরে রেখে সুস্থ হওয়ার অপেক্ষা করবেন না।',
      ],
      dosEnglish: [
        'F (Face Droop): Ask the person to smile. Does one side of the face droop?',
        'A (Arm Weakness): Ask them to raise both arms. Does one arm drift down?',
        'S (Speech Difficulty): Ask them to repeat a simple sentence. Is speech slurred?',
        'T (Time to Call 999): If any sign is present, rush immediately to a hospital.',
      ],
      dontsEnglish: [
        'Do not give anything to eat or drink (risk of choking into lungs).',
        'Do not wait for symptoms to go away on their own.',
      ],
      emergencyTipBangla: 'স্ট্রোকের প্রথম ৪.৫ ঘণ্টার মধ্যে হাসপাতালে পৌঁছালে সম্পূর্ণ পক্ষাঘাত ও মৃত্যু থেকে রক্ষা পাওয়া সম্ভব।',
      emergencyTipEnglish: 'Golden window: Getting to a hospital within 4.5 hours can completely reverse stroke damage.',
    ),
  ];
}
