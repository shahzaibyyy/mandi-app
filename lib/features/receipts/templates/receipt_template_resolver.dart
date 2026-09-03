import 'receipt_template.dart';
import 'receipt_template_v1.dart';
import 'receipt_template_v2.dart';
import 'receipt_template_v3.dart';
import 'receipt_template_v4.dart';
import 'receipt_template_v5.dart';

ReceiptTemplate resolveTemplate(String version) {
  return switch (version) {
    'v5' => ReceiptTemplateV5(),
    'v4' => ReceiptTemplateV4(),
    'v3' => ReceiptTemplateV3(),
    'v2' => ReceiptTemplateV2(),
    _ => ReceiptTemplateV1(),
  };
}
