import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import 'blood_directory_screen.dart';
import 'emergency_sos_screen.dart';
import 'medicine_expiry_screen.dart';

class EmergencyHubScreen extends StatelessWidget {
  const EmergencyHubScreen({super.key});

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
            backgroundColor: const Color(0xFFB91C1C),
            title: Text(
              strings.emergencyHubTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            elevation: 0,
            actions: const [
              LanguageToggleButton(),
              SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              // 1. Emergency SOS Card
              _buildCard(
                context,
                title: strings.emergencySosCardTitle,
                subtitle: strings.emergencySosCardSubtitle,
                enterText: strings.enter,
                icon: Icons.emergency_rounded,
                iconColor: const Color(0xFFDC2626),
                bgColor: const Color(0xFFFEF2F2),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencySosScreen())),
              ),
              const SizedBox(height: 16),

              // 2. Blood Bank Directory Card
              _buildCard(
                context,
                title: strings.emergencyBloodCardTitle,
                subtitle: strings.emergencyBloodCardSubtitle,
                enterText: strings.enter,
                icon: Icons.bloodtype_rounded,
                iconColor: const Color(0xFFB91C1C),
                bgColor: const Color(0xFFFFF1F2),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodDirectoryScreen())),
              ),
              const SizedBox(height: 16),

              // 3. Home Medicine Cabinet Expiry Card
              _buildCard(
                context,
                title: strings.emergencyExpiryCardTitle,
                subtitle: strings.emergencyExpiryCardSubtitle,
                enterText: strings.enter,
                icon: Icons.inventory_2_rounded,
                iconColor: const Color(0xFF0A6847),
                bgColor: const Color(0xFFE8F5E9),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicineExpiryScreen())),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String enterText,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 6),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(enterText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: iconColor)),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 16, color: iconColor),
                      ],
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
}
