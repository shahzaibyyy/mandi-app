import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

import 'package:mandi_fee_collector/core/constants/app_constants.dart';
import 'package:mandi_fee_collector/core/license/license_codec.dart';
import 'package:mandi_fee_collector/core/license/license_info.dart';

/// Signs monthly device licenses for GitHub Actions / local CLI use.
///
/// Usage:
///   LICENSE_SIGNING_KEY=[base64-seed] dart run tools/generate_license.dart \
///     --device-id=ABC12XY9 --months=1
Future<void> main(List<String> args) async {
  final deviceId = _arg(args, '--device-id')?.trim().toUpperCase();
  final monthsRaw = _arg(args, '--months') ?? '1';
  final months = int.tryParse(monthsRaw);
  final seedB64 = Platform.environment['LICENSE_SIGNING_KEY'];

  if (deviceId == null || deviceId.isEmpty) {
    stderr.writeln('Missing --device-id');
    exit(1);
  }
  if (months == null || months < 1) {
    stderr.writeln('Invalid --months');
    exit(1);
  }
  if (seedB64 == null || seedB64.isEmpty) {
    stderr.writeln('Missing LICENSE_SIGNING_KEY environment variable.');
    exit(1);
  }

  final issuedAt = DateTime.now().toUtc();
  final expiresAt = issuedAt.add(
    Duration(days: AppConstants.licenseDaysPerMonth * months),
  );
  final info = LicenseInfo(
    deviceId: deviceId,
    issuedAt: issuedAt,
    expiresAt: expiresAt,
  );

  final seed = base64Decode(seedB64);
  if (seed.length != 32) {
    stderr.writeln('LICENSE_SIGNING_KEY must be 32-byte Ed25519 seed (base64).');
    exit(1);
  }

  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPairFromSeed(seed);
  final payload = utf8.encode(jsonEncode(info.toPayloadJson()));
  final signature = await algorithm.sign(payload, keyPair: keyPair);
  final code = LicenseCodec.encodeSigned(info, signature.bytes);

  stdout.writeln('device_id=$deviceId');
  stdout.writeln('issued_at=${issuedAt.toIso8601String()}');
  stdout.writeln('expires_at=${expiresAt.toIso8601String()}');
  stdout.writeln('');
  stdout.writeln('activation_code=$code');
}

String? _arg(List<String> args, String name) {
  for (final arg in args) {
    if (arg.startsWith('$name=')) {
      return arg.substring(name.length + 1);
    }
  }
  return null;
}
