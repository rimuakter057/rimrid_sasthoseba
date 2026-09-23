class Medicine {
  final int? id;
  final String brandName;
  final String generic;
  final String manufacturer;
  final String strength;
  final String dosageForm;
  final String dosage;
  final String sideEffects;

  const Medicine({
    this.id,
    required this.brandName,
    required this.generic,
    required this.manufacturer,
    required this.strength,
    required this.dosageForm,
    required this.dosage,
    required this.sideEffects,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand_name': brandName,
      'generic': generic,
      'manufacturer': manufacturer,
      'strength': strength,
      'dosage_form': dosageForm,
      'dosage': dosage,
      'side_effects': sideEffects,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] as int?,
      brandName: (map['brand_name'] as String?)?.trim() ?? '',
      generic: (map['generic'] as String?)?.trim() ?? '',
      manufacturer: (map['manufacturer'] as String?)?.trim() ?? '',
      strength: (map['strength'] as String?)?.trim() ?? '',
      dosageForm: (map['dosage_form'] as String?)?.trim() ?? '',
      dosage: (map['dosage'] as String?)?.trim() ?? '',
      sideEffects: (map['side_effects'] as String?)?.trim() ?? '',
    );
  }

  /// Helper getter for displaying a clean title with strength
  String get displayNameWithStrength {
    if (strength.isNotEmpty) {
      return '$brandName ($strength)';
    }
    return brandName;
  }
}
