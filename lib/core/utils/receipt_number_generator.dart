class ReceiptNumberGenerator {
  ReceiptNumberGenerator._();

  static String format({
    required String prefix,
    required int sequence,
    required int padWidth,
  }) {
    final padded = sequence.toString().padLeft(padWidth, '0');
    return '$prefix$padded';
  }
}