import 'dart:convert';
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:cryptography/cryptography.dart';

import 'license_info.dart';
import 'license_public_key.dart';

const licenseSignatureLength = 64;

class DecodedLicense {
  const DecodedLicense({
    required this.info,
    required this.payloadBytes,
    required this.signature,
  });

  final LicenseInfo info;
  final List<int> payloadBytes;
  final List<int> signature;
}

class LicenseCodec {
  LicenseCodec._();

  static String encodeSigned(LicenseInfo info, List<int> signature) {
    final payload = utf8.encode(jsonEncode(info.toPayloadJson()));
    final wire = [...payload, ...signature];
    return base32.encode(Uint8List.fromList(wire)).replaceAll('=', '');
  }

  static DecodedLicense decodeSigned(String code) {
    final normalized = code.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();
    if (normalized.isEmpty) {
      throw FormatException('Activation code is empty.');
    }
    final padding = '=' * ((8 - normalized.length % 8) % 8);
    final wire = base32.decode('$normalized$padding');
    if (wire.length <= licenseSignatureLength) {
      throw FormatException('Activation code is too short.');
    }
    final payloadBytes = wire.sublist(0, wire.length - licenseSignatureLength);
    final signature = wire.sublist(wire.length - licenseSignatureLength);
    final json = jsonDecode(utf8.decode(payloadBytes)) as Map<String, dynamic>;
    return DecodedLicense(
      info: LicenseInfo.fromPayloadJson(json),
      payloadBytes: payloadBytes,
      signature: signature,
    );
  }

  static Future<bool> verifySignature({
    required List<int> payload,
    required List<int> signature,
  }) async {
    final algorithm = Ed25519();
    final publicKey = await LicensePublicKey.load();
    return algorithm.verify(
      payload,
      signature: Signature(signature, publicKey: publicKey),
    );
  }
}
