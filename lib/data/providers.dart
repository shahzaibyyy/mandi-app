import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local/hive_service.dart';
import 'models/app_settings.dart';
import 'models/fee_type.dart';
import 'models/market.dart';
import 'models/receipt.dart';
import 'repositories/fee_type_repository.dart';
import 'repositories/market_repository.dart';
import 'repositories/receipt_repository.dart';
import 'repositories/settings_repository.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService.instance;
});

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MarketRepository(ref.watch(hiveServiceProvider));
});

final feeTypeRepositoryProvider = Provider<FeeTypeRepository>((ref) {
  return FeeTypeRepository(ref.watch(hiveServiceProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(hiveServiceProvider));
});

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository(
    ref.watch(hiveServiceProvider),
    ref.watch(settingsRepositoryProvider),
  );
});

class MarketsController extends Notifier<List<Market>> {
  MarketRepository get _repo => ref.read(marketRepositoryProvider);

  @override
  List<Market> build() => _repo.getAll();

  void reload() => state = _repo.getAll();

  Future<void> save(Market market) async {
    await _repo.save(market);
    reload();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    reload();
  }
}

final marketsControllerProvider =
    NotifierProvider<MarketsController, List<Market>>(MarketsController.new);

class FeeTypesController extends Notifier<List<FeeType>> {
  FeeTypeRepository get _repo => ref.read(feeTypeRepositoryProvider);

  @override
  List<FeeType> build() => _repo.getAll();

  void reload() => state = _repo.getAll();

  List<FeeType> forMarket(String? marketId) =>
      _repo.forMarket(marketId, activeOnly: true);

  Future<void> save(FeeType feeType) async {
    await _repo.save(feeType);
    reload();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    reload();
  }
}

final feeTypesControllerProvider =
    NotifierProvider<FeeTypesController, List<FeeType>>(FeeTypesController.new);

class ReceiptsController extends Notifier<List<Receipt>> {
  ReceiptRepository get _repo => ref.read(receiptRepositoryProvider);

  @override
  List<Receipt> build() => _repo.getAll();

  void reload() => state = _repo.getAll();

  Receipt? byId(String id) => _repo.getById(id);

  Future<Receipt> create(Receipt receipt) async {
    final saved = await _repo.create(receipt);
    reload();
    return saved;
  }

  Future<void> markPrinted(String id) async {
    await _repo.markPrinted(id);
    reload();
  }
}

final receiptsControllerProvider =
    NotifierProvider<ReceiptsController, List<Receipt>>(ReceiptsController.new);

final receiptByIdProvider = Provider.family<Receipt?, String>((ref, id) {
  ref.watch(receiptsControllerProvider);
  return ref.watch(receiptRepositoryProvider).getById(id);
});

class SettingsController extends Notifier<AppSettings> {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  AppSettings build() => _repo.get();

  void reload() => state = _repo.get();

  Future<void> save(AppSettings settings) async {
    await _repo.save(settings);
    reload();
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
