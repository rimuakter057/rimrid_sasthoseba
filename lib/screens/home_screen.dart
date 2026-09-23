import 'dart:async';
import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import '../models/medicine.dart';
import '../services/database_helper.dart';
import 'medicine_detail_sheet.dart';
import 'prescription_scan_screen.dart';
import 'medicine_reminder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Medicine> _medicines = [];
  bool _isLoading = false;
  bool _isInitializingDb = false;
  double _initProgress = 0.0;
  String _initStatus = '';
  int _totalMedicineCount = 0;
  Timer? _debounce;

  // Quick search suggestions popular in Bangladesh
  final List<String> _popularSearches = const [
    'Napa',
    'Ace',
    'Seclo',
    'Monas',
    'Sergel',
    'Paracetamol',
    'Omeprazole',
    'Ceevit',
    'Alatrol',
    'Azithromycin',
  ];

  @override
  void initState() {
    super.initState();
    _checkAndInitDatabase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Checks if SQLite is already populated; if not, loads from CSV assets
  Future<void> _checkAndInitDatabase() async {
    setState(() {
      _isLoading = true;
    });

    final isPopulated = await _dbHelper.isDatabasePopulated();

    if (!isPopulated) {
      setState(() {
        _isInitializingDb = true;
      });

      await _dbHelper.populateDatabaseFromCsv(
        onProgress: (progress, status) {
          setState(() {
            _initProgress = progress;
            _initStatus = status;
          });
        },
      );

      setState(() {
        _isInitializingDb = false;
      });
    }

    _totalMedicineCount = await _dbHelper.getMedicineCount();
    await _performSearch('');
  }

  /// Debounced search
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _performSearch(query);
    });
  }

  /// Search offline SQLite database
  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    final results = await _dbHelper.searchMedicineDetails(query);

    setState(() {
      _medicines = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageController.instance,
      builder: (context, _) {
        final isBangla = LanguageController.instance.isBangla;
        final strings = AppStrings(isBangla);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFF0A6847),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.appTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        strings.appSubtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFD1FAE5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Medicine Reminder Alarm Shortcut
              IconButton(
                icon: const Icon(Icons.alarm_on_rounded, color: Colors.white, size: 22),
                tooltip: strings.medicineReminderTooltip,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MedicineReminderScreen(),
                    ),
                  );
                },
              ),

              // Language Switcher Toggle Button (বাং / EN)
              const Center(child: LanguageToggleButton()),
              const SizedBox(width: 14),
            ],
          ),
          body: _isInitializingDb
              ? _buildDatabaseInitView(strings)
              : _buildMainContentView(strings),
          floatingActionButton: _isInitializingDb
              ? null
              : FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrescriptionScanScreen(),
                      ),
                    );
                  },
                  backgroundColor: const Color(0xFF0A6847),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  icon: const Icon(Icons.document_scanner_rounded, size: 20),
                  label: Text(
                    strings.scanPrescriptionButton,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
        );
      },
    );
  }

  /// Initial database loading screen with real-time progress
  Widget _buildDatabaseInitView(AppStrings strings) {
    final percent = (_initProgress * 100).toInt();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_information_rounded,
                size: 64,
                color: Color(0xFF0A6847),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              strings.dbInitTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _initStatus.isNotEmpty ? _initStatus : strings.dbInitDefaultStatus,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _initProgress > 0 ? _initProgress : null,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0A6847)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              strings.percentCompleted(percent),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A6847),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFB45309), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.dbInitNote,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Main search and list view
  Widget _buildMainContentView(AppStrings strings) {
    return Column(
      children: [
        // Top search bar container
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input Field
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: strings.searchHint,
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.normal,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF0A6847),
                    size: 26,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF0A6847), width: 1.8),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Quick Filter / Popular Search Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    Text(
                      strings.popularLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    ..._popularSearches.map((term) {
                      final isSelected = _searchController.text.trim().toLowerCase() == term.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () {
                            _searchController.text = term;
                            _performSearch(term);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0A6847) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF0A6847) : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              term,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Results Status Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _searchController.text.trim().isEmpty
                    ? strings.recentPopularTitle
                    : strings.searchResultsCount(_medicines.length),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              if (_totalMedicineCount > 0)
                Text(
                  strings.totalMedicines(_totalMedicineCount),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
            ],
          ),
        ),

        // List View of Medicines
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0A6847),
                  ),
                )
              : _medicines.isEmpty
                  ? _buildEmptyState(strings)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                      itemCount: _medicines.length,
                      itemBuilder: (context, index) {
                        final med = _medicines[index];
                        return _buildMedicineCard(med, strings);
                      },
                    ),
        ),
      ],
    );
  }

  /// Medicine card formatted for elderly readability with clear labels
  Widget _buildMedicineCard(Medicine med, AppStrings strings) {
    return Card(
      elevation: 0.8,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => MedicineDetailSheet.show(context, med),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Brand name, Dosage Form Badge, Strength
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForDosageForm(med.dosageForm),
                      color: const Color(0xFF0A6847),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med.brandName,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (med.dosageForm.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  med.dosageForm,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                            if (med.strength.isNotEmpty)
                              Text(
                                med.strength,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A6847),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Generic Row
              _buildInfoRow(
                icon: Icons.science_outlined,
                iconColor: Colors.teal.shade700,
                label: strings.genericLabel,
                value: med.generic.isNotEmpty ? med.generic : strings.noData,
                isValueBold: true,
              ),
              const SizedBox(height: 6),

              // Manufacturer Row
              _buildInfoRow(
                icon: Icons.domain_outlined,
                iconColor: Colors.indigo.shade600,
                label: strings.companyLabel,
                value: med.manufacturer.isNotEmpty ? med.manufacturer : strings.noData,
              ),

              // Dosage preview (খাওয়ার নিয়ম)
              if (med.dosage.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDCFCE7)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: Color(0xFF0A6847),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${strings.dosagePreviewLabel} ${_truncateText(med.dosage, 70)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Side effects preview (পার্শ্বপ্রতিক্রিয়া)
              if (med.sideEffects.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFEDD5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFEA580C),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${strings.sideEffectsPreviewLabel} ${_truncateText(med.sideEffects, 65)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9A3412),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool isValueBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppStrings strings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              strings.notFoundTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.notFoundSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForDosageForm(String form) {
    final lower = form.toLowerCase();
    if (lower.contains('syrup') || lower.contains('suspension') || lower.contains('drop')) {
      return Icons.water_drop_rounded;
    } else if (lower.contains('injection') || lower.contains('infusion')) {
      return Icons.vaccines_rounded;
    } else if (lower.contains('capsule')) {
      return Icons.medication_liquid_rounded;
    } else if (lower.contains('inhaler')) {
      return Icons.air_rounded;
    }
    return Icons.medication_rounded;
  }

  String _truncateText(String text, int maxLength) {
    final clean = text.replaceAll('\n', ' ').trim();
    if (clean.length <= maxLength) return clean;
    return '${clean.substring(0, maxLength)}...';
  }
}
