import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_strings.dart';

class VaccineDose {
  final String titleBangla;
  final String titleEnglish;
  final String diseaseCoveredBangla;
  final String diseaseCoveredEnglish;
  final int dueDaysFromBirth;

  const VaccineDose({
    required this.titleBangla,
    required this.titleEnglish,
    required this.diseaseCoveredBangla,
    required this.diseaseCoveredEnglish,
    required this.dueDaysFromBirth,
  });
}

class VaccinationTrackerScreen extends StatefulWidget {
  const VaccinationTrackerScreen({super.key});

  @override
  State<VaccinationTrackerScreen> createState() => _VaccinationTrackerScreenState();
}

class _VaccinationTrackerScreenState extends State<VaccinationTrackerScreen> {
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 60));
  final Set<int> _completedDoses = {};

  static const List<VaccineDose> _schedule = [
    VaccineDose(
      titleBangla: 'জন্মের সময়: বিসিজি ও ওপিভি-০',
      titleEnglish: 'At Birth: BCG & OPV-0',
      diseaseCoveredBangla: 'যক্ষ্মা (টিবি) ও পোলিও প্রতিরোধে',
      diseaseCoveredEnglish: 'Tuberculosis (TB) and Polio prevention',
      dueDaysFromBirth: 0,
    ),
    VaccineDose(
      titleBangla: '৬ষ্ঠ সপ্তাহ: পেন্টা-১, পিসিভি-১, ওপিভি-১',
      titleEnglish: '6 Weeks: Penta-1, PCV-1, OPV-1',
      diseaseCoveredBangla: 'ডিপথেরিয়া, ধনুষ্টংকার, হুপিং কাশি, হেপাটাইটিস-বি, হিমোফাইলাস ও নিউমোনিয়া',
      diseaseCoveredEnglish: 'Diphtheria, Tetanus, Pertussis, Hep B, Hib, and Pneumonia',
      dueDaysFromBirth: 42,
    ),
    VaccineDose(
      titleBangla: '১০ম সপ্তাহ: পেন্টা-২, পিসিভি-২, ওপিভি-২',
      titleEnglish: '10 Weeks: Penta-2, PCV-2, OPV-2',
      diseaseCoveredBangla: 'ডিপথেরিয়া, হেপাটাইটিস-বি ও নিউমোকক্কাল দ্বিতীয় ডোজ',
      diseaseCoveredEnglish: 'Second dose of Pentavalent, PCV, and OPV',
      dueDaysFromBirth: 70,
    ),
    VaccineDose(
      titleBangla: '১৪তম সপ্তাহ: পেন্টা-৩, পিসিভি-৩, ওপিভি-৩, আইপিভি',
      titleEnglish: '14 Weeks: Penta-3, PCV-3, OPV-3, IPV',
      diseaseCoveredBangla: 'পেন্টা ও পিসিভি শেষ ডোজ এবং ইনজেকটেবল পোলিও ভ্যাকসিন',
      diseaseCoveredEnglish: 'Final Pentavalent, PCV, OPV, and Inactivated Polio Vaccine',
      dueDaysFromBirth: 98,
    ),
    VaccineDose(
      titleBangla: '৯ মাস পূর্ণ হলে: এমআর-১ (হাম ও রুবেলা)',
      titleEnglish: '9 Months: MR-1 (Measles & Rubella)',
      diseaseCoveredBangla: 'হাম ও রুবেলা প্রতিরোধে প্রথম ডোজ',
      diseaseCoveredEnglish: 'First dose for Measles and Rubella protection',
      dueDaysFromBirth: 270,
    ),
    VaccineDose(
      titleBangla: '১৫ মাস পূর্ণ হলে: এমআর-২',
      titleEnglish: '15 Months: MR-2',
      diseaseCoveredBangla: 'হাম ও রুবেলার দ্বিতীয় চূড়ান্ত বুস্টার ডোজ',
      diseaseCoveredEnglish: 'Final booster dose for Measles and Rubella',
      dueDaysFromBirth: 450,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('child_birth_date');
    if (savedDate != null) {
      _birthDate = DateTime.parse(savedDate);
    }
    final completedList = prefs.getStringList('completed_vaccines') ?? [];
    setState(() {
      _completedDoses.addAll(completedList.map((e) => int.parse(e)));
    });
  }

  Future<void> _toggleDose(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_completedDoses.contains(index)) {
        _completedDoses.remove(index);
      } else {
        _completedDoses.add(index);
      }
    });
    await prefs.setStringList('completed_vaccines', _completedDoses.map((e) => e.toString()).toList());
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('child_birth_date', picked.toIso8601String());
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageController.instance,
      builder: (context, _) {
        final isBangla = LanguageController.instance.isBangla;
        final strings = AppStrings(isBangla);
        final now = DateTime.now();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A6847),
            title: Text(
              strings.vaccineTrackerTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            elevation: 0,
            actions: const [
              LanguageToggleButton(),
              SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Birth date selector card
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.pink.shade50, shape: BoxShape.circle),
                      child: const Icon(Icons.child_care_rounded, color: Colors.pink, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.childBirthDateLabel,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                          ),
                          Text(
                            strings.formatDate(_birthDate),
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickBirthDate,
                      icon: const Icon(Icons.calendar_month_rounded, size: 18),
                      label: Text(strings.changeDateBtn),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0A6847),
                        side: const BorderSide(color: Color(0xFF0A6847)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),

              // Timetable List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: _schedule.length,
                  itemBuilder: (context, index) {
                    final dose = _schedule[index];
                    final dueDate = _birthDate.add(Duration(days: dose.dueDaysFromBirth));
                    final isDone = _completedDoses.contains(index);
                    final isOverdue = !isDone && dueDate.isBefore(now);

                    return Card(
                      elevation: 0.8,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDone
                              ? const Color(0xFFBBF7D0)
                              : isOverdue
                                  ? const Color(0xFFFECACA)
                                  : Colors.grey.shade200,
                        ),
                      ),
                      color: isDone ? const Color(0xFFF0FDF4) : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: isDone,
                              activeColor: const Color(0xFF0A6847),
                              onChanged: (_) => _toggleDose(index),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isBangla ? dose.titleBangla : dose.titleEnglish,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDone ? const Color(0xFF166534) : const Color(0xFF1E293B),
                                      decoration: isDone ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    isBangla ? dose.diseaseCoveredBangla : dose.diseaseCoveredEnglish,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.event_rounded, size: 14, color: isOverdue ? Colors.red : const Color(0xFF0A6847)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${strings.dueDateLabel} ${strings.formatDate(dueDate)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isOverdue ? Colors.red.shade700 : const Color(0xFF0A6847),
                                        ),
                                      ),
                                      if (isOverdue) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
                                          child: Text(
                                            strings.overdueTag,
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
