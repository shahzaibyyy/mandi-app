import 'package:flutter_test/flutter_test.dart';

import 'package:mandi_fee_collector/core/utils/receipt_number_generator.dart';

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
}