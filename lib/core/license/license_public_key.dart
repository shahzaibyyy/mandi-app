import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// Ed25519 public key used to verify activation codes.
///
/// Development default: RFC 8032 test vector #3.
/// Production: run `dart run tools/generate_keypair.dart` and commit this file.
class LicensePublicKey {
  LicensePublicKey._();

  static const List<int> _bytes = [
    0x3d, 0x40, 0x17, 0xc6, 0x03, 0x5e, 0xc3, 0x13,
    0x37, 0x51, 0xbd, 0xd7, 0x82, 0x0e, 0x81, 0xa5,
    0xc6, 0x13, 0x3e, 0x8b, 0x1e, 0xb1, 0x73, 0x1f,
    0xfc, 0x86, 0x66, 0xea, 0x36, 0xeb, 0x0d, 0xd4,
  ];

  static Future<SimplePublicKey> load() async {
    return SimplePublicKey(_bytes, type: KeyPairType.ed25519);
  }

  /// Base64 of [_bytes] for tooling/debug only.
  static String get base64 => base64Encode(_bytes);
}
