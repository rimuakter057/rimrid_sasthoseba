import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../localization/app_strings.dart';
import '../models/prescription_item.dart';
import '../services/prescription_parser_service.dart';
import 'medicine_detail_sheet.dart';
import 'medicine_reminder_screen.dart';

class PrescriptionScanScreen extends StatefulWidget {
  const PrescriptionScanScreen({super.key});

  @override
  State<PrescriptionScanScreen> createState() => _PrescriptionScanScreenState();
}

class _PrescriptionScanScreenState extends State<PrescriptionScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final PrescriptionParserService _parserService = PrescriptionParserService.instance;

  File? _selectedImage;
  bool _isProcessing = false;
  List<PrescriptionItem> _detectedItems = [];
  String? _rawOcrText;

  Future<void> _pickAndProcessImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 90,
      );

      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
        _isProcessing = true;
        _detectedItems = [];
        _rawOcrText = null;
      });

      // 1. OCR text extraction
      final text = await _parserService.extractTextFromImage(_selectedImage!);
      _rawOcrText = text;

      // 2. Parse medicines and match with SQLite database
      final items = await _parserService.parsePrescriptionText(text);

      setState(() {
        _detectedItems = items;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ত্রুটি হয়েছে: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageController.instance,
      builder: (context, _) {
        final strings = AppStrings(LanguageController.instance.isBangla);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A6847),
            title: Text(
              strings.prescriptionScannerTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline_rounded),
                tooltip: 'সহায়িকা',
                onPressed: () => _showHelpDialog(strings),
              ),
            ],
          ),
          body: Column(
            children: [
              // Top Action / Capture Card
              _buildCaptureCard(strings),

              // Processing State OR Results List
              Expanded(
                child: _isProcessing
                    ? _buildProcessingView(strings)
                    : _selectedImage == null
                        ? _buildWelcomeGuide(strings)
                        : _detectedItems.isEmpty
                            ? _buildEmptyResultsView(strings)
                            : _buildResultsList(strings),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCaptureCard(AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Row(
            children: [
              // Camera Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : () => _pickAndProcessImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded, size: 20),
                  label: Text(
                    strings.scanFromCamera,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A6847),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Gallery Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isProcessing ? null : () => _pickAndProcessImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded, size: 20, color: Color(0xFF0A6847)),
                  label: Text(
                    strings.scanFromGallery,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0A6847)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0A6847), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          if (_selectedImage != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 6),
                const Text(
                  'প্রেসক্রিপশন আপলোড করা হয়েছে',
                  style: TextStyle(fontSize: 12, color: Color(0xFF047857), fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showRawOcrSheet(),
                  child: const Text('মূল লেখা দেখুন (OCR)', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProcessingView(AppStrings strings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                color: Color(0xFF0A6847),
                strokeWidth: 3.5,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              strings.scanningInProgress,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              strings.scanningSubtitle,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeGuide(AppStrings strings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBBF7D0), width: 2),
            ),
            child: const Icon(
              Icons.document_scanner_rounded,
              size: 64,
              color: Color(0xFF0A6847),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            strings.scannerInstructionTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            strings.scannerInstructionBody,
            style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildGuideRow(Icons.lightbulb_outline_rounded, 'পর্যাপ্ত আলোতে ছবি তুলুন', Colors.amber.shade700),
                const Divider(height: 16),
                _buildGuideRow(Icons.crop_free_rounded, 'প্রেসক্রিপশনটি সোজাভাবে ফ্রেমের মধ্যে রাখুন', Colors.blue.shade700),
                const Divider(height: 16),
                _buildGuideRow(Icons.verified_outlined, 'অন-ডিভাইস অফলাইন স্ক্যানিং (নিরাপদ ও দ্রুত)', Colors.green.shade700),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsList(AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            strings.detectedMedicinesCount(_detectedItems.length),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
            itemCount: _detectedItems.length,
            itemBuilder: (context, index) {
              final item = _detectedItems[index];
              return _buildPrescriptionCard(item, strings);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionCard(PrescriptionItem item, AppStrings strings) {
    final med = item.matchedMedicine;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Medicine Name & Form Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.medication_rounded, color: Color(0xFF0A6847), size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med != null ? med.displayNameWithStrength : item.rawText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (med != null && med.generic.isNotEmpty)
                        Text(
                          '${strings.genericLabel} ${med.generic}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade800,
                          ),
                        ),
                    ],
                  ),
                ),
                if (med != null && med.dosageForm.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      med.dosageForm,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                    ),
                  ),
              ],
            ),
            const Divider(height: 20),

            // Indication / রোগের নাম (কোন কাজের জন্য)
            if (item.indication.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.healing_rounded, color: Color(0xFF2563EB), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.indicationLabel,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.indication,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Dosage frequency (১ + ০ + ১) & Meal timing
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (item.frequency.isNotEmpty)
                  _buildPill(
                    icon: Icons.schedule_rounded,
                    label: '${strings.scheduleLabel} ${item.frequency}',
                    bg: const Color(0xFFF0FDF4),
                    fg: const Color(0xFF15803D),
                    border: const Color(0xFFBBF7D0),
                  ),
                if (item.mealTiming.isNotEmpty)
                  _buildPill(
                    icon: Icons.restaurant_rounded,
                    label: '${strings.mealTimingLabel} ${item.mealTiming}',
                    bg: const Color(0xFFFFF7ED),
                    fg: const Color(0xFFC2410C),
                    border: const Color(0xFFFED7AA),
                  ),
                if (item.duration.isNotEmpty)
                  _buildPill(
                    icon: Icons.calendar_today_rounded,
                    label: '${strings.durationLabel} ${item.duration}',
                    bg: Colors.purple.shade50,
                    fg: Colors.purple.shade800,
                    border: Colors.purple.shade200,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Original Scanned Line
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    strings.originalLineLabel,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.rawText,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade800, fontStyle: FontStyle.italic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 1-Tap Add to Reminder
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.alarm_add_rounded, size: 16, color: Color(0xFF0A6847)),
                label: Text(
                  strings.isBangla ? 'রিমাইন্ডারে যোগ করুন' : 'Add to Reminders',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0A6847)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicineReminderScreen(
                        initialMedicineName: med != null ? med.displayNameWithStrength : item.rawText,
                        initialDosage: item.frequency.isNotEmpty ? item.frequency : '১টি',
                        initialMealTiming: item.mealTiming.isNotEmpty ? item.mealTiming : 'খাবারের পরে',
                      ),
                    ),
                  );
                },
              ),
            ),

            // Action Button: View Full Medicine Details
            if (med != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => MedicineDetailSheet.show(context, med),
                  icon: const Icon(Icons.info_outline_rounded, size: 18),
                  label: Text(strings.viewFullDetailsBtn),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0A6847),
                    backgroundColor: const Color(0xFFE8F5E9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResultsView(AppStrings strings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.document_scanner_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              strings.noPrescriptionDetected,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 8),
            Text(
              strings.noPrescriptionHint,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showRawOcrSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('OCR টেক্সট প্রিভিউ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    _rawOcrText ?? 'কোনো টেক্সট পাওয়া যায়নি',
                    style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpDialog(AppStrings strings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('প্রেসক্রিপশন স্ক্যান সহায়িকা'),
        content: const Text(
          '১. ভালো আলোতে প্রেসক্রিপশনের স্পষ্ট ছবি তুলুন।\n'
          '২. প্রিন্ট করা প্রেসক্রিপশন শতভাগ নির্ভুলভাবে পড়া যায়।\n'
          '৩. শনাক্ত হওয়া যেকোনো ওষুধের উপর ট্যাপ করে তার সম্পূর্ণ খাওয়ার নিয়ম, জেনেরিক এবং পার্শ্বপ্রতিক্রিয়া দেখতে পারবেন।\n'
          '৪. এটি সম্পূর্ণ অফলাইনে কাজ করে।',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ঠিক আছে')),
        ],
      ),
    );
  }
}
