import '../local/hive_service.dart';
import '../models/market.dart';

class MarketRepository {
  MarketRepository(this._hive);

  final HiveService _hive;

  List<Market> getAll() {
    final items = _hive.marketsBox.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return items;
  }

  Market? getById(String id) => _hive.marketsBox.get(id);

  Future<void> save(Market market) async {
    await _hive.marketsBox.put(market.id, market);
  }

  Future<void> delete(String id) async {
    await _hive.marketsBox.delete(id);
  }
}