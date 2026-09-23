import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/emergency_data.dart';
import '../localization/app_strings.dart';

class BloodDirectoryScreen extends StatefulWidget {
  const BloodDirectoryScreen({super.key});

  @override
  State<BloodDirectoryScreen> createState() => _BloodDirectoryScreenState();
}

class _BloodDirectoryScreenState extends State<BloodDirectoryScreen> {
  String _selectedGroup = 'সকল';
  String _selectedDivision = 'সকল';

  final List<String> _bloodGroups = const ['সকল', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> _divisions = const ['সকল', 'ঢাকা', 'চট্টগ্রাম', 'রাজশাহী', 'সিলেট', 'খুলনা', 'বরিশাল', 'রংপুর', 'ময়মনসিংহ'];

  Future<void> _makeCall(String phoneNumber, AppStrings strings) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.sosCallFailedMessage(phoneNumber))),
        );
      }
    }
  }

  String _getDivisionLabel(String div, AppStrings strings) {
    switch (div) {
      case 'সকল':
        return strings.divisionAll;
      case 'ঢাকা':
        return strings.divisionDhaka;
      case 'চট্টগ্রাম':
        return strings.divisionChittagong;
      case 'রাজশাহী':
        return strings.divisionRajshahi;
      case 'সিলেট':
        return strings.divisionSylhet;
      case 'খুলনা':
        return strings.divisionKhulna;
      case 'বরিশাল':
        return strings.divisionBarishal;
      case 'রংপুর':
        return strings.divisionRangpur;
      case 'ময়মনসিংহ':
      case 'ময়মনসিংহ':
        return strings.divisionMymensingh;
      default:
        return div;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageController.instance,
      builder: (context, _) {
        final isBangla = LanguageController.instance.isBangla;
        final strings = AppStrings(isBangla);

        final filteredBanks = EmergencyData.verifiedBloodBanks.where((bank) {
          final matchesDiv = _selectedDivision == 'সকল' || bank.division == _selectedDivision;
          final matchesGroup = _selectedGroup == 'সকল' || bank.availableGroups.contains(_selectedGroup);
          return matchesDiv && matchesGroup;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFB91C1C),
            title: Text(
              strings.bloodFinderTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            elevation: 0,
            actions: const [
              LanguageToggleButton(),
              SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Filter Header Container
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Blood Group Horizontal Selector
                    Text(
                      strings.bloodSelectGroup,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _bloodGroups.map((group) {
                          final isSelected = _selectedGroup == group;
                          final groupLabel = group == 'সকল' ? strings.all : group;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(groupLabel, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFFB91C1C))),
                              selected: isSelected,
                              selectedColor: const Color(0xFFB91C1C),
                              backgroundColor: const Color(0xFFFEF2F2),
                              side: BorderSide(color: isSelected ? const Color(0xFFB91C1C) : const Color(0xFFFECACA)),
                              onSelected: (_) => setState(() => _selectedGroup = group),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Division Dropdown Selector
                    Row(
                      children: [
                        Text(
                          strings.bloodSelectDivision,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedDivision,
                                isExpanded: true,
                                items: _divisions.map((div) {
                                  return DropdownMenuItem(
                                    value: div,
                                    child: Text(
                                      _getDivisionLabel(div, strings),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedDivision = val);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Count Status
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      strings.bloodCentersFound(filteredBanks.length),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ),

              // Blood Banks List
              Expanded(
                child: filteredBanks.isEmpty
                    ? Center(
                        child: Text(
                          strings.bloodNoCentersInRegion,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                        itemCount: filteredBanks.length,
                        itemBuilder: (context, index) {
                          final bank = filteredBanks[index];
                          return Card(
                            elevation: 0.8,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.bloodtype_rounded, color: Color(0xFFB91C1C), size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              bank.name,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                            ),
                                            Text(
                                              '${bank.district}, ${_getDivisionLabel(bank.division, strings)}',
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          bank.address,
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Call Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _makeCall(bank.phone, strings),
                                      icon: const Icon(Icons.phone_rounded, size: 18),
                                      label: Text(
                                        strings.bloodCallDirect(bank.phone),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFB91C1C),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
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
