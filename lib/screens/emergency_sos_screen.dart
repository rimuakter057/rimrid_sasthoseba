import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/emergency_data.dart';
import '../localization/app_strings.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen> {
  String _guardianPhone = '';
  final TextEditingController _guardianController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGuardianPhone();
  }

  Future<void> _loadGuardianPhone() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _guardianPhone = prefs.getString('emergency_guardian_phone') ?? '';
      _guardianController.text = _guardianPhone;
    });
  }

  Future<void> _saveGuardianPhone(String phone, AppStrings strings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emergency_guardian_phone', phone.trim());
    setState(() {
      _guardianPhone = phone.trim();
    });
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.sosGuardianSavedMessage)),
      );
    }
  }

  Future<void> _callNumber(String phone, AppStrings strings) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.sosCallFailedMessage(phone))),
        );
      }
    }
  }

  void _showSetGuardianDialog(AppStrings strings) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.sosGuardianDialogTitle),
          content: TextField(
            controller: _guardianController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: strings.sosGuardianPhoneHint,
              prefixIcon: const Icon(Icons.phone),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(strings.cancel)),
            ElevatedButton(
              onPressed: () => _saveGuardianPhone(_guardianController.text, strings),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
              child: Text(strings.saveAction),
            ),
          ],
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
        final strings = AppStrings(isBangla);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFDC2626),
            title: Text(
              strings.sosScreenTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            elevation: 0,
            actions: const [
              LanguageToggleButton(),
              SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Big SOS Call Button
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => _callNumber('999', strings),
                      borderRadius: BorderRadius.circular(75),
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFDC2626),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC2626).withValues(alpha: 0.35),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.emergency_rounded, size: 52, color: Colors.white),
                              Text('SOS 999', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.sosBigButtonTapPrompt,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.sosBigButtonServicesText,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF7F1D1D)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Guardian Contact Card
              Card(
                elevation: 0.8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                        child: const Icon(Icons.family_restroom_rounded, color: Colors.blue, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.sosFamilyContactTitle,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                            Text(
                              _guardianPhone.isNotEmpty ? _guardianPhone : strings.sosNoNumberSaved,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      if (_guardianPhone.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.call_rounded, color: Colors.green, size: 28),
                          onPressed: () => _callNumber(_guardianPhone, strings),
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: Colors.grey),
                        onPressed: () => _showSetGuardianDialog(strings),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // National Emergency Hotlines List
              Text(
                strings.sosHotlinesListTitle,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 10),

              ...EmergencyData.nationalHotlines.map((contact) {
                return Card(
                  elevation: 0.6,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF0A6847), size: 22),
                    ),
                    title: Text(
                      isBangla ? contact.titleBangla : contact.titleEnglish,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      isBangla ? contact.descriptionBangla : contact.descriptionEnglish,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _callNumber(contact.number, strings),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A6847),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(strings.call),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
