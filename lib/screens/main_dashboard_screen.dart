import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import 'emergency_hub_screen.dart';
import 'first_aid_and_vaccine_hub_screen.dart';
import 'home_screen.dart';
import 'interaction_checker_screen.dart';
import 'lab_report_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    InteractionCheckerScreen(),
    LabReportScreen(),
    FirstAidAndVaccineHubScreen(),
    EmergencyHubScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageController.instance,
      builder: (context, _) {
        final isBangla = LanguageController.instance.isBangla;

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF0A6847),
              unselectedItemColor: const Color(0xFF64748B),
              selectedFontSize: 11,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              backgroundColor: Colors.white,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.medication_rounded),
                  label: isBangla ? 'ওষুধ' : 'Medicines',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.compare_arrows_rounded),
                  label: isBangla ? 'বিক্রিয়া' : 'Interactions',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.biotech_rounded),
                  label: isBangla ? 'ল্যাব টেস্ট' : 'Lab Tests',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.health_and_safety_rounded),
                  label: isBangla ? 'ফার্স্ট এইড' : 'First Aid',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.emergency_rounded),
                  label: isBangla ? 'জরুরি সেবা' : 'Emergency',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
