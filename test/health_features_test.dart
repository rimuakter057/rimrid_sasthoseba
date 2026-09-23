import 'package:flutter_test/flutter_test.dart';
import 'package:rimrid_sasthoseba/data/emergency_data.dart';
import 'package:rimrid_sasthoseba/data/lab_tests_data.dart';
import 'package:rimrid_sasthoseba/models/medicine.dart';
import 'package:rimrid_sasthoseba/services/interaction_service.dart';

void main() {
  group('Health Features Tests', () {
    test('InteractionService detects severe NSAID and Blood Thinner conflict', () {
      const aspirin = Medicine(
        brandName: 'Ecosprin',
        generic: 'Aspirin',
        manufacturer: 'Square',
        strength: '75 mg',
        dosageForm: 'Tablet',
        dosage: '',
        sideEffects: '',
      );

      const clopidogrel = Medicine(
        brandName: 'Plagrin',
        generic: 'Clopidogrel',
        manufacturer: 'Square',
        strength: '75 mg',
        dosageForm: 'Tablet',
        dosage: '',
        sideEffects: '',
      );

      final alerts = InteractionService.instance.analyzeInteractions([aspirin, clopidogrel]);
      expect(alerts.isNotEmpty, true);
      expect(alerts.first.risk, InteractionRisk.severe);
      expect(alerts.first.titleBangla.contains('রক্তক্ষরণ'), true);
    });

    test('InteractionService detects duplicate Paracetamol overdosage', () {
      const napa = Medicine(
        brandName: 'Napa',
        generic: 'Paracetamol',
        manufacturer: 'Beximco',
        strength: '500 mg',
        dosageForm: 'Tablet',
        dosage: '',
        sideEffects: '',
      );

      const ace = Medicine(
        brandName: 'Ace',
        generic: 'Paracetamol',
        manufacturer: 'Square',
        strength: '500 mg',
        dosageForm: 'Tablet',
        dosage: '',
        sideEffects: '',
      );

      final alerts = InteractionService.instance.analyzeInteractions([napa, ace]);
      expect(alerts.isNotEmpty, true);
      expect(alerts.first.risk, InteractionRisk.severe);
      expect(alerts.first.titleBangla.contains('দ্বৈত মাত্রা'), true);
    });

    test('InteractionService detects duplicate NSAID conflict', () {
      const naproxen = Medicine(
        brandName: 'Napryn',
        generic: 'Naproxen',
        manufacturer: 'Square',
        strength: '500 mg',
        dosageForm: 'Tablet',
        dosage: '',
        sideEffects: '',
      );

      const diclofenac = Medicine(
        brandName: 'Clofenac',
        generic: 'Diclofenac Sodium',
        manufacturer: 'Square',
        strength: '50 mg',
        dosageForm: 'Tablet',
        dosage: '',
        sideEffects: '',
      );

      final alerts = InteractionService.instance.analyzeInteractions([naproxen, diclofenac]);
      expect(alerts.isNotEmpty, true);
      expect(alerts.first.risk, InteractionRisk.severe);
      expect(alerts.first.titleBangla.contains('দ্বৈত ব্যথানাশক'), true);
    });

    test('InteractionService detects Levothyroxine and Calcium/Iron chelation block', () {
      const thyrox = Medicine(
        brandName: 'Thyrox',
        generic: 'Levothyroxine Sodium',
        manufacturer: 'Popular',
        strength: '50 mcg',
        dosageForm: 'Tablet',
        dosage: '',
        sideEffects: '',
      );

      const calbo = Medicine(
        brandName: 'Calbo-D',
        generic: 'Calcium Carbonate + Vitamin D3',
        manufacturer: 'Square',
        strength: '500 mg',
        dosageForm: 'Tablet',
        dosage: '',
        sideEffects: '',
      );

      final alerts = InteractionService.instance.analyzeInteractions([thyrox, calbo]);
      expect(alerts.isNotEmpty, true);
      expect(alerts.first.risk, InteractionRisk.severe);
      expect(alerts.first.titleBangla.contains('থাইরক্সিন'), true);
    });

    test('InteractionService detects Nitrate and Sildenafil fatal hypotension risk', () {
      const angispray = Medicine(
        brandName: 'Angispray',
        generic: 'Nitroglycerin',
        manufacturer: 'Square',
        strength: '0.4 mg',
        dosageForm: 'Sublingual Spray',
        dosage: '',
        sideEffects: '',
      );

      const vigorex = Medicine(
        brandName: 'Vigorex',
        generic: 'Sildenafil Citrate',
        manufacturer: 'Square',
        strength: '50 mg',
        dosageForm: 'Tablet',
        dosage: '',
        sideEffects: '',
      );

      final alerts = InteractionService.instance.analyzeInteractions([angispray, vigorex]);
      expect(alerts.isNotEmpty, true);
      expect(alerts.first.risk, InteractionRisk.severe);
      expect(alerts.first.titleBangla.contains('মারাত্মক রক্তচাপ পতন'), true);
    });

    test('InteractionService returns empty alerts for safe drug combination', () {
      const napa = Medicine(
        brandName: 'Napa',
        generic: 'Paracetamol',
        manufacturer: 'Beximco',
        strength: '500 mg',
        dosageForm: 'Tablet',
        dosage: '',
        sideEffects: '',
      );

      const seclo = Medicine(
        brandName: 'Seclo',
        generic: 'Omeprazole',
        manufacturer: 'Square',
        strength: '20 mg',
        dosageForm: 'Capsule',
        dosage: '',
        sideEffects: '',
      );

      final alerts = InteractionService.instance.analyzeInteractions([napa, seclo]);
      expect(alerts.isEmpty, true);
    });

    test('LabTestsData correctly calculates Platelet and Creatinine status', () {
      final plateletTest = LabTestsData.tests.firstWhere((t) => t.id == 'platelet');
      expect(plateletTest.evaluate(35000).status, LabStatus.critical);
      expect(plateletTest.evaluate(120000).status, LabStatus.borderline);
      expect(plateletTest.evaluate(220000).status, LabStatus.normal);

      final creatinineTest = LabTestsData.tests.firstWhere((t) => t.id == 'creatinine');
      expect(creatinineTest.evaluate(0.9).status, LabStatus.normal);
      expect(creatinineTest.evaluate(1.6).status, LabStatus.borderline);
      expect(creatinineTest.evaluate(2.5).status, LabStatus.critical);
    });

    test('EmergencyData contains essential national contacts and first aid guides', () {
      expect(EmergencyData.nationalHotlines.any((c) => c.number == '999'), true);
      expect(EmergencyData.nationalHotlines.any((c) => c.number == '16263'), true);
      expect(EmergencyData.verifiedBloodBanks.isNotEmpty, true);
      expect(EmergencyData.firstAidGuides.any((g) => g.titleBangla.contains('পোড়া')), true);
      expect(EmergencyData.firstAidGuides.any((g) => g.titleBangla.contains('স্ট্রোক')), true);
    });
  });
}
