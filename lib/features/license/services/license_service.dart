import '../../../core/license/device_fingerprint.dart';
import '../../../core/license/license_codec.dart';
import '../../../core/services/device_id_service.dart';
import '../../../data/repositories/settings_repository.dart';

enum LicenseStatus {
  valid,
  missing,
  expired,
  clockTampered,
}

enum LicenseActivationFailure {
  invalidCode,
  wrongDevice,
  notYetValid,
}

class LicenseActivationResult {
  const LicenseActivationResult.success(this.expiresAt) : failure = null;

  const LicenseActivationResult.failure(this.failure) : expiresAt = null;

  final DateTime? expiresAt;
  final LicenseActivationFailure? failure;

  bool get ok => failure == null;
}

class LicenseService {
  LicenseService(this._settings, {DeviceIdService? deviceId})
    : _deviceId = deviceId ?? DeviceIdService.instance;

  final SettingsRepository _settings;
  final DeviceIdService _deviceId;

  LicenseStatus status() {
    final current = _settings.get();
    final now = DateTime.now().toUtc();

    final lastSeen = current.lastSeenTimestampMillis;
    if (lastSeen != null) {
      final lastSeenAt = DateTime.fromMillisecondsSinceEpoch(
        lastSeen,
        isUtc: true,
      );
      if (now.isBefore(lastSeenAt)) {
        return LicenseStatus.clockTampered;
      }
    }

    final expiresMillis = current.licenseExpiresAtMillis;
    if (expiresMillis == null) return LicenseStatus.missing;

    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      expiresMillis,
      isUtc: true,
    );
    if (now.isAfter(expiresAt)) return LicenseStatus.expired;

    return LicenseStatus.valid;
  }

  DateTime? expiresAt() {
    final millis = _settings.get().licenseExpiresAtMillis;
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  Future<String> ensureDeviceFingerprint() async {
    final current = _settings.get();
    final existing = current.deviceFingerprint?.trim();
    if (existing != null && existing.isNotEmpty) return existing;

    final androidId = await _deviceId.getId();
    final fingerprint = DeviceFingerprint.fromAndroidId(androidId);
    await _settings.save(current.copyWith(deviceFingerprint: fingerprint));
    return fingerprint;
  }

  String? storedDeviceFingerprint() =>
      _settings.get().deviceFingerprint?.trim();

  Future<void> recordActivityTimestamp() async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final current = _settings.get();
    final lastSeen = current.lastSeenTimestampMillis;
    if (lastSeen != null && now < lastSeen) return;
    await _settings.save(current.copyWith(lastSeenTimestampMillis: now));
  }

  Future<LicenseActivationResult> activate(String code) async {
    final fingerprint = await ensureDeviceFingerprint();
    try {
      final decoded = LicenseCodec.decodeSigned(code);
      final validSig = await LicenseCodec.verifySignature(
        payload: decoded.payloadBytes,
        signature: decoded.signature,
      );
      if (!validSig) {
        return const LicenseActivationResult.failure(
          LicenseActivationFailure.invalidCode,
        );
      }

      final info = decoded.info;
      if (info.deviceId != fingerprint) {
        return const LicenseActivationResult.failure(
          LicenseActivationFailure.wrongDevice,
        );
      }

      final now = DateTime.now().toUtc();
      if (now.isBefore(info.issuedAt)) {
        return const LicenseActivationResult.failure(
          LicenseActivationFailure.notYetValid,
        );
      }

      await _settings.save(
        _settings.get().copyWith(
          licenseIssuedAtMillis: info.issuedAt.toUtc().millisecondsSinceEpoch,
          licenseExpiresAtMillis: info.expiresAt.toUtc().millisecondsSinceEpoch,
          lastSeenTimestampMillis: now.millisecondsSinceEpoch,
        ),
      );
      return LicenseActivationResult.success(info.expiresAt);
    } on FormatException {
      return const LicenseActivationResult.failure(
        LicenseActivationFailure.invalidCode,
      );
    }
  }
}
