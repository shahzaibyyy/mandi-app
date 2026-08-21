import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _format = NumberFormat.currency(
    locale: 'en_PK',
    symbol: '${AppConstants.currencySymbol} ',
    decimalDigits: 2,
  );

  static final NumberFormat _plain = NumberFormat('#,##0.00', 'en_PK');

  static String format(num value) => _format.format(value);

  static String plain(num value) => _plain.format(value);
}