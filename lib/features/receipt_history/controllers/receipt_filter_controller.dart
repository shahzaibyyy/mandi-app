import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReceiptFilter {
  const ReceiptFilter({
    this.query = '',
    this.marketId,
    this.from,
    this.to,
    this.isPaid,
  });

  final String query;
  final String? marketId;
  final DateTime? from;
  final DateTime? to;
  final bool? isPaid;

  ReceiptFilter copyWith({
    String? query,
    String? marketId,
    bool clearMarket = false,
    DateTime? from,
    bool clearFrom = false,
    DateTime? to,
    bool clearTo = false,
    bool? isPaid,
    bool clearPaid = false,
  }) {
    return ReceiptFilter(
      query: query ?? this.query,
      marketId: clearMarket ? null : (marketId ?? this.marketId),
      from: clearFrom ? null : (from ?? this.from),
      to: clearTo ? null : (to ?? this.to),
      isPaid: clearPaid ? null : (isPaid ?? this.isPaid),
    );
  }
}

class ReceiptFilterController extends Notifier<ReceiptFilter> {
  @override
  ReceiptFilter build() => const ReceiptFilter();

  void setQuery(String value) => state = state.copyWith(query: value);

  void setMarket(String? id) =>
      state = state.copyWith(marketId: id, clearMarket: id == null);

  void setFrom(DateTime? value) =>
      state = state.copyWith(from: value, clearFrom: value == null);

  void setTo(DateTime? value) =>
      state = state.copyWith(to: value, clearTo: value == null);

  void setPaid(bool? value) =>
      state = state.copyWith(isPaid: value, clearPaid: value == null);

  void clear() => state = const ReceiptFilter();
}

final receiptFilterControllerProvider =
    NotifierProvider.autoDispose<ReceiptFilterController, ReceiptFilter>(
      ReceiptFilterController.new,
    );
