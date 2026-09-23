import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import '../models/medicine.dart';
import '../services/database_helper.dart';
import '../services/interaction_service.dart';

class InteractionCheckerScreen extends StatefulWidget {
  const InteractionCheckerScreen({super.key});

  @override
  State<InteractionCheckerScreen> createState() => _InteractionCheckerScreenState();
}

class _InteractionCheckerScreenState extends State<InteractionCheckerScreen> {
  final List<Medicine> _selectedMedicines = [];
  final TextEditingController _searchController = TextEditingController();
  List<Medicine> _searchResults = [];
  bool _isMultiTokenSearch = false;

  final List<String> _quickSuggestions = const [
    'Napa',
    'Seclo',
    'Histacin',
    'Aspirin',
    'Monas',
    'Ceevit',
    'Alatrol',
    'Clopidogrel',
  ];

  Future<void> _onSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) {
      setState(() {
        _searchResults = [];
        _isMultiTokenSearch = false;
      });
      return;
    }

    // Check if user entered multiple medicines with comma or plus (e.g. saclo, napa, histasin)
    if (clean.contains(',') || clean.contains(';') || clean.contains('+')) {
      final tokens = clean
          .split(RegExp(r'[,;+]'))
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final List<Medicine> combined = [];
      for (final token in tokens) {
        final matches = await DatabaseHelper.instance.searchMedicineDetails(token, limit: 3);
        for (final m in matches) {
          if (!combined.any((item) => item.brandName == m.brandName && item.generic == m.generic)) {
            combined.add(m);
          }
        }
      }

      setState(() {
        _searchResults = combined;
        _isMultiTokenSearch = true;
      });
    } else {
      // Single token search with spelling variation fallback
      final results = await DatabaseHelper.instance.searchMedicineDetails(clean, limit: 12);
      setState(() {
        _searchResults = results;
        _isMultiTokenSearch = false;
      });
    }
  }

  void _addMedicine(Medicine med) {
    if (_selectedMedicines.any((m) => m.id == med.id || (m.brandName == med.brandName && m.generic == med.generic))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${med.brandName} ইতিমধ্যে তালিকায় যোগ করা আছে')),
      );
      return;
    }
    setState(() {
      _selectedMedicines.add(med);
      _searchController.clear();
      _searchResults = [];
      _isMultiTokenSearch = false;
    });
  }

  void _addAllSearchResults() {
    int addedCount = 0;
    setState(() {
      for (final med in _searchResults) {
        if (!_selectedMedicines.any((m) => m.brandName == med.brandName && m.generic == med.generic)) {
          _selectedMedicines.add(med);
          addedCount++;
        }
      }
      _searchController.clear();
      _searchResults = [];
      _isMultiTokenSearch = false;
    });

    if (addedCount > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$addedCount টি ওষুধ তালিকায় যোগ করা হয়েছে')),
      );
    }
  }

  void _removeMedicine(int index) {
    setState(() {
      _selectedMedicines.removeAt(index);
    });
  }

  Future<void> _addFromQuickSuggestion(String name) async {
    final matches = await DatabaseHelper.instance.searchMedicineDetails(name, limit: 1);
    if (matches.isNotEmpty) {
      _addMedicine(matches.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageController.instance,
      builder: (context, _) {
        final isBangla = LanguageController.instance.isBangla;
        final alerts = InteractionService.instance.analyzeInteractions(_selectedMedicines);
        final hasQuery = _searchController.text.trim().isNotEmpty;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A6847),
            title: Text(
              isBangla ? 'ড্রাগ ইন্টারঅ্যাকশন চেকার' : 'Drug Interaction Checker',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            elevation: 0,
            actions: [
              if (_selectedMedicines.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: isBangla ? 'সব মুছুন' : 'Clear all',
                  onPressed: () => setState(() => _selectedMedicines.clear()),
                ),
            ],
          ),
          body: Column(
            children: [
              // Search & Input Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBangla
                          ? 'একসাথে খাওয়ার ওষুধগুলো সার্চ করে যোগ করুন:'
                          : 'Search and add medicines you take together:',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 10),
                    // Search Text Field
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearch,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: isBangla
                            ? 'ওষুধের নাম লিখুন (যেমন: Napa, Seclo, Histacin)...'
                            : 'Type medicine name (e.g. Napa, Seclo)...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.normal),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0A6847)),
                        suffixIcon: hasQuery
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearch('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF0A6847), width: 1.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Quick Suggestion Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            isBangla ? 'দ্রুত যোগ করুন: ' : 'Quick add: ',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                          ..._quickSuggestions.map((name) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                label: Text('+ $name', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0A6847))),
                                backgroundColor: const Color(0xFFE8F5E9),
                                side: BorderSide(color: Colors.green.shade200),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                onPressed: () => _addFromQuickSuggestion(name),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Search Results Dropdown List
              if (hasQuery && _searchResults.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  color: Colors.white,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isMultiTokenSearch)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: const Color(0xFFF0FDF4),
                          child: Row(
                            children: [
                              Text(
                                '${_searchResults.length}টি ওষুধ পাওয়া গেছে',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: _addAllSearchResults,
                                icon: const Icon(Icons.done_all_rounded, size: 16),
                                label: const Text('সবগুলো যোগ করুন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: TextButton.styleFrom(foregroundColor: const Color(0xFF0A6847)),
                              ),
                            ],
                          ),
                        ),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final med = _searchResults[index];
                            final isAlreadyAdded = _selectedMedicines.any((m) => m.brandName == med.brandName && m.generic == med.generic);

                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.medication_rounded, color: Color(0xFF0A6847), size: 20),
                              ),
                              title: Text(med.displayNameWithStrength, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text('${med.generic} • ${med.manufacturer}', style: const TextStyle(fontSize: 11)),
                              trailing: isAlreadyAdded
                                  ? const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20)
                                  : ElevatedButton.icon(
                                      onPressed: () => _addMedicine(med),
                                      icon: const Icon(Icons.add, size: 16),
                                      label: Text(isBangla ? 'যোগ' : 'Add'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0A6847),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              // If searched but 0 results found
              if (hasQuery && _searchResults.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.amber.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.search_off_rounded, color: Colors.amber.shade800, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isBangla
                              ? '"${_searchController.text}" পাওয়া যায়নি। বানান সঠিক আছে কিনা দেখুন (যেমন: saclo এর বদলে seclo লিখুন) অথবা কমা ছাড়া একটি একটি করে লিখুন।'
                              : 'No medicines matched "${_searchController.text}". Check the spelling.',
                          style: TextStyle(fontSize: 12, color: Colors.amber.shade900, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),

              // Selected Medicines Tray
              if (_selectedMedicines.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: const Color(0xFFF1F5F9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'নির্বাচিত ওষুধ (${_selectedMedicines.length} টি):',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _selectedMedicines.clear()),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                            child: const Text('সব মুছুন', style: TextStyle(fontSize: 12, color: Colors.red)),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_selectedMedicines.length, (index) {
                          final med = _selectedMedicines[index];
                          final classes = InteractionService.instance.identifyClasses(med);
                          final classBadge = classes.isNotEmpty && classes.first != DrugClass.unknown
                              ? InteractionService.instance.getDrugClassLabel(classes.first, isBangla)
                              : (med.generic.isNotEmpty ? med.generic : '');

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.medication_liquid_rounded, size: 16, color: Color(0xFF0A6847)),
                                const SizedBox(width: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      med.displayNameWithStrength,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                                    ),
                                    if (classBadge.isNotEmpty)
                                      Text(
                                        classBadge,
                                        style: TextStyle(fontSize: 10, color: Colors.blueGrey.shade600, fontWeight: FontWeight.w500),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => _removeMedicine(index),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2),
                                    child: Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

              // Interaction Report Area
              Expanded(
                child: _selectedMedicines.isEmpty
                    ? _buildEmptyState(isBangla)
                    : _selectedMedicines.length == 1
                        ? _buildAddAnotherHint(isBangla)
                        : alerts.isEmpty
                            ? _buildSafeState(isBangla)
                            : _buildAlertsList(alerts, isBangla),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isBangla) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
              child: const Icon(Icons.compare_arrows_rounded, size: 56, color: Color(0xFF2563EB)),
            ),
            const SizedBox(height: 20),
            Text(
              isBangla ? 'ড্রাগ ইন্টারঅ্যাকশন পরীক্ষা করুন' : 'Check Drug Interactions',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              isBangla
                  ? 'আপনি যে ওষুধগুলো একসাথে খান, সেগুলো উপরের সার্চবারে একটি একটি করে অথবা কমা (,) দিয়ে লিখে যোগ করুন। কোনো ক্ষতিকর বিক্রিয়া আছে কিনা তা আমরা পরীক্ষা করে দেব।'
                  : 'Add two or more medicines to check if they interact with each other safely or have harmful conflicts.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAnotherHint(bool isBangla) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline_rounded, size: 48, color: Colors.amber),
            const SizedBox(height: 14),
            Text(
              isBangla ? 'আরও অন্তত ১টি ওষুধ যোগ করুন' : 'Add at least one more medicine',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 6),
            Text(
              isBangla
                  ? 'ইন্টারঅ্যাকশন বা বিক্রিয়া পরীক্ষা করতে কমপক্ষে ২টি ওষুধের প্রয়োজন হয়।'
                  : 'At least 2 medications are required to analyze mutual drug interactions.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeState(bool isBangla) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Column(
            children: [
              const Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 46),
              const SizedBox(height: 10),
              Text(
                isBangla ? 'কোনো পরিচিত মারাত্মক সংঘাত পাওয়া যায়নি' : 'No Known Severe Conflicts Detected',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isBangla
                    ? 'আমাদের ডাটাবেজের ২২+ টি প্রধান ক্লিনিক্যাল ক্লাস ও জেনেরিকের মেডিকেল নিয়মের ভিত্তিতে আপনার নির্বাচিত ${_selectedMedicines.length}টি ওষুধের মধ্যে কোনো পরিচিত মারাত্মক বিক্রিয়া বা দ্বন্দ্ব নেই।'
                    : 'Based on 22+ primary clinical classes and drug interaction rules, no known critical conflicts were found among your selected ${_selectedMedicines.length} medicines.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF166534), height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Medical Safety Disclaimer Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.health_and_safety_outlined, color: Color(0xFFB45309), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBangla ? 'মেডিকেল সতর্কতা ও পরামর্শ' : 'Medical Safety Note',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBangla
                          ? 'এই অ্যাপটি একটি বৈজ্ঞানিক সহায়ক নির্দেশিকা এবং কখনোই ডাক্তারের সরাসরি পরামর্শের বিকল্প নয়। প্রতিটি মানুষের বয়স, কিডনি বা লিভারের অবস্থা অনুযায়ী ওষুধের প্রভাব ভিন্ন হতে পারে। নতুন কোনো ওষুধ শুরু করার আগে সর্বদা চিকিৎসকের প্রেসক্রিপশন মেনে চলুন।'
                          : 'This tool is a clinical guide and does not substitute a licensed physician. Individual tolerance varies based on age, renal, and liver conditions. Always follow your doctor\'s prescription.',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF78350F), height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsList(List<InteractionAlert> alerts, bool isBangla) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        final isSevere = alert.risk == InteractionRisk.severe;
        final bg = isSevere ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB);
        final border = isSevere ? const Color(0xFFFECACA) : const Color(0xFFFDE68A);
        final titleColor = isSevere ? const Color(0xFFB91C1C) : const Color(0xFFB45309);

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: border, width: 1.2),
          ),
          color: bg,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Medicines conflicting
                Row(
                  children: [
                    Icon(
                      isSevere ? Icons.warning_rounded : Icons.info_outline_rounded,
                      color: titleColor,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isBangla ? alert.titleBangla : alert.titleEnglish,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: titleColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Medicines involved pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: border),
                  ),
                  child: Text(
                    '⚠️ ${alert.med1.displayNameWithStrength}  ✖  ${alert.med2.displayNameWithStrength}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                  ),
                ),
                const SizedBox(height: 12),

                // Explanation
                Text(
                  isBangla ? alert.explanationBangla : alert.explanationEnglish,
                  style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 10),

                // Management / Solution
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSevere ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, size: 18, color: titleColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isBangla ? alert.managementBangla : alert.managementEnglish,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: titleColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
