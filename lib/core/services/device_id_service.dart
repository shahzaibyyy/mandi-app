import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceIdService {
  DeviceIdService._();

  static final DeviceIdService instance = DeviceIdService._();

  String? _cached;

  Future<String> getId() async {
    if (_cached != null) return _cached!;
    final plugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      _cached = info.id;
      return _cached!;
    }
    final info = await plugin.deviceInfo;
    _cached = info.data['deviceId']?.toString() ?? info.data.toString();
    return _cached!;
  }
}
