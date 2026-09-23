import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rimrid_sasthoseba/models/medicine.dart';
import 'package:rimrid_sasthoseba/services/prescription_parser_service.dart';

void main() {
  setUpAll(() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  });

  group('PrescriptionParserService Tests', () {
    final parser = PrescriptionParserService.instance;

    test('extractFrequency extracts english, bengali and word patterns', () {
      expect(parser.extractFrequency('Tab. Napa 500mg 1+0+1'), '১ + ০ + ১ (দিনে ২ বার — সকালে ১টি ও রাতে ১টি)');
      expect(parser.extractFrequency('Cap. Seclo 20mg 1 - 0 - 1'), '১ + ০ + ১ (দিনে ২ বার — সকালে ১টি ও রাতে ১টি)');
      expect(parser.extractFrequency('Tab. Monas 10mg ০+০+১'), '০ + ০ + ১ (দিনে ১ বার — শুধুমাত্র রাতে ১টি)');
      expect(parser.extractFrequency('১+১+১ ভরা পেটে'), '১ + ১ + ১ (দিনে ৩ বার — সকাল, দুপুর ও রাতে ১টি করে)');
      expect(parser.extractFrequency('২ চামচ করে দিনে ৩ বার'), '১ + ১ + ১ (দিনে ৩ বার — সকাল, দুপুর ও রাতে)');
      expect(parser.extractFrequency('Take once daily in morning'), '১ + ০ + ০ (দিনে ১ বার — সকালে)');
      expect(parser.extractFrequency('Take at bedtime'), '০ + ০ + ১ (দিনে ১ বার — রাতে ঘুমানোর আগে)');
    });

    test('extractMealTiming detects meal instructions accurately', () {
      expect(parser.extractMealTiming('খাবার ২০ মিনিট আগে খাবেন'), 'খাবার ২০-৩০ মিনিট আগে');
      expect(parser.extractMealTiming('খালি পেটে সেব্য'), 'খাবার ২০-৩০ মিনিট আগে');
      expect(parser.extractMealTiming('1+0+1 before meal'), 'খাবার ২০-৩০ মিনিট আগে');
      expect(parser.extractMealTiming('১+০+১ খাবার পরে'), 'খাবার পরে (ভরা পেটে)');
      expect(parser.extractMealTiming('ভরা পেটে খাবেন'), 'খাবার পরে (ভরা পেটে)');
      expect(parser.extractMealTiming('after meal with water'), 'খাবার পরে (ভরা পেটে)');
    });

    test('extractDuration extracts prescription durations', () {
      expect(parser.extractDuration('৭ দিন চলবে'), '৭ দিন');
      expect(parser.extractDuration('for 14 days'), '14 days');
      expect(parser.extractDuration('১ মাস খাবেন'), '১ মাস');
      expect(parser.extractDuration('নিয়মিত চলবে continue'), 'নিয়মিত চলবে (Continue)');
    });

    test('extractMedicineNameCandidate cleans prefixes and strengths', () {
      expect(parser.extractMedicineNameCandidate('1. Tab. Napa Extra 500mg 1+0+1'), 'Napa Extra');
      expect(parser.extractMedicineNameCandidate('Cap. Seclo 20mg - 1+0+1'), 'Seclo');
      expect(parser.extractMedicineNameCandidate('Rx: Tab Monas 10mg'), 'Monas');
      expect(parser.extractMedicineNameCandidate('Syp. Tusca 100ml'), 'Tusca');
      expect(parser.extractMedicineNameCandidate('2) Tab. Ace Plus'), 'Ace Plus');
    });

    test('determineIndication returns correct indication in Bengali', () {
      const napa = Medicine(
        brandName: 'Napa',
        generic: 'Paracetamol',
        manufacturer: 'Beximco',
        strength: '500 mg',
        dosageForm: 'Tablet',
        dosage: '',
        sideEffects: '',
      );
      expect(parser.determineIndication(napa), 'জ্বর, সর্দি, মাথাব্যথা ও সাধারণ শরীর ব্যথা');

      const seclo = Medicine(
        brandName: 'Seclo',
        generic: 'Omeprazole',
        manufacturer: 'Square',
        strength: '20 mg',
        dosageForm: 'Capsule',
        dosage: '',
        sideEffects: '',
      );
      expect(parser.determineIndication(seclo), 'গ্যাস্ট্রিক, এসিডিটি, বুক জ্বালাপোড়া ও পেটের আলসার');

      const monas = Medicine(
        brandName: 'Monas',
        generic: 'Montelukast',
        manufacturer: 'Acme',
        strength: '10 mg',
        dosageForm: 'Tablet',
        dosage: '',
        sideEffects: '',
      );
      expect(parser.determineIndication(monas), 'অ্যাজমা, শ্বাসকষ্ট, হাঁপানি ও ক্রনিক এলার্জি');
    });
  });
}
