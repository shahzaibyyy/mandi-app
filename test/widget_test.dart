import 'package:flutter_test/flutter_test.dart';

import 'package:mandi_fee_collector/core/constants/app_constants.dart';
import 'package:mandi_fee_collector/core/utils/receipt_number_generator.dart';
import 'package:mandi_fee_collector/features/receipts/templates/receipt_template_resolver.dart';
import 'package:mandi_fee_collector/features/receipts/templates/receipt_template_v1.dart';
import 'package:mandi_fee_collector/features/receipts/templates/receipt_template_v2.dart';
import 'package:mandi_fee_collector/features/receipts/templates/receipt_template_v3.dart';
import 'package:mandi_fee_collector/features/receipts/templates/receipt_template_v4.dart';
import 'package:mandi_fee_collector/features/receipts/templates/receipt_template_v5.dart';

void main() {
  test('receipt numbers are sequential and zero-padded', () {
    expect(
      ReceiptNumberGenerator.format(
        prefix: 'MND-',
        sequence: 1,
        padWidth: 6,
      ),
      'MND-000001',
    );
    expect(
      ReceiptNumberGenerator.format(
        prefix: 'MND-',
        sequence: 42,
        padWidth: 6,
      ),
      'MND-000042',
    );
  });

  test('resolveTemplate keeps v1-v4 and adds v5', () {
    expect(resolveTemplate('v1'), isA<ReceiptTemplateV1>());
    expect(resolveTemplate('v2'), isA<ReceiptTemplateV2>());
    expect(resolveTemplate('v3'), isA<ReceiptTemplateV3>());
    expect(resolveTemplate('v4'), isA<ReceiptTemplateV4>());
    expect(resolveTemplate('v5'), isA<ReceiptTemplateV5>());
    expect(resolveTemplate('unknown'), isA<ReceiptTemplateV1>());
  });

  test('contractor display name stays سید تحریم عباس when empty', () {
    expect(
      AppConstants.contractorDisplayName(null),
      AppConstants.defaultContractorName,
    );
    expect(
      AppConstants.contractorDisplayName(''),
      AppConstants.defaultContractorName,
    );
    expect(
      AppConstants.contractorDisplayName('  '),
      AppConstants.defaultContractorName,
    );
    expect(AppConstants.contractorDisplayName('Nasir Khan'), 'Nasir Khan');
    expect(
      AppConstants.defaultContractorName,
      'سید تحریم عباس',
    );
  });
}
