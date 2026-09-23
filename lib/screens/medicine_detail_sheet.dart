import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../localization/app_strings.dart';
import '../models/medicine.dart';
import 'medicine_reminder_screen.dart';

class MedicineDetailSheet extends StatefulWidget {
  final Medicine medicine;

  const MedicineDetailSheet({super.key, required this.medicine});

  static void show(BuildContext context, Medicine medicine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MedicineDetailSheet(medicine: medicine),
    );
  }

  @override
  State<MedicineDetailSheet> createState() => _MedicineDetailSheetState();
}

class _MedicineDetailSheetState extends State<MedicineDetailSheet> {
  bool _largeFont = false;

  @override
  Widget build(BuildContext context) {
    final med = widget.medicine;
    final theme = Theme.of(context);
    final textScale = _largeFont ? 1.25 : 1.0;
    final strings = AppStrings(LanguageController.instance.isBangla);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle & Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.medication_liquid_rounded,
                        color: Color(0xFF0A6847),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med.brandName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22 * textScale,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          if (med.strength.isNotEmpty)
                            Text(
                              '${strings.strengthLabel} ${med.strength}',
                              style: TextStyle(
                                fontSize: 14 * textScale,
                                color: const Color(0xFF0A6847),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Elderly font-size toggle button
                    ActionChip(
                      avatar: Icon(
                        _largeFont ? Icons.text_fields_rounded : Icons.text_format_rounded,
                        size: 18,
                        color: _largeFont ? Colors.white : const Color(0xFF0A6847),
                      ),
                      label: Text(
                        _largeFont ? strings.normalFont : strings.largeFont,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _largeFont ? Colors.white : const Color(0xFF0A6847),
                        ),
                      ),
                      backgroundColor: _largeFont ? const Color(0xFF0A6847) : const Color(0xFFE8F5E9),
                      onPressed: () {
                        setState(() {
                          _largeFont = !_largeFont;
                        });
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Quick info pills
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (med.dosageForm.isNotEmpty)
                      _buildChip(
                        icon: Icons.bubble_chart_outlined,
                        label: med.dosageForm,
                        bgColor: Colors.blue.shade50,
                        textColor: Colors.blue.shade900,
                      ),
                    if (med.strength.isNotEmpty)
                      _buildChip(
                        icon: Icons.flash_on_rounded,
                        label: med.strength,
                        bgColor: Colors.amber.shade50,
                        textColor: Colors.brown.shade900,
                      ),
                    _buildChip(
                      icon: Icons.verified_user_outlined,
                      label: strings.offlineDataTag,
                      bgColor: Colors.green.shade50,
                      textColor: Colors.green.shade900,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Generic Name Section
                _buildSectionCard(
                  icon: Icons.science_outlined,
                  iconColor: Colors.teal.shade700,
                  heading: strings.genericHeading,
                  content: med.generic.isNotEmpty ? med.generic : strings.noData,
                  textScale: textScale,
                  strings: strings,
                  isBold: true,
                ),
                const SizedBox(height: 14),

                // Manufacturer Section
                _buildSectionCard(
                  icon: Icons.domain_outlined,
                  iconColor: Colors.indigo.shade700,
                  heading: strings.companyHeading,
                  content: med.manufacturer.isNotEmpty ? med.manufacturer : strings.noData,
                  textScale: textScale,
                  strings: strings,
                ),
                const SizedBox(height: 14),

                // Dosage / Administration Section
                _buildSectionCard(
                  icon: Icons.schedule_rounded,
                  iconColor: const Color(0xFF0A6847),
                  heading: strings.dosageHeading,
                  content: med.dosage.isNotEmpty ? med.dosage : strings.defaultDosageAdvice,
                  textScale: textScale,
                  strings: strings,
                  isHighlight: true,
                ),
                const SizedBox(height: 14),

                // Side Effects Section
                _buildSectionCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.deepOrange.shade700,
                  heading: strings.sideEffectsHeading,
                  content: med.sideEffects.isNotEmpty ? med.sideEffects : strings.defaultSideEffectsAdvice,
                  textScale: textScale,
                  strings: strings,
                  isWarning: true,
                ),
                const SizedBox(height: 20),

                // Elderly warning notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.amber.shade900, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          strings.medicalWarning,
                          style: TextStyle(
                            fontSize: 14 * textScale,
                            fontWeight: FontWeight.w600,
                            color: Colors.brown.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Set Reminder Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_alarm_rounded),
                    label: Text(
                      strings.isBangla ? '🔔 এই ওষুধের রিমাইন্ডার সেট করুন' : '🔔 Set Reminder for this Medicine',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A6847),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicineReminderScreen(
                            initialMedicineName: med.displayNameWithStrength,
                            initialDosage: med.dosage.isNotEmpty ? med.dosage : '১টি ট্যাবলেট',
                            initialMealTiming: 'খাবারের পরে',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String heading,
    required String content,
    required double textScale,
    required AppStrings strings,
    bool isBold = false,
    bool isHighlight = false,
    bool isWarning = false,
  }) {
    Color cardBg = Colors.grey.shade50;
    Color borderColor = Colors.grey.shade200;

    if (isHighlight) {
      cardBg = const Color(0xFFF0FDF4);
      borderColor = const Color(0xFFBBF7D0);
    } else if (isWarning) {
      cardBg = const Color(0xFFFFF7ED);
      borderColor = const Color(0xFFFED7AA);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  heading,
                  style: TextStyle(
                    fontSize: 16 * textScale,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                tooltip: strings.copyTooltip,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: '$heading\n$content'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(strings.copiedMessage(heading)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(height: 16),
          SelectableText(
            content,
            style: TextStyle(
              fontSize: 15 * textScale,
              height: 1.5,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
