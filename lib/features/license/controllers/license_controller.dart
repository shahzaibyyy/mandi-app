import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers.dart';
import '../services/license_service.dart';

class LicenseState {
  const LicenseState({
    required this.status,
    this.deviceFingerprint,
    this.expiresAt,
    this.isReady = false,
  });

  final LicenseStatus status;
  final String? deviceFingerprint;
  final DateTime? expiresAt;
  final bool isReady;

  bool get isLicensed => status == LicenseStatus.valid;

  LicenseState copyWith({
    LicenseStatus? status,
    String? deviceFingerprint,
    DateTime? expiresAt,
    bool? isReady,
  }) {
    return LicenseState(
      status: status ?? this.status,
      deviceFingerprint: deviceFingerprint ?? this.deviceFingerprint,
      expiresAt: expiresAt ?? this.expiresAt,
      isReady: isReady ?? this.isReady,
    );
  }
}

class LicenseController extends Notifier<LicenseState> {
  LicenseService get _license => ref.read(licenseServiceProvider);

  @override
  LicenseState build() {
    return LicenseState(
      status: _license.status(),
      deviceFingerprint: _license.storedDeviceFingerprint(),
      expiresAt: _license.expiresAt(),
    );
  }

  Future<void> onAppStart() async {
    final fingerprint = await _license.ensureDeviceFingerprint();
    final status = _license.status();
    if (status == LicenseStatus.clockTampered) {
      state = LicenseState(
        status: status,
        deviceFingerprint: fingerprint,
        expiresAt: _license.expiresAt(),
        isReady: true,
      );
      return;
    }
    if (status == LicenseStatus.valid) {
      await _license.recordActivityTimestamp();
    }
    _refresh(fingerprint);
  }

  Future<LicenseActivationResult> activate(String code) async {
    final result = await _license.activate(code);
    if (result.ok) {
      _refresh(await _license.ensureDeviceFingerprint());
    }
    return result;
  }

  Future<void> recordReceiptActivity() async {
    if (state.status != LicenseStatus.valid) return;
    await _license.recordActivityTimestamp();
    _refresh(state.deviceFingerprint);
  }

  void _refresh(String? fingerprint) {
    state = LicenseState(
      status: _license.status(),
      deviceFingerprint: fingerprint ?? _license.storedDeviceFingerprint(),
      expiresAt: _license.expiresAt(),
      isReady: true,
    );
  }
}

final licenseServiceProvider = Provider<LicenseService>((ref) {
  return LicenseService(ref.watch(settingsRepositoryProvider));
});

final licenseControllerProvider =
    NotifierProvider<LicenseController, LicenseState>(LicenseController.new);

final licenseReadyProvider = Provider<bool>((ref) {
  return ref.watch(licenseControllerProvider).isReady;
});

final licenseValidProvider = Provider<bool>((ref) {
  return ref.watch(licenseControllerProvider).isLicensed;
});
