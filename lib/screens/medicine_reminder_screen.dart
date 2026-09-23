import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import '../models/medicine_reminder.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class MedicineReminderScreen extends StatefulWidget {
  final String? initialMedicineName;
  final String? initialDosage;
  final String? initialMealTiming;

  const MedicineReminderScreen({
    super.key,
    this.initialMedicineName,
    this.initialDosage,
    this.initialMealTiming,
  });

  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  List<MedicineReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.requestPermissions();
    _loadReminders().then((_) {
      if (widget.initialMedicineName != null && mounted) {
        _showAddReminderDialog(
          prefillMedicine: widget.initialMedicineName,
          prefillDosage: widget.initialDosage,
          prefillMeal: widget.initialMealTiming,
        );
      }
    });
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    final list = await DatabaseHelper.instance.getAllReminders();
    for (final r in list) {
      if (r.isActive) {
        NotificationService.instance.scheduleMedicineReminder(r);
      }
    }
    if (mounted) {
      setState(() {
        _reminders = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleActive(MedicineReminder reminder, bool val) async {
    if (reminder.id == null) return;
    await DatabaseHelper.instance.toggleReminderActive(reminder.id!, val);
    if (!val) {
      await NotificationService.instance.cancelReminder(reminder.id!);
    } else {
      await NotificationService.instance.scheduleMedicineReminder(reminder.copyWith(isActive: true));
    }
    _loadReminders();
  }

  Future<void> _confirmMarkTaken(MedicineReminder reminder, bool isBangla) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isBangla ? 'ওষুধ খাওয়া নিশ্চিত করুন' : 'Confirm Medication Taken',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBangla
                  ? 'আপনি কি নিশ্চিত যে আপনি "${reminder.medicineName}" ওষুধটি এখন খেয়েছেন?'
                  : 'Are you sure you have taken "${reminder.medicineName}" now?',
              style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF0A6847)),
                  const SizedBox(width: 8),
                  Text(
                    '${reminder.formattedTime} (${reminder.slotBangla}) • ${reminder.dosage.isNotEmpty ? reminder.dosage : "১ মাত্রা"}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              isBangla ? 'বাতিল' : 'Cancel',
              style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text(
              isBangla ? 'হ্যাঁ, খেয়েছি' : 'Yes, Taken',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A6847),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _markTaken(reminder);
    }
  }

  Future<void> _confirmUnmarkTaken(MedicineReminder reminder, bool isBangla) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isBangla ? 'স্ট্যাটাস রিসেট করবেন?' : 'Reset Taken Status?',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isBangla
              ? 'ভুলবশত কি "খেয়েছি" চাপ লেগেছিল? আপনি চাইলে এটিকে পুনরায় না-খাওয়া অবস্থায় ফিরিয়ে নিতে পারেন।'
              : 'Did you mark this by mistake? You can reset it back to pending.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isBangla ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isBangla ? 'হ্যাঁ, রিসেট করুন' : 'Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && reminder.id != null) {
      await DatabaseHelper.instance.unmarkReminderTaken(reminder.id!);
      _loadReminders();
    }
  }

  Future<void> _markTaken(MedicineReminder reminder) async {
    if (reminder.id == null) return;
    await DatabaseHelper.instance.markReminderTaken(reminder.id!, DateTime.now());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${reminder.medicineName} ওষুধটি খাওয়া সম্পন্ন হয়েছে'),
          backgroundColor: const Color(0xFF0A6847),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    _loadReminders();
  }

  Future<void> _deleteReminder(int id, String name) async {
    await DatabaseHelper.instance.deleteReminder(id);
    await NotificationService.instance.cancelReminder(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name রিমাইন্ডার মুছে ফেলা হয়েছে')),
      );
    }
    _loadReminders();
  }

  Future<void> _testInstantNotification(bool isBangla) async {
    await NotificationService.instance.showInstantNotification(
      title: isBangla ? '🔔 নাপা ৫০০ মিগ্রা খাওয়ার সময় হয়েছে!' : '🔔 Time for Napa 500mg!',
      body: isBangla ? 'সকাল — ১টি ট্যাবলেট (ভরা পেটে সেবন করুন)' : 'Morning — 1 Tablet (After meal)',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBangla
                ? 'টেস্ট নোটিফিকেশন পাঠানো হয়েছে! ফোনের নোটিফিকেশন বার চেক করুন।'
                : 'Test notification sent! Check your notification tray.',
          ),
          backgroundColor: const Color(0xFF0A6847),
        ),
      );
    }
  }

  /*
  void _showTokenDialog() {
    final token = NotificationService.instance.fcmToken ?? 'টোকেন পাওয়া যায়নি (কেবল অ্যান্ড্রয়েড/আইওএস ডিভাইসে প্রযোজ্য)';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Firebase FCM Token', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SelectableText(token, style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('কপি করুন'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: token));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('FCM Token ক্লিপবোর্ডে কপি করা হয়েছে')),
              );
            },
          ),
          TextButton(
            child: const Text('ঠিক আছে'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }
  */

  void _showAddReminderDialog({
    String? prefillMedicine,
    String? prefillDosage,
    String? prefillMeal,
  }) {
    final nameController = TextEditingController(text: prefillMedicine ?? '');
    final dosageController = TextEditingController(text: prefillDosage ?? '১টি ট্যাবলেট');
    String mealTiming = prefillMeal ?? 'খাবারের পরে';
    TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
    bool isMorning = true;
    bool isNoon = false;
    bool isNight = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '🔔 নতুন ওষুধের রিমাইন্ডার',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Medicine Name
                    const Text('ওষুধের নাম:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'যেমন: Napa 500mg, Seclo 20mg...',
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Dosage
                    const Text('পরিমাণ বা মাত্রা (Dosage):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: dosageController,
                      decoration: InputDecoration(
                        hintText: 'যেমন: ১টি ট্যাবলেট, ২ চামচ...',
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Meal Timing Chips
                    const Text('খাওয়ার নিয়ম:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['খাবারের আগে', 'খাবারের পরে', 'খাবারের সাথে'].map((timing) {
                        final isSelected = mealTiming == timing;
                        return ChoiceChip(
                          label: Text(timing),
                          selected: isSelected,
                          selectedColor: const Color(0xFF0A6847),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (selected) {
                            if (selected) setModalState(() => mealTiming = timing);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Time Slot Presets & Custom Time Picker
                    const Text('সময় নির্ধারণ করুন:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                isMorning = true;
                                isNoon = false;
                                isNight = false;
                                selectedTime = const TimeOfDay(hour: 8, minute: 0);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isMorning ? const Color(0xFF0A6847) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.wb_sunny_rounded, size: 20, color: isMorning ? Colors.white : Colors.grey.shade600),
                                  const SizedBox(height: 4),
                                  Text(
                                    'সকাল',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isMorning ? Colors.white : Colors.grey.shade800),
                                  ),
                                  Text(
                                    '০৮:০০ AM',
                                    style: TextStyle(fontSize: 10, color: isMorning ? Colors.white70 : Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                isMorning = false;
                                isNoon = true;
                                isNight = false;
                                selectedTime = const TimeOfDay(hour: 14, minute: 0);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isNoon ? const Color(0xFF0A6847) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.light_mode_rounded, size: 20, color: isNoon ? Colors.white : Colors.grey.shade600),
                                  const SizedBox(height: 4),
                                  Text(
                                    'দুপুর',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isNoon ? Colors.white : Colors.grey.shade800),
                                  ),
                                  Text(
                                    '০২:০০ PM',
                                    style: TextStyle(fontSize: 10, color: isNoon ? Colors.white70 : Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                isMorning = false;
                                isNoon = false;
                                isNight = true;
                                selectedTime = const TimeOfDay(hour: 21, minute: 0);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isNight ? const Color(0xFF0A6847) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.nightlight_round, size: 20, color: isNight ? Colors.white : Colors.grey.shade600),
                                  const SizedBox(height: 4),
                                  Text(
                                    'রাত',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isNight ? Colors.white : Colors.grey.shade800),
                                  ),
                                  Text(
                                    '০৯:০০ PM',
                                    style: TextStyle(fontSize: 10, color: isNight ? Colors.white70 : Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Custom exact time button
                    OutlinedButton.icon(
                      icon: const Icon(Icons.access_time_filled_rounded, size: 18, color: Color(0xFF0A6847)),
                      label: Text(
                        'নির্দিষ্ট সময় পরিবর্তন করুন: ${selectedTime.format(context)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0A6847)),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: Color(0xFF0A6847)),
                      ),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedTime = picked;
                            isMorning = picked.hour < 12;
                            isNoon = picked.hour >= 12 && picked.hour < 18;
                            isNight = picked.hour >= 18;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A6847),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('অনুগ্রহ করে ওষুধের নাম লিখুন')),
                            );
                            return;
                          }

                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(ctx);

                          final newReminder = MedicineReminder(
                            medicineName: name,
                            dosage: dosageController.text.trim(),
                            mealTiming: mealTiming,
                            timeHour: selectedTime.hour,
                            timeMinute: selectedTime.minute,
                            isMorning: isMorning,
                            isNoon: isNoon,
                            isNight: isNight,
                            isActive: true,
                          );

                          final insertedId = await DatabaseHelper.instance.insertReminder(newReminder);
                          final savedReminder = newReminder.copyWith(id: insertedId);
                          await NotificationService.instance.scheduleMedicineReminder(savedReminder);

                          final now = DateTime.now();
                          final isToday = (selectedTime.hour > now.hour) ||
                              (selectedTime.hour == now.hour && selectedTime.minute > now.minute);
                          final dayText = isToday ? 'আজকে' : 'আগামীকাল';

                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('🔔 $name এর রিমাইন্ডার সেট করা হয়েছে ($dayText ${savedReminder.formattedTime} থেকে বাজবে)'),
                              backgroundColor: const Color(0xFF0A6847),
                            ),
                          );
                          _loadReminders();
                        },
                        child: const Text('রিমাইন্ডার সেভ করুন', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageController.instance,
      builder: (context, _) {
        final isBangla = LanguageController.instance.isBangla;
        final now = DateTime.now();
        final takenCount = _reminders.where((r) => r.isTakenToday(now)).length;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A6847),
            title: Text(
              isBangla ? 'ওষুধের রিমাইন্ডার ও রুটিন' : 'Medicine Reminders & Routine',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_active_rounded),
                tooltip: isBangla ? 'টেস্ট নোটিফিকেশন' : 'Test notification',
                onPressed: () => _testInstantNotification(isBangla),
              ),
              // Firebase FCM Token (Temporarily commented out - local notification mode active)
              /*
              IconButton(
                icon: const Icon(Icons.cloud_sync_rounded),
                tooltip: 'Firebase FCM Token',
                onPressed: _showTokenDialog,
              ),
              */
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF0A6847),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_alarm_rounded),
            label: Text(
              isBangla ? 'নতুন রিমাইন্ডার' : 'Add Reminder',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => _showAddReminderDialog(),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Daily Progress Header Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0A6847), Color(0xFF15803D)],
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isBangla ? 'আজকের ওষুধ খাওয়ার অগ্রগতি' : 'Today\'s Medication Progress',
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isBangla ? '$takenCount / ${_reminders.length} সম্পন্ন' : '$takenCount / ${_reminders.length} Taken',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _reminders.isEmpty ? 0 : takenCount / _reminders.length,
                              backgroundColor: Colors.white.withValues(alpha: 0.25),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isBangla
                                ? 'সময়মতো ওষুধ খেলে অ্যালার্ম বাজবে। খাওয়ার পর "খেয়েছি" চাপুন।'
                                : 'Reminders notify on schedule. Tap "Mark Taken" when ingested.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11),
                          ),
                        ],
                      ),
                    ),

                    // Quick Test Notification Action Banner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_active_rounded, color: Color(0xFF0A6847), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isBangla ? 'নোটিফিকেশন ও অ্যালার্ম চেক করতে চান?' : 'Want to verify notification sound & popup?',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A6847),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _testInstantNotification(isBangla),
                              child: Text(
                                isBangla ? 'এখনই টেস্ট' : 'Test Now',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Reminders List
                    Expanded(
                      child: _reminders.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEFF6FF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.alarm_off_rounded, size: 56, color: Color(0xFF2563EB)),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      isBangla ? 'কোনো সক্রিয় রিমাইন্ডার নেই' : 'No Active Reminders',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      isBangla
                                          ? 'নিচের "নতুন রিমাইন্ডার" বোতামে চাপ দিয়ে প্রতিদিনের ওষুধ খাওয়ার সময় সেট করুন।'
                                          : 'Tap "Add Reminder" button below to schedule daily medicine alarms.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              itemCount: _reminders.length,
                              itemBuilder: (context, index) {
                                final reminder = _reminders[index];
                                final isTaken = reminder.isTakenToday(now);

                                return Card(
                                  elevation: 1.5,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: isTaken ? const Color(0xFFBBF7D0) : Colors.grey.shade200,
                                      width: 1.2,
                                    ),
                                  ),
                                  color: isTaken ? const Color(0xFFF0FDF4) : Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        // Time & Slot Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isTaken ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                reminder.isMorning
                                                    ? Icons.wb_sunny_rounded
                                                    : reminder.isNoon
                                                        ? Icons.light_mode_rounded
                                                        : Icons.nightlight_round,
                                                size: 20,
                                                color: isTaken ? const Color(0xFF16A34A) : const Color(0xFF0A6847),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                reminder.formattedTime,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: isTaken ? const Color(0xFF15803D) : const Color(0xFF0F172A),
                                                ),
                                              ),
                                              Text(
                                                reminder.slotBangla,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isTaken ? const Color(0xFF166534) : Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                reminder.medicineName,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF1E293B),
                                                  decoration: isTaken ? TextDecoration.lineThrough : null,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Wrap(
                                                spacing: 6,
                                                children: [
                                                  if (reminder.dosage.isNotEmpty)
                                                    Text(
                                                      reminder.dosage,
                                                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                                    ),
                                                  if (reminder.mealTiming.isNotEmpty)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFEFF6FF),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        reminder.mealTiming,
                                                        style: const TextStyle(fontSize: 10, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),

                                              // Mark Taken / Status Button with Confirmation
                                              if (isTaken)
                                                InkWell(
                                                  onTap: () => _confirmUnmarkTaken(reminder, isBangla),
                                                  borderRadius: BorderRadius.circular(6),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFDCFCE7),
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(color: const Color(0xFF86EFAC)),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.check_circle_rounded, size: 15, color: Color(0xFF16A34A)),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          isBangla ? 'আজকে খাওয়া হয়েছে' : 'Taken Today',
                                                          style: const TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Icon(Icons.edit_outlined, size: 12, color: Colors.green.shade800),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              else
                                                InkWell(
                                                  onTap: () => _confirmMarkTaken(reminder, isBangla),
                                                  borderRadius: BorderRadius.circular(6),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF0A6847).withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(color: const Color(0xFF0A6847).withValues(alpha: 0.35)),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.check_rounded, size: 15, color: Color(0xFF0A6847)),
                                                        const SizedBox(width: 5),
                                                        Text(
                                                          isBangla ? 'খেয়েছি (Mark Taken)' : 'Mark as Taken',
                                                          style: const TextStyle(fontSize: 12, color: Color(0xFF0A6847), fontWeight: FontWeight.bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                        // Switch & Delete
                                        Column(
                                          children: [
                                            Switch(
                                              value: reminder.isActive,
                                              activeThumbColor: const Color(0xFF0A6847),
                                              onChanged: (val) => _toggleActive(reminder, val),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.grey),
                                              onPressed: () => _deleteReminder(reminder.id!, reminder.medicineName),
                                            ),
                                          ],
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
