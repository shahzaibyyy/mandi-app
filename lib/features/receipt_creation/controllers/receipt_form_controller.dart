import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/gps_capture.dart';
import '../../../data/models/fee_type.dart';
import '../../../data/models/market.dart';
import '../../../data/models/receipt.dart';
import '../../../data/models/receipt_line_item.dart';
import '../../../data/providers.dart';
import '../../license/controllers/license_controller.dart';

class DraftLineItem {
  DraftLineItem({
    required this.id,
    this.feeTypeId,
    required this.feeTypeName,
    required this.unitLabel,
    required this.quantity,
    required this.unitRate,
  });

  final String id;
  final String? feeTypeId;
  final String feeTypeName;
  final String unitLabel;
  final double quantity;
  final double unitRate;

  double get amount => quantity * unitRate;

  DraftLineItem copyWith({
    String? feeTypeId,
    bool clearFeeTypeId = false,
    String? feeTypeName,
    String? unitLabel,
    double? quantity,
    double? unitRate,
  }) {
    return DraftLineItem(
      id: id,
      feeTypeId: clearFeeTypeId ? feeTypeId : (feeTypeId ?? this.feeTypeId),
      feeTypeName: feeTypeName ?? this.feeTypeName,
      unitLabel: unitLabel ?? this.unitLabel,
      quantity: quantity ?? this.quantity,
      unitRate: unitRate ?? this.unitRate,
    );
  }

  ReceiptLineItem toEmbedded() {
    return ReceiptLineItem(
      feeTypeId: feeTypeId,
      feeTypeName: feeTypeName,
      unitLabel: unitLabel,
      quantity: quantity,
      unitRate: unitRate,
      amount: amount,
    );
  }
}

class ReceiptFormState {
  ReceiptFormState({
    this.marketId,
    this.receiverName = '',
    this.contractorName = '',
    this.lineItems = const [],
    this.isPaid = true,
    this.taxPercent = 16,
    this.isSaving = false,
    this.error,
  });

  final String? marketId;
  final String receiverName;
  final String contractorName;
  final List<DraftLineItem> lineItems;
  final bool isPaid;
  final double taxPercent;
  final bool isSaving;
  final String? error;

  double get subtotal =>
      lineItems.fold<double>(0, (sum, item) => sum + item.amount);

  double get taxAmount => subtotal * taxPercent / 100;

  double get total => subtotal + taxAmount;

  ReceiptFormState copyWith({
    String? marketId,
    bool clearMarketId = false,
    String? receiverName,
    String? contractorName,
    List<DraftLineItem>? lineItems,
    bool? isPaid,
    double? taxPercent,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return ReceiptFormState(
      marketId: clearMarketId ? marketId : (marketId ?? this.marketId),
      receiverName: receiverName ?? this.receiverName,
      contractorName: contractorName ?? this.contractorName,
      lineItems: lineItems ?? this.lineItems,
      isPaid: isPaid ?? this.isPaid,
      taxPercent: taxPercent ?? this.taxPercent,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ReceiptFormController extends Notifier<ReceiptFormState> {
  static const _uuid = Uuid();

  ReceiptFormState _initialState() {
    final settings = ref.read(settingsControllerProvider);
    final markets = ref.read(marketsControllerProvider);
    String? marketId = settings.defaultMarketId;
    if (marketId != null &&
        markets.every((market) => market.id != marketId)) {
      marketId = null;
    }
    marketId ??= markets.isEmpty ? null : markets.first.id;
    return ReceiptFormState(
      marketId: marketId,
      receiverName: settings.defaultReceiverName ?? '',
      taxPercent: settings.defaultTaxPercent,
      isPaid: true,
    );
  }

  @override
  ReceiptFormState build() => _initialState();

  void hydrateFromSettings() {
    state = _initialState();
  }

  void setMarket(String? id) {
    state = state.copyWith(marketId: id, clearMarketId: id == null);
  }

  void setReceiverName(String value) {
    state = state.copyWith(receiverName: value);
  }

  void setContractorName(String value) {
    state = state.copyWith(contractorName: value);
  }

  void setPaid(bool value) {
    state = state.copyWith(isPaid: value);
  }

  void addLineItem({FeeType? feeType}) {
    final item = DraftLineItem(
      id: _uuid.v4(),
      feeTypeId: feeType?.id,
      feeTypeName: feeType?.name ?? '',
      unitLabel: feeType?.unitLabel ?? '',
      quantity: 1,
      unitRate: feeType?.defaultRate ?? 0,
    );
    state = state.copyWith(lineItems: [...state.lineItems, item]);
  }

  void updateLineItem(DraftLineItem item) {
    state = state.copyWith(
      lineItems: [
        for (final existing in state.lineItems)
          if (existing.id == item.id) item else existing,
      ],
    );
  }

  void applyFeeType(String lineId, FeeType feeType) {
    final items = [
      for (final item in state.lineItems)
        if (item.id == lineId)
          item.copyWith(
            feeTypeId: feeType.id,
            feeTypeName: feeType.name,
            unitLabel: feeType.unitLabel,
            unitRate: feeType.defaultRate,
          )
        else
          item,
    ];
    state = state.copyWith(lineItems: items);
  }

  void removeLineItem(String id) {
    state = state.copyWith(
      lineItems: state.lineItems.where((item) => item.id != id).toList(),
    );
  }

  String? validate(List<Market> markets) {
    if (markets.isEmpty) return 'Add a market before creating a receipt.';
    if (state.marketId == null) return 'Select a market.';
    if (state.receiverName.trim().isEmpty) return 'Receiver name is required.';
    if (state.lineItems.isEmpty) {
      return 'Add at least one fee line item.';
    }
    for (final item in state.lineItems) {
      if (item.feeTypeName.trim().isEmpty) {
        return 'Each line item needs a fee type.';
      }
      if (item.quantity <= 0) return 'Quantity must be greater than zero.';
      if (item.unitRate < 0) return 'Unit rate cannot be negative.';
    }
    return null;
  }

  Future<Receipt> save() async {
    final markets = ref.read(marketsControllerProvider);
    final validationError = validate(markets);
    if (validationError != null) {
      throw Exception(validationError);
    }

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final gps = await GpsCapture.capture();
      final market = markets.firstWhere((m) => m.id == state.marketId);
      final receipt = Receipt(
        id: _uuid.v4(),
        receiptNumber: '',
        marketId: market.id,
        marketNameSnapshot: market.name,
        receiverName: state.receiverName.trim(),
        contractorName: state.contractorName.trim().isEmpty
            ? null
            : state.contractorName.trim(),
        lineItems: state.lineItems.map((item) => item.toEmbedded()).toList(),
        subtotal: state.subtotal,
        taxPercent: state.taxPercent,
        taxAmount: state.taxAmount,
        totalAmount: state.total,
        isPaid: state.isPaid,
        latitude: gps.latitude,
        longitude: gps.longitude,
        createdAt: DateTime.now(),
      );
      final saved = await ref
          .read(receiptsControllerProvider.notifier)
          .create(receipt);
      await ref.read(licenseControllerProvider.notifier).recordReceiptActivity();
      state = state.copyWith(isSaving: false);
      return saved;
    } catch (error) {
      state = state.copyWith(isSaving: false, error: error.toString());
      rethrow;
    }
  }
}

final receiptFormControllerProvider =
    NotifierProvider.autoDispose<ReceiptFormController, ReceiptFormState>(
      ReceiptFormController.new,
    );
