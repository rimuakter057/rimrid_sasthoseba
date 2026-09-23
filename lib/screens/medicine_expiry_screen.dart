import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_strings.dart';

class CabinetMedicine {
  final String id;
  final String name;
  final DateTime expiryDate;

  CabinetMedicine({required this.id, required this.name, required this.expiryDate});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'expiryDate': expiryDate.toIso8601String(),
      };

  factory CabinetMedicine.fromJson(Map<String, dynamic> json) => CabinetMedicine(
        id: json['id'] as String,
        name: json['name'] as String,
        expiryDate: DateTime.parse(json['expiryDate'] as String),
      );
}

class MedicineExpiryScreen extends StatefulWidget {
  const MedicineExpiryScreen({super.key});

  @override
  State<MedicineExpiryScreen> createState() => _MedicineExpiryScreenState();
}

class _MedicineExpiryScreenState extends State<MedicineExpiryScreen> {
  final List<CabinetMedicine> _cabinetItems = [];
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCabinet();
  }

  Future<void> _loadCabinet() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('home_cabinet_items') ?? [];
    setState(() {
      _cabinetItems.clear();
      for (final s in jsonList) {
        try {
          _cabinetItems.add(CabinetMedicine.fromJson(jsonDecode(s) as Map<String, dynamic>));
        } catch (_) {}
      }
    });
  }

  Future<void> _saveCabinet() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _cabinetItems.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('home_cabinet_items', jsonList);
  }

  void _addItem(String name, DateTime exp) {
    if (name.trim().isEmpty) return;
    setState(() {
      _cabinetItems.add(CabinetMedicine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        expiryDate: exp,
      ));
    });
    _saveCabinet();
    Navigator.pop(context);
    _nameController.clear();
  }

  void _removeItem(int index) {
    setState(() {
      _cabinetItems.removeAt(index);
    });
    _saveCabinet();
  }

  void _showAddDialog(BuildContext context, bool isBangla) {
    DateTime tempExp = DateTime.now().add(const Duration(days: 180));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isBangla ? 'গৃহস্থালী ওষুধ যোগ করুন' : 'Add Medicine to Cabinet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: isBangla ? 'ওষুধের নাম (যেমন: Napa 500mg)' : 'Medicine Name',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${isBangla ? 'মেয়াদ শেষ:' : 'Expiry:'} ${tempExp.month}/${tempExp.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: Text(isBangla ? 'তারিখ দিন' : 'Set Date'),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tempExp,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (picked != null) {
                        setDialogState(() => tempExp = picked);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isBangla ? 'বাতিল' : 'Cancel')),
            ElevatedButton(
              onPressed: () => _addItem(_nameController.text, tempExp),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A6847), foregroundColor: Colors.white),
              child: Text(isBangla ? 'যোগ করুন' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageController.instance,
      builder: (context, _) {
        final isBangla = LanguageController.instance.isBangla;
        final now = DateTime.now();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A6847),
            title: Text(
              isBangla ? 'ঘরের ওষুধের মেয়াদোত্তীর্ণ ট্র্যাকার' : 'Medicine Expiry Tracker',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            elevation: 0,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddDialog(context, isBangla),
            backgroundColor: const Color(0xFF0A6847),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: Text(isBangla ? 'নতুন ওষুধ যোগ' : 'Add Medicine'),
          ),
          body: _cabinetItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          isBangla ? 'আপনার ঘরের বক্স খালি' : 'Your cabinet is empty',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isBangla
                              ? 'বাসার ড্রয়ার বা বক্সে রাখা ওষুধের নাম ও এক্সপায়ারি ডেট যোগ করুন। মেয়াদ শেষ হওয়ার আগে অ্যাপ সতর্ক করবে।'
                              : 'Add medicines stored at home with their expiry dates to track safety.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
                  itemCount: _cabinetItems.length,
                  itemBuilder: (context, index) {
                    final item = _cabinetItems[index];
                    final isExpired = item.expiryDate.isBefore(now);
                    final daysLeft = item.expiryDate.difference(now).inDays;
                    final isExpiringSoon = !isExpired && daysLeft <= 30;

                    Color statusBg = const Color(0xFFF0FDF4);
                    Color statusBorder = const Color(0xFFBBF7D0);
                    Color statusColor = const Color(0xFF16A34A);
                    String statusText = isBangla ? 'মেয়াদ ঠিক আছে' : 'Good';

                    if (isExpired) {
                      statusBg = const Color(0xFFFEF2F2);
                      statusBorder = const Color(0xFFFECACA);
                      statusColor = const Color(0xFFDC2626);
                      statusText = isBangla ? 'মেয়াদোত্তীর্ণ (ফেলে দিন)' : 'Expired! Discard';
                    } else if (isExpiringSoon) {
                      statusBg = const Color(0xFFFFFBEB);
                      statusBorder = const Color(0xFFFDE68A);
                      statusColor = const Color(0xFFD97706);
                      statusText = isBangla ? 'শীঘ্রই শেষ হবে ($daysLeft দিন)' : 'Expiring ($daysLeft days)';
                    }

                    return Card(
                      elevation: 0.8,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: statusBorder),
                      ),
                      color: statusBg,
                      child: ListTile(
                        leading: Icon(
                          isExpired ? Icons.cancel_rounded : Icons.medication_rounded,
                          color: statusColor,
                          size: 28,
                        ),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: isExpired ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(
                          '${isBangla ? 'মেয়াদ:' : 'Expiry:'} ${item.expiryDate.month}/${item.expiryDate.year} • $statusText',
                          style: TextStyle(fontWeight: FontWeight.w600, color: statusColor, fontSize: 13),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey),
                          onPressed: () => _removeItem(index),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
