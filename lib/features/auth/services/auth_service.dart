import '../../../core/constants/app_constants.dart';
import '../../../core/services/device_id_service.dart';
import '../../../data/repositories/settings_repository.dart';

enum AuthFailure {
  invalidCredentials,
  deviceAlreadyRegistered,
}

class AuthResult {
  const AuthResult.success() : failure = null;

  const AuthResult.failure(this.failure);

  final AuthFailure? failure;

  bool get ok => failure == null;
}

class AuthService {
  AuthService(this._settings, {DeviceIdService? deviceId})
    : _deviceId = deviceId ?? DeviceIdService.instance;

  final SettingsRepository _settings;
  final DeviceIdService _deviceId;

  bool get isLoggedIn => _settings.get().isLoggedIn;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail != AppConstants.loginEmail ||
        password != AppConstants.loginPassword) {
      return const AuthResult.failure(AuthFailure.invalidCredentials);
    }

    final current = _settings.get();
    final device = await _deviceId.getId();
    final bound = current.boundDeviceId;

    if (bound != null && bound != device) {
      return const AuthResult.failure(AuthFailure.deviceAlreadyRegistered);
    }

    await _settings.save(
      current.copyWith(
        isLoggedIn: true,
        boundDeviceId: bound ?? device,
      ),
    );
    return const AuthResult.success();
  }

  Future<void> logout() async {
    final current = _settings.get();
    await _settings.save(current.copyWith(isLoggedIn: false));
  }
}
