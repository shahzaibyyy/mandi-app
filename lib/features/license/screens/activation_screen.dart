import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/license_controller.dart';
import '../services/license_service.dart';

class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({super.key});

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  final _code = TextEditingController();
  var _loading = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _copyDeviceId(String deviceId) async {
    await Clipboard.setData(ClipboardData(text: deviceId));
    if (!mounted) return;
    SnackbarUtils.success(context, 'Device ID copied.');
  }

  Future<void> _activate() async {
    if (_code.text.trim().isEmpty) {
      SnackbarUtils.error(context, 'Paste the activation code first.');
      return;
    }
    setState(() => _loading = true);
    final result = await ref
        .read(licenseControllerProvider.notifier)
        .activate(_code.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.ok) {
      final loggedIn = ref.read(authControllerProvider);
      context.go(loggedIn ? '/' : '/login');
      return;
    }
    final message = switch (result.failure) {
      LicenseActivationFailure.invalidCode => 'Invalid activation code.',
      LicenseActivationFailure.wrongDevice =>
        'This code is for a different device.',
      LicenseActivationFailure.notYetValid => 'This code is not valid yet.',
      null => 'Activation failed.',
    };
    SnackbarUtils.error(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final license = ref.watch(licenseControllerProvider);
    final deviceId = license.deviceFingerprint ?? '…';
    final expires = license.expiresAt;
    final expiresLabel = expires == null
        ? null
        : DateFormat('dd MMM yyyy').format(expires.toLocal());

    final headline = switch (license.status) {
      LicenseStatus.expired => 'License expired',
      LicenseStatus.clockTampered => 'Device time invalid',
      LicenseStatus.missing => 'Activate this device',
      LicenseStatus.valid => 'Activate this device',
    };

    final subtitle = switch (license.status) {
      LicenseStatus.expired =>
        'Contact ${AppConstants.licenseSupportPhone} for renewal.',
      LicenseStatus.clockTampered =>
        'Set the correct date/time, then enter a new activation code.',
      _ =>
        'Send your Device ID on WhatsApp to receive a monthly activation code.',
    };

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(AppConstants.logoAsset, width: 88),
                    const SizedBox(height: 16),
                    Text(
                      headline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(subtitle, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Device ID',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            deviceId,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => _copyDeviceId(deviceId),
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Device ID'),
                          ),
                        ],
                      ),
                    ),
                    if (expiresLabel != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Previous expiry: $expiresLabel',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'Activation code',
                      controller: _code,
                      requiredField: true,
                      maxLines: 3,
                      hintText: 'Paste the code from WhatsApp',
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: _loading ? 'Activating…' : 'Activate',
                      onPressed: _loading ? null : _activate,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
