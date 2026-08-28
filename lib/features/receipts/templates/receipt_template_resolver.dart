import 'receipt_template.dart';
import 'receipt_template_v1.dart';
import 'receipt_template_v2.dart';

ReceiptTemplate resolveTemplate(String version) {
  return switch (version) {
    'v2' => ReceiptTemplateV2(),
    _ => ReceiptTemplateV1(),
  };
}
