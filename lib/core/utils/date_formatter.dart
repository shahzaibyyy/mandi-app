import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _date = DateFormat('dd MMM yyyy');
  static final DateFormat _receipt = DateFormat('dd/MM/yyyy hh:mm a');
  static final DateFormat _dayKey = DateFormat('yyyy-MM-dd');

  static String dateTime(DateTime value) => _dateTime.format(value);

  static String date(DateTime value) => _date.format(value);

  static String receiptDateTime(DateTime value) => _receipt.format(value);

  static String dayKey(DateTime value) => _dayKey.format(value);

  static bool isSameDay(DateTime a, DateTime b) => dayKey(a) == dayKey(b);
}