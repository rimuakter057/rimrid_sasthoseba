import 'package:flutter_test/flutter_test.dart';
import 'package:rimrid_sasthoseba/data/lab_tests_data.dart';
import 'package:rimrid_sasthoseba/services/lab_report_parser_service.dart';

void main() {
  group('LabReportParserService Tests', () {
    test('Correctly extracts and evaluates parameters from Bangladeshi lab report text', () {
      const samplePopularReport = '''
POPULAR DIAGNOSTIC CENTRE LTD.
DHAKA, BANGLADESH
HAEMATOLOGY & CLINICAL BIOCHEMISTRY REPORT
---------------------------------------------------------------
TEST NAME                         RESULT    UNIT      NORMAL RANGE
Total Platelet Count (PLT)        45,000    /uL       (150,000 - 450,000)
Hemoglobin (Hb)                   7.8       g/dL      (12.0 - 16.5)
Total Leucocyte Count (WBC)       16,500    /uL       (4,000 - 11,000)
Serum Creatinine                  2.1       mg/dL     (0.6 - 1.2)
S. Bilirubin (Total)              2.5       mg/dL     (0.2 - 1.2)
SGPT (ALT)                        72        U/L       (Up to 40)
HbA1c                             8.5       %         (4.0 - 5.6)
Fasting Blood Sugar (FBS)         8.4       mmol/L    (3.9 - 6.1)
Serum Uric Acid                   8.6       mg/dL     (3.4 - 7.0)
Total Cholesterol                 245       mg/dL     (< 200)
TSH                               7.2       uIU/mL    (0.4 - 4.2)
---------------------------------------------------------------
Report Verified by Consultant Pathologist
''';

      final result = LabReportParserService.instance.parseReportFromText(samplePopularReport);

      expect(result.matchedItems.isNotEmpty, isTrue);

      // Platelet check (45000 -> critical low)
      final plt = result.matchedItems.firstWhere((item) => item.definition.id == 'platelet');
      expect(plt.detectedValue, 45000.0);
      expect(plt.evaluation.status, LabStatus.critical);

      // Hemoglobin check (7.8 -> critical low severe anemia)
      final hb = result.matchedItems.firstWhere((item) => item.definition.id == 'hemoglobin');
      expect(hb.detectedValue, 7.8);
      expect(hb.evaluation.status, LabStatus.critical);

      // Creatinine check (2.1 -> critical high)
      final cr = result.matchedItems.firstWhere((item) => item.definition.id == 'creatinine');
      expect(cr.detectedValue, 2.1);
      expect(cr.evaluation.status, LabStatus.critical);

      // SGPT check (72 -> borderline/high)
      final sgpt = result.matchedItems.firstWhere((item) => item.definition.id == 'sgpt');
      expect(sgpt.detectedValue, 72.0);
      expect(sgpt.evaluation.status, LabStatus.borderline);

      // HbA1c check (8.5 -> critical/uncontrolled)
      final hba1c = result.matchedItems.firstWhere((item) => item.definition.id == 'hba1c');
      expect(hba1c.detectedValue, 8.5);

      expect(result.criticalCount > 0, isTrue);
    });

    test('Normal report evaluates with all normal status', () {
      const sampleNormalReport = '''
IBN SINA MEDICAL LAB
Hemoglobin 14.2 g/dL (12 - 16.5)
Platelet Count 250,000 /uL (150,000 - 450,000)
Serum Creatinine 0.9 mg/dL (0.6 - 1.2)
SGPT 28 U/L (Up to 40)
HbA1c 5.2 % (4.0 - 5.6)
''';

      final result = LabReportParserService.instance.parseReportFromText(sampleNormalReport);

      expect(result.matchedItems.length, 5);
      expect(result.criticalCount, 0);
      expect(result.borderlineCount, 0);
      expect(result.normalCount, 5);
    });

    test('Converts Blood Sugar in mg/dL to mmol/L', () {
      const sampleSugarReport = '''
LABAID DIAGNOSTICS
Fasting Blood Sugar (FBS) 144 mg/dL
''';

      final result = LabReportParserService.instance.parseReportFromText(sampleSugarReport);
      expect(result.matchedItems.length, 1);
      final fbs = result.matchedItems.first;
      // 144 / 18 = 8.0 mmol/L -> >= 7.0 is diagnostic of Diabetes (critical)
      expect(fbs.detectedValue, 8.0);
      expect(fbs.evaluation.status, LabStatus.critical);

      // Also test pre-diabetes range (e.g. 117 mg/dL = 6.5 mmol/L -> borderline)
      const samplePreDiabetes = 'Fasting Blood Sugar: 117 mg/dL';
      final preResult = LabReportParserService.instance.parseReportFromText(samplePreDiabetes);
      expect(preResult.matchedItems.first.detectedValue, 6.5);
      expect(preResult.matchedItems.first.evaluation.status, LabStatus.borderline);
    });
  });
}
