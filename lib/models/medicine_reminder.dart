class MedicineReminder {
  final int? id;
  final String medicineName;
  final String dosage;
  final String mealTiming;
  final int timeHour;
  final int timeMinute;
  final bool isMorning;
  final bool isNoon;
  final bool isNight;
  final bool isActive;
  final String? lastTakenDate;

  const MedicineReminder({
    this.id,
    required this.medicineName,
    required this.dosage,
    required this.mealTiming,
    required this.timeHour,
    required this.timeMinute,
    this.isMorning = false,
    this.isNoon = false,
    this.isNight = false,
    this.isActive = true,
    this.lastTakenDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicine_name': medicineName,
      'dosage': dosage,
      'meal_timing': mealTiming,
      'time_hour': timeHour,
      'time_minute': timeMinute,
      'is_morning': isMorning ? 1 : 0,
      'is_noon': isNoon ? 1 : 0,
      'is_night': isNight ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'last_taken_date': lastTakenDate,
    };
  }

  factory MedicineReminder.fromMap(Map<String, dynamic> map) {
    return MedicineReminder(
      id: map['id'] as int?,
      medicineName: (map['medicine_name'] as String?)?.trim() ?? '',
      dosage: (map['dosage'] as String?)?.trim() ?? '',
      mealTiming: (map['meal_timing'] as String?)?.trim() ?? '',
      timeHour: map['time_hour'] as int? ?? 8,
      timeMinute: map['time_minute'] as int? ?? 0,
      isMorning: (map['is_morning'] as int? ?? 0) == 1,
      isNoon: (map['is_noon'] as int? ?? 0) == 1,
      isNight: (map['is_night'] as int? ?? 0) == 1,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      lastTakenDate: map['last_taken_date'] as String?,
    );
  }

  MedicineReminder copyWith({
    int? id,
    String? medicineName,
    String? dosage,
    String? mealTiming,
    int? timeHour,
    int? timeMinute,
    bool? isMorning,
    bool? isNoon,
    bool? isNight,
    bool? isActive,
    String? lastTakenDate,
  }) {
    return MedicineReminder(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      mealTiming: mealTiming ?? this.mealTiming,
      timeHour: timeHour ?? this.timeHour,
      timeMinute: timeMinute ?? this.timeMinute,
      isMorning: isMorning ?? this.isMorning,
      isNoon: isNoon ?? this.isNoon,
      isNight: isNight ?? this.isNight,
      isActive: isActive ?? this.isActive,
      lastTakenDate: lastTakenDate ?? this.lastTakenDate,
    );
  }

  /// Formatted time string (e.g. 08:30 AM / রাত ০৯:১৫)
  String get formattedTime {
    final period = timeHour >= 12 ? 'PM' : 'AM';
    final hour12 = timeHour == 0 ? 12 : (timeHour > 12 ? timeHour - 12 : timeHour);
    final minuteStr = timeMinute.toString().padLeft(2, '0');
    return '${hour12.toString().padLeft(2, '0')}:$minuteStr $period';
  }

  /// Bengali slot title
  String get slotBangla {
    if (isMorning) return 'সকাল';
    if (isNoon) return 'দুপুর';
    if (isNight) return 'রাত';
    if (timeHour < 12) return 'সকাল';
    if (timeHour < 16) return 'দুপুর';
    if (timeHour < 19) return 'বিকাল';
    return 'রাত';
  }

  bool isTakenToday(DateTime now) {
    if (lastTakenDate == null) return false;
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return lastTakenDate == todayStr;
  }
}
