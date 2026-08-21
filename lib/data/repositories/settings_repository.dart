import '../../core/constants/app_constants.dart';
import '../local/hive_service.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._hive);

  final HiveService _hive;

  AppSettings get() {
    return _hive.settingsBox.get(AppConstants.settingsKey) ??
        AppSettings.defaults();
  }

  Future<void> save(AppSettings settings) async {
    await _hive.settingsBox.put(AppConstants.settingsKey, settings);
  }
}