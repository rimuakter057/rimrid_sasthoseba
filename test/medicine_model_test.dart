import 'package:flutter_test/flutter_test.dart';
import 'package:rimrid_sasthoseba/models/medicine.dart';
import 'package:rimrid_sasthoseba/services/database_helper.dart';

void main() {
  group('Medicine Model Tests', () {
    test('Medicine fromMap and toMap serialize correctly', () {
      final map = {
        'id': 1,
        'brand_name': 'Napa',
        'generic': 'Paracetamol',
        'manufacturer': 'Beximco Pharmaceuticals Ltd.',
        'strength': '500 mg',
        'dosage_form': 'Tablet',
        'dosage': '১-২ টি ট্যাবলেট প্রতি ৪-৬ ঘণ্টা পরপর',
        'side_effects': 'পার্শ্বপ্রতিক্রিয়া সাধারণত মৃদু',
      };

      final med = Medicine.fromMap(map);
      expect(med.id, 1);
      expect(med.brandName, 'Napa');
      expect(med.generic, 'Paracetamol');
      expect(med.manufacturer, 'Beximco Pharmaceuticals Ltd.');
      expect(med.strength, '500 mg');
      expect(med.dosageForm, 'Tablet');
      expect(med.dosage, '১-২ টি ট্যাবলেট প্রতি ৪-৬ ঘণ্টা পরপর');
      expect(med.sideEffects, 'পার্শ্বপ্রতিক্রিয়া সাধারণত মৃদু');
      expect(med.displayNameWithStrength, 'Napa (500 mg)');

      final outMap = med.toMap();
      expect(outMap['brand_name'], 'Napa');
      expect(outMap['generic'], 'Paracetamol');
    });

    test('cleanHtml handles HTML formatting and entities', () {
      const rawHtml = '<div class="body"><p>Adult: <strong>1 tablet</strong></p><br/><ul><li>With food</li></ul>&amp; &lt;safe&gt;</div>';
      final cleaned = DatabaseHelper.cleanHtml(rawHtml);
      expect(cleaned.contains('<div'), false);
      expect(cleaned.contains('<strong>'), false);
      expect(cleaned.contains('&amp;'), false);
      expect(cleaned.contains('&'), true);
      expect(cleaned.contains('• With food'), true);
    });
  });
}
