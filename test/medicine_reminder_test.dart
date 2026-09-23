import 'package:flutter_test/flutter_test.dart';
import 'package:rimrid_sasthoseba/models/medicine_reminder.dart';

void main() {
  group('MedicineReminder Tests', () {
    test('MedicineReminder serializes toMap and fromMap accurately', () {
      const reminder = MedicineReminder(
        id: 1,
        medicineName: 'Napa 500mg',
        dosage: '১টি ট্যাবলেট',
        mealTiming: 'খাবারের পরে',
        timeHour: 8,
        timeMinute: 30,
        isMorning: true,
        isNoon: false,
        isNight: false,
        isActive: true,
        lastTakenDate: '2026-09-21',
      );

      final map = reminder.toMap();
      expect(map['id'], 1);
      expect(map['medicine_name'], 'Napa 500mg');
      expect(map['is_morning'], 1);
      expect(map['is_active'], 1);
      expect(map['last_taken_date'], '2026-09-21');

      final fromMap = MedicineReminder.fromMap(map);
      expect(fromMap.id, reminder.id);
      expect(fromMap.medicineName, reminder.medicineName);
      expect(fromMap.dosage, reminder.dosage);
      expect(fromMap.mealTiming, reminder.mealTiming);
      expect(fromMap.timeHour, reminder.timeHour);
      expect(fromMap.timeMinute, reminder.timeMinute);
      expect(fromMap.isMorning, true);
      expect(fromMap.isActive, true);
      expect(fromMap.lastTakenDate, '2026-09-21');
    });

    test('MedicineReminder formattedTime and slotBangla format correctly', () {
      const morningReminder = MedicineReminder(
        medicineName: 'Seclo 20mg',
        dosage: '১টি ক্যাপসুল',
        mealTiming: 'খাবারের আগে',
        timeHour: 7,
        timeMinute: 15,
        isMorning: true,
      );

      expect(morningReminder.formattedTime, '07:15 AM');
      expect(morningReminder.slotBangla, 'সকাল');

      const nightReminder = MedicineReminder(
        medicineName: 'Monas 10mg',
        dosage: '১টি ট্যাবলেট',
        mealTiming: 'রাতে শোবার আগে',
        timeHour: 21,
        timeMinute: 45,
        isNight: true,
      );

      expect(nightReminder.formattedTime, '09:45 PM');
      expect(nightReminder.slotBangla, 'রাত');
    });

    test('MedicineReminder isTakenToday evaluates correctly against current date', () {
      final now = DateTime(2026, 9, 21);

      const takenToday = MedicineReminder(
        medicineName: 'Histacin',
        dosage: '১টি',
        mealTiming: '',
        timeHour: 14,
        timeMinute: 0,
        lastTakenDate: '2026-09-21',
      );

      const notTakenToday = MedicineReminder(
        medicineName: 'Histacin',
        dosage: '১টি',
        mealTiming: '',
        timeHour: 14,
        timeMinute: 0,
        lastTakenDate: '2026-09-20',
      );

      const neverTaken = MedicineReminder(
        medicineName: 'Histacin',
        dosage: '১টি',
        mealTiming: '',
        timeHour: 14,
        timeMinute: 0,
      );

      expect(takenToday.isTakenToday(now), true);
      expect(notTakenToday.isTakenToday(now), false);
      expect(neverTaken.isTakenToday(now), false);
    });
  });
}
