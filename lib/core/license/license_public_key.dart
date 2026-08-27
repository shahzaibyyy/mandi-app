import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// Ed25519 public key used to verify activation codes.
class LicensePublicKey {
  LicensePublicKey._();

  static const String base64 = 'cW+IwVvbS2794fkWrcYJ8MhX8th5y9CNekR/08GaOD4=';

  static Future<SimplePublicKey> load() async {
    final bytes = base64Decode(base64);
    return SimplePublicKey(bytes, type: KeyPairType.ed25519);
  }
}
