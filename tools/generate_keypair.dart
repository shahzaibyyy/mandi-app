import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

/// Generates a fresh Ed25519 keypair for production licensing.
///
/// Run once locally:
///   dart run tools/generate_keypair.dart
///
/// Then:
/// 1. Commit the updated `lib/core/license/license_public_key.dart`
/// 2. Add printed PRIVATE_SEED_B64 to GitHub secret `LICENSE_SIGNING_KEY`
Future<void> main() async {
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPair();
  final publicKey = await keyPair.extractPublicKey();
  final keyData = await keyPair.extract();

  final publicB64 = base64Encode(publicKey.bytes);
  final seedB64 = base64Encode(keyData.bytes.sublist(0, 32));

  final publicKeyFile = File(
    'lib/core/license/license_public_key.dart',
  );
  await publicKeyFile.writeAsString('''import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// Ed25519 public key used to verify activation codes.
class LicensePublicKey {
  LicensePublicKey._();

  static const String base64 = '$publicB64';

  static Future<SimplePublicKey> load() async {
    final bytes = base64Decode(base64);
    return SimplePublicKey(bytes, type: KeyPairType.ed25519);
  }
}
''');

  stdout.writeln('Updated lib/core/license/license_public_key.dart');
  stdout.writeln('');
  stdout.writeln('Add this GitHub Actions secret:');
  stdout.writeln('  LICENSE_SIGNING_KEY=$seedB64');
  stdout.writeln('');
  stdout.writeln('Never commit the private seed.');
}
