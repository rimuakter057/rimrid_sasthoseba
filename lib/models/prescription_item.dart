import 'medicine.dart';

class PrescriptionItem {
  final String rawText;
  Medicine? matchedMedicine;
  String frequency; // e.g. "১ + ০ + ১" or "1 + 0 + 1"
  String mealTiming; // e.g. "খাবার পরে" / "খাবার আগে"
  String duration; // e.g. "৭ দিন" / "14 days"
  String indication; // e.g. "জ্বর ও মাথাব্যথা" / "গ্যাস্ট্রিক ও এসিডিটি"

  PrescriptionItem({
    required this.rawText,
    this.matchedMedicine,
    this.frequency = '',
    this.mealTiming = '',
    this.duration = '',
    this.indication = '',
  });

  bool get hasMatchedMedicine => matchedMedicine != null;

  String get displayName => matchedMedicine != null
      ? matchedMedicine!.displayNameWithStrength
      : rawText;
}
