import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import 'first_aid_screen.dart';
import 'vaccination_tracker_screen.dart';

class FirstAidAndVaccineHubScreen extends StatelessWidget {
  const FirstAidAndVaccineHubScreen({super.key});

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
              isBangla ? 'প্রাথমিক চিকিৎসা ও শিশু স্বাস্থ্য' : 'First Aid & Child Health',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              // 1. First Aid Card
              _buildFeatureCard(
                context,
                title: isBangla ? 'জরুরি প্রাথমিক চিকিৎসা (ফার্স্ট এইড)' : 'Emergency First Aid Guide',
                subtitle: isBangla
                    ? 'আগুনে পোড়া, সাপে কাটা, গলায় কিছু আটকে যাওয়া ও স্ট্রোকের লক্ষণ চেনার ১০০% অফলাইন নির্দেশিকা।'
                    : '100% offline lifesaver guidelines for burns, snake bite, choking, and stroke.',
                icon: Icons.medical_services_rounded,
                iconColor: const Color(0xFF0A6847),
                bgColor: const Color(0xFFE8F5E9),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FirstAidScreen())),
              ),
              const SizedBox(height: 16),

              // 2. Child Vaccination Tracker Card
              _buildFeatureCard(
                context,
                title: isBangla ? 'শিশুর টিকাদান সূচি (EPI Tracker)' : 'Child EPI Vaccination Tracker',
                subtitle: isBangla
                    ? 'জন্মের সময় থেকে ১৫ মাস পর্যন্ত সরকারি নিয়মে সব টিকার তারিখ গণনা ও সম্পূর্ণ করার ট্র্যাকার।'
                    : 'Track mandatory child vaccination dates from birth up to 15 months.',
                icon: Icons.child_care_rounded,
                iconColor: Colors.pink.shade700,
                bgColor: Colors.pink.shade50,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VaccinationTrackerScreen())),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
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
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 6),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'প্রবেশ করুন',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: iconColor),
                        ),
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
