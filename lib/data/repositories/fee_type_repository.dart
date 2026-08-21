import '../local/hive_service.dart';
import '../models/fee_type.dart';

class FeeTypeRepository {
  FeeTypeRepository(this._hive);

  final HiveService _hive;

  List<FeeType> getAll() {
    final items = _hive.feeTypesBox.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return items;
  }

  List<FeeType> forMarket(String? marketId, {bool activeOnly = true}) {
    return getAll().where((fee) {
      if (activeOnly && !fee.isActive) return false;
      if (fee.marketId == null) return true;
      if (marketId == null) return true;
      return fee.marketId == marketId;
    }).toList();
  }

  FeeType? getById(String id) => _hive.feeTypesBox.get(id);

  Future<void> save(FeeType feeType) async {
    await _hive.feeTypesBox.put(feeType.id, feeType);
  }

  Future<void> delete(String id) async {
    await _hive.feeTypesBox.delete(id);
  }
}