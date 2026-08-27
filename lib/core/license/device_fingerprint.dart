import 'dart:convert';
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';

class DeviceFingerprint {
  DeviceFingerprint._();

  static const length = 8;

  static String fromAndroidId(String androidId) {
    final hash = sha256.convert(utf8.encode(androidId)).bytes;
    final encoded = base32
        .encode(Uint8List.fromList(hash.sublist(0, 5)))
        .replaceAll('=', '')
        .toUpperCase();
    return encoded.length >= length
        ? encoded.substring(0, length)
        : encoded.padRight(length, '0');
  }
}
