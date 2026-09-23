import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/lab_tests_data.dart';
import '../localization/app_strings.dart';
import '../services/lab_report_parser_service.dart';

class LabReportScreen extends StatefulWidget {
  const LabReportScreen({super.key});

  @override
  State<LabReportScreen> createState() => _LabReportScreenState();
}

class _LabReportScreenState extends State<LabReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  final LabReportParserService _parserService = LabReportParserService.instance;

  // Scanner state
  File? _selectedImage;
  bool _isScanning = false;
  LabReportParseResult? _scanResult;

  // Manual Explorer state
  late LabTestDefinition _selectedTest;
  final TextEditingController _manualValController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'সব';
  List<LabTestDefinition> _filteredTests = [];

  final List<String> _categories = const [
    'সব',
    'রক্ত পরীক্ষা (CBC)',
    'কিডনি পরীক্ষা (KFT)',
    'লিভার পরীক্ষা (LFT)',
    'ডায়াবেটিস পরীক্ষা',
    'কোলেস্টেরল ও লিপিড',
    'থাইরয়েড পরীক্ষা',
    'ইলেক্ট্রোলাইট ও মিনারেল',
    'ইউরিন পরীক্ষা (R/E)',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedTest = LabTestsData.tests.first;
    _manualValController.text = _selectedTest.defaultInputValue.toString();
    _filteredTests = List.from(LabTestsData.tests);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _manualValController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      final q = query.trim().toLowerCase();
      _filteredTests = LabTestsData.tests.where((test) {
        final matchesCategory = _selectedCategory == 'সব' || test.categoryBangla == _selectedCategory;
        if (!matchesCategory) return false;
        if (q.isEmpty) return true;
        return test.nameBangla.toLowerCase().contains(q) ||
            test.nameEnglish.toLowerCase().contains(q) ||
            test.ocrAliases.any((a) => a.toLowerCase().contains(q));
      }).toList();
    });
  }

  void _onSelectCategory(String cat) {
    setState(() {
      _selectedCategory = cat;
      _onSearchChanged(_searchController.text);
    });
  }

  void _onSelectManualTest(LabTestDefinition test) {
    setState(() {
      _selectedTest = test;
      _manualValController.text = test.defaultInputValue.toString();
    });
  }

  Future<void> _pickAndScanReport(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 92,
      );

      if (picked == null) return;

      setState(() {
        _selectedImage = File(picked.path);
        _isScanning = true;
        _scanResult = null;
      });

      final rawText = await _parserService.extractTextFromImage(_selectedImage!);
      final result = _parserService.parseReportFromText(rawText);

      setState(() {
        _scanResult = result;
        _isScanning = false;
      });
    } catch (e) {
      setState(() => _isScanning = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('রিপোর্ট স্ক্যানে সমস্যা হয়েছে: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _loadSampleReport() {
    const samplePopularReport = '''
POPULAR DIAGNOSTIC CENTRE LTD.
DHAKA, BANGLADESH
HAEMATOLOGY & CLINICAL BIOCHEMISTRY REPORT
---------------------------------------------------------------
TEST NAME                         RESULT    UNIT      NORMAL RANGE
Total Platelet Count (PLT)        75,000    /uL       (150,000 - 450,000)
Hemoglobin (Hb)                   8.4       g/dL      (12.0 - 16.5)
Total Leucocyte Count (WBC)       14,500    /uL       (4,000 - 11,000)
Serum Creatinine                  1.9       mg/dL     (0.6 - 1.2)
S. Bilirubin (Total)              2.4       mg/dL     (0.2 - 1.2)
SGPT (ALT)                        68        U/L       (Up to 40)
HbA1c                             8.4       %         (4.0 - 5.6)
Fasting Blood Sugar (FBS)         8.2       mmol/L    (3.9 - 6.1)
Serum Uric Acid                   8.5       mg/dL     (3.4 - 7.0)
Total Cholesterol                 238       mg/dL     (< 200)
TSH                               6.5       uIU/mL    (0.4 - 4.2)
---------------------------------------------------------------
''';

    setState(() {
      _selectedImage = null;
      _isScanning = true;
      _scanResult = null;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      final result = _parserService.parseReportFromText(samplePopularReport);
      setState(() {
        _scanResult = result;
        _isScanning = false;
      });
    });
  }

  void _showEditValueDialog(ScannedLabTestItem item, bool isBangla) {
    final editController = TextEditingController(text: item.detectedValue.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isBangla ? 'টেস্টের মান সংশোধন করুন' : 'Edit Test Value',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBangla ? item.definition.nameBangla : item.definition.nameEnglish,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0A6847)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: editController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                suffixText: item.definition.unit,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isBangla ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A6847),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final newVal = double.tryParse(editController.text.trim());
              if (newVal != null && _scanResult != null) {
                final updatedItems = _scanResult!.matchedItems.map((curr) {
                  if (curr.definition.id == item.definition.id) {
                    return ScannedLabTestItem(
                      definition: curr.definition,
                      detectedValue: newVal,
                      rawMatchedText: curr.rawMatchedText,
                      evaluation: curr.definition.evaluate(newVal),
                    );
                  }
                  return curr;
                }).toList();

                int normalCount = 0;
                int borderlineCount = 0;
                int criticalCount = 0;
                for (final itm in updatedItems) {
                  if (itm.evaluation.status == LabStatus.normal) normalCount++;
                  if (itm.evaluation.status == LabStatus.borderline) borderlineCount++;
                  if (itm.evaluation.status == LabStatus.critical) criticalCount++;
                }

                setState(() {
                  _scanResult = LabReportParseResult(
                    fullOcrText: _scanResult!.fullOcrText,
                    matchedItems: updatedItems,
                    normalCount: normalCount,
                    borderlineCount: borderlineCount,
                    criticalCount: criticalCount,
                    overallSummaryBangla: _scanResult!.overallSummaryBangla,
                    overallSummaryEnglish: _scanResult!.overallSummaryEnglish,
                  );
                });
              }
              Navigator.pop(ctx);
            },
            child: Text(isBangla ? 'সংরক্ষণ ও পুনঃবিশ্লেষণ' : 'Save & Re-evaluate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageController.instance,
      builder: (context, _) {
        final isBangla = LanguageController.instance.isBangla;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A6847),
            title: Text(
              isBangla ? 'ল্যাব টেস্ট ও রিপোর্ট অ্যানালাইজার' : 'Lab Test & Report Analyzer',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(
                  icon: const Icon(Icons.document_scanner_rounded, size: 20),
                  text: isBangla ? 'কাগজের রিপোর্ট স্ক্যান' : 'Scan Lab Report',
                ),
                Tab(
                  icon: const Icon(Icons.biotech_rounded, size: 20),
                  text: isBangla ? 'টেস্ট ডিরেক্টরি (২০+)' : 'Test Directory (20+)',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: OCR Scanner
              _buildScannerTab(isBangla),
              // TAB 2: 20+ Tests Manual Directory & Calculator
              _buildManualDirectoryTab(isBangla),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 1: OCR REPORT SCANNER
  // ==========================================
  Widget _buildScannerTab(bool isBangla) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A6847), Color(0xFF138D63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A6847).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.camera_enhance_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBangla ? 'ল্যাব রিপোর্টের ছবি স্ক্যান করুন' : 'Scan Paper Lab Report',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isBangla
                                ? 'পপুলার, ইবনে সিনা বা যেকোনো ডায়াগনস্টিক সেন্টারের রিপোর্ট সহজে বুঝুন'
                                : 'Instantly decode reports from Popular, Ibn Sina, or any diagnostic center',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0A6847),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: () => _pickAndScanReport(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_rounded, size: 18),
                        label: Text(
                          isBangla ? 'ক্যামেরা' : 'Camera',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Colors.white54),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => _pickAndScanReport(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_rounded, size: 18),
                        label: Text(
                          isBangla ? 'গ্যালারি' : 'Gallery',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton.icon(
                    onPressed: _loadSampleReport,
                    icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 16),
                    label: Text(
                      isBangla ? 'নমুনা রিপোর্ট দিয়ে পরীক্ষা করুন' : 'Test with Sample Lab Report',
                      style: const TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // SCANNING PROGRESS STATE
          if (_isScanning)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      color: Color(0xFF0A6847),
                      strokeWidth: 3.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    isBangla ? 'রিপোর্টটি স্ক্যান ও বিশ্লেষণ করা হচ্ছে...' : 'Scanning & analyzing report...',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isBangla
                        ? 'হিমোগ্লোবিন, প্লাটিলেট, ক্রিয়েটিনিন, সুগার ইত্যাদি মান খোঁজা হচ্ছে...'
                        : 'Detecting Hemoglobin, Platelets, Creatinine, Sugar...',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          // SCAN RESULTS
          else if (_scanResult != null)
            _buildScanResultSection(_scanResult!, isBangla)
          // EMPTY INSTRUCTION STATE
          else
            _buildEmptyInstructionState(isBangla),
        ],
      ),
    );
  }

  Widget _buildEmptyInstructionState(bool isBangla) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.document_scanner_outlined, size: 40, color: Color(0xFF0A6847)),
          ),
          const SizedBox(height: 16),
          Text(
            isBangla ? 'কাগজের ল্যাব রিপোর্ট সহজে যাচাই করুন' : 'Understand Diagnostic Reports with Ease',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            isBangla
                ? '১. উপরের ক্যামেরা বা গ্যালারি বোতামে চাপ দিয়ে ল্যাব টেস্ট রিপোর্টের ছবি তুলুন।\n'
                  '২. অ্যাপটি নিজে থেকেই সিবিসি, রক্তে সুগার, কিডনি ও লিভারের টেস্ট চিহ্নিত করবে।\n'
                  '৩. কোনটি স্বাভাবিক, কোনটি বিপদসীমার মধ্যে তা পরিষ্কার বাংলায় দেখতে পাবেন।'
                : '1. Tap Camera or Gallery to upload your paper lab report.\n'
                  '2. The app automatically extracts CBC, blood sugar, kidney, and liver parameters.\n'
                  '3. View actionable health assessment in clear, everyday language.',
            style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF475569)),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0A6847),
              side: const BorderSide(color: Color(0xFF0A6847)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _loadSampleReport,
            icon: const Icon(Icons.science_outlined, size: 18),
            label: Text(isBangla ? 'নমুনা রিপোর্ট চালিয়ে দেখুন' : 'Try Demo Report Analysis'),
          ),
        ],
      ),
    );
  }

  Widget _buildScanResultSection(LabReportParseResult result, bool isBangla) {
    final hasCritical = result.criticalCount > 0;
    final hasBorderline = result.borderlineCount > 0;

    Color bannerBg = const Color(0xFFF0FDF4);
    Color bannerBorder = const Color(0xFFBBF7D0);
    Color bannerColor = const Color(0xFF16A34A);
    IconData bannerIcon = Icons.check_circle_rounded;

    if (hasCritical) {
      bannerBg = const Color(0xFFFEF2F2);
      bannerBorder = const Color(0xFFFECACA);
      bannerColor = const Color(0xFFDC2626);
      bannerIcon = Icons.warning_rounded;
    } else if (hasBorderline) {
      bannerBg = const Color(0xFFFFFBEB);
      bannerBorder = const Color(0xFFFDE68A);
      bannerColor = const Color(0xFFD97706);
      bannerIcon = Icons.info_rounded;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scorecard Counts Row
        Row(
          children: [
            Expanded(
              child: _buildScorecardItem(
                count: result.normalCount,
                label: isBangla ? 'স্বাভাবিক' : 'Normal',
                color: const Color(0xFF16A34A),
                bgColor: const Color(0xFFF0FDF4),
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildScorecardItem(
                count: result.borderlineCount,
                label: isBangla ? 'সতর্কতা' : 'Borderline',
                color: const Color(0xFFD97706),
                bgColor: const Color(0xFFFFFBEB),
                icon: Icons.info_outline,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildScorecardItem(
                count: result.criticalCount,
                label: isBangla ? 'বিপদসীমা' : 'Critical',
                color: const Color(0xFFDC2626),
                bgColor: const Color(0xFFFEF2F2),
                icon: Icons.error_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Overall Advice Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bannerBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: bannerBorder, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(bannerIcon, color: bannerColor, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBangla ? 'সামগ্রিক মূল্যায়ন' : 'Overall Assessment',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: bannerColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBangla ? result.overallSummaryBangla : result.overallSummaryEnglish,
                      style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Matched Items List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isBangla
                  ? 'শনাক্ত হওয়া টেস্টসমূহ (${result.matchedItems.length}টি):'
                  : 'Detected Lab Tests (${result.matchedItems.length}):',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            Text(
              isBangla ? 'মান পরিবর্তন করতে ট্যাপ করুন' : 'Tap to edit value',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (result.matchedItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Text(
                isBangla
                    ? 'ছবি থেকে কোনো পরিচিত টেস্টের মান পড়া সম্ভব হয়নি। অনুগ্রহ করে স্পষ্ট আলোতে সোজা ছবি তুলুন অথবা পাশের ট্যাব থেকে টেস্টটি সরাসরি বেছে নিন।'
                    : 'Could not extract clinical parameters. Please re-take in good lighting or use the Manual Directory tab.',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...result.matchedItems.map((item) => _buildScannedItemCard(item, isBangla)),

        const SizedBox(height: 16),

        // Raw OCR Text Viewer (Collapsible)
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(
            isBangla ? 'রিপোর্টের কাঁচা টেক্সট দেখুন (OCR Raw Data)' : 'View Raw OCR Text',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.fullOcrText,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFF334155)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildScorecardItem({
    required int count,
    required String label,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedItemCard(ScannedLabTestItem item, bool isBangla) {
    Color cardBorder = const Color(0xFFBBF7D0);
    Color statusColor = const Color(0xFF16A34A);
    Color statusBg = const Color(0xFFF0FDF4);
    IconData statusIcon = Icons.check_circle_rounded;

    if (item.evaluation.status == LabStatus.borderline) {
      cardBorder = const Color(0xFFFDE68A);
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFFFBEB);
      statusIcon = Icons.info_rounded;
    } else if (item.evaluation.status == LabStatus.critical) {
      cardBorder = const Color(0xFFFECACA);
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEF2F2);
      statusIcon = Icons.warning_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showEditValueDialog(item, isBangla),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Test Name + Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBangla ? item.definition.nameBangla : item.definition.nameEnglish,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          item.definition.categoryBangla,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          isBangla ? item.evaluation.statusTitleBangla : item.evaluation.statusTitleEnglish,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Value & Reference Comparison Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(
                          isBangla ? 'প্রাপ্ত মান: ' : 'Found: ',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        Text(
                          '${item.detectedValue} ${item.definition.unit}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isBangla
                          ? 'স্বাভাবিক: ${item.definition.minNormal}-${item.definition.maxNormal} ${item.definition.unit}'
                          : 'Normal: ${item.definition.minNormal}-${item.definition.maxNormal} ${item.definition.unit}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Clinical Message
              Text(
                isBangla ? item.evaluation.messageBangla : item.evaluation.messageEnglish,
                style: const TextStyle(fontSize: 12.5, height: 1.4, color: Color(0xFF334155), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              // Medical Advice
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.medical_services_outlined, size: 16, color: Color(0xFF0A6847)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isBangla ? item.evaluation.adviceBangla : item.evaluation.adviceEnglish,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: MANUAL 20+ TESTS DIRECTORY & CALCULATOR
  // ==========================================
  Widget _buildManualDirectoryTab(bool isBangla) {
    final double inputVal = double.tryParse(_manualValController.text.trim()) ?? _selectedTest.defaultInputValue;
    final result = _selectedTest.evaluate(inputVal);

    Color statusColor = const Color(0xFF16A34A);
    Color statusBg = const Color(0xFFF0FDF4);
    Color statusBorder = const Color(0xFFBBF7D0);
    IconData statusIcon = Icons.check_circle_rounded;

    if (result.status == LabStatus.borderline) {
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFFFBEB);
      statusBorder = const Color(0xFFFDE68A);
      statusIcon = Icons.info_rounded;
    } else if (result.status == LabStatus.critical) {
      statusColor = const Color(0xFFDC2626);
      statusBg = const Color(0xFFFEF2F2);
      statusBorder = const Color(0xFFFECACA);
      statusIcon = Icons.warning_rounded;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: isBangla
                  ? 'টেস্ট খুঁজুন (যেমন: হিমোগ্লোবিন, প্লাটিলেট, ক্রিয়েটিনিন, SGPT)...'
                  : 'Search test (e.g. Hemoglobin, Platelet, Creatinine, SGPT)...',
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0A6847)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0A6847), width: 1.5)),
            ),
          ),
          const SizedBox(height: 12),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF0A6847),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF0A6847),
                    backgroundColor: const Color(0xFFE8F5E9),
                    checkmarkColor: Colors.white,
                    side: BorderSide(color: isSelected ? const Color(0xFF0A6847) : Colors.green.shade200),
                    onSelected: (_) => _onSelectCategory(cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Test Selection Carousel / Chips
          Text(
            isBangla ? 'যে টেস্ট পরীক্ষা করতে চান নির্বাচন করুন:' : 'Select Diagnostic Parameter:',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),

          if (_filteredTests.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Text(
                isBangla ? 'কোনো টেস্ট পাওয়া যায়নি' : 'No matching tests found',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filteredTests.map((test) {
                  final isSelected = test.id == _selectedTest.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        isBangla ? test.nameBangla : test.nameEnglish,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isSelected ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0A6847),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: isSelected ? const Color(0xFF0A6847) : Colors.grey.shade300),
                      onSelected: (_) => _onSelectManualTest(test),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 18),

          // Selected Test Input & Config Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.biotech_rounded, color: Color(0xFF0A6847), size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBangla ? _selectedTest.nameBangla : _selectedTest.nameEnglish,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          Text(
                            _selectedTest.categoryBangla,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedTest.descriptionBangla,
                  style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF475569)),
                ),
                const Divider(height: 24),

                // Reference normal range badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.straighten_rounded, size: 16, color: Color(0xFF475569)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isBangla
                              ? 'স্বাভাবিক মাত্রা (Normal Range): ${_selectedTest.minNormal} - ${_selectedTest.maxNormal} ${_selectedTest.unit}'
                              : 'Reference Normal: ${_selectedTest.minNormal} - ${_selectedTest.maxNormal} ${_selectedTest.unit}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Input Box for Reading
                Text(
                  isBangla ? 'রিপোর্টের প্রাপ্ত ফলাফল লিখুন:' : 'Enter report reading:',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualValController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A6847)),
                        decoration: InputDecoration(
                          suffixText: _selectedTest.unit,
                          suffixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0A6847), width: 2)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Quick preset buttons to see normal, borderline, and critical levels
                Text(
                  isBangla ? 'দ্রুত বিভিন্ন মাত্রা যাচাই করে দেখুন:' : 'Quick preset demonstrations:',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    ActionChip(
                      backgroundColor: const Color(0xFFF0FDF4),
                      side: const BorderSide(color: Color(0xFFBBF7D0)),
                      label: Text(
                        isBangla ? '🟢 স্বাভাবিক নমুনা' : '🟢 Normal Example',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                      ),
                      onPressed: () {
                        setState(() {
                          _manualValController.text = _selectedTest.defaultInputValue.toString();
                        });
                      },
                    ),
                    ActionChip(
                      backgroundColor: const Color(0xFFFEF2F2),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      label: Text(
                        isBangla ? '🔴 বিপদসীমা নমুনা' : '🔴 Critical Example',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                      ),
                      onPressed: () {
                        setState(() {
                          // Pick a critical test value
                          if (_selectedTest.id == 'platelet') {
                            _manualValController.text = '45000';
                          } else if (_selectedTest.id == 'hemoglobin') {
                            _manualValController.text = '7.5';
                          } else if (_selectedTest.id == 'creatinine') {
                            _manualValController.text = '2.4';
                          } else if (_selectedTest.id == 'sgpt') {
                            _manualValController.text = '150';
                          } else if (_selectedTest.id == 'fbs') {
                            _manualValController.text = '8.5';
                          } else {
                            _manualValController.text = (_selectedTest.maxNormal * 1.5).toStringAsFixed(1);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Evaluation Result Box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusBorder, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isBangla ? result.statusTitleBangla : result.statusTitleEnglish,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isBangla ? result.messageBangla : result.messageEnglish,
                  style: const TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                ),
                const Divider(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.health_and_safety_rounded, color: Color(0xFF0A6847), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBangla ? 'পরামর্শ ও করণীয়:' : 'Recommendation:',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0A6847)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isBangla ? result.adviceBangla : result.adviceEnglish,
                            style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF334155)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
