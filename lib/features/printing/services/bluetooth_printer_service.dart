import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class BluetoothPrinterService {
  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
    ].request();

    final connect = statuses[Permission.bluetoothConnect];
    final scan = statuses[Permission.bluetoothScan];
    if (connect != null && connect.isPermanentlyDenied) return false;
    if (scan != null && scan.isPermanentlyDenied) return false;
    return true;
  }

  Future<bool> isBluetoothOn() => PrintBluetoothThermal.bluetoothEnabled;

  Future<bool> isConnected() => PrintBluetoothThermal.connectionStatus;

  Future<List<BluetoothInfo>> pairedDevices() {
    return PrintBluetoothThermal.pairedBluetooths;
  }

  Future<bool> connect(String macAddress) {
    return PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
  }

  Future<bool> disconnect() => PrintBluetoothThermal.disconnect;

  Future<bool> writeBytes(List<int> bytes) {
    return PrintBluetoothThermal.writeBytes(bytes);
  }

  Future<bool> ensureConnected(String macAddress) async {
    final connected = await isConnected();
    if (connected) return true;
    return connect(macAddress);
  }
}

final bluetoothPrinterServiceProvider = Provider<BluetoothPrinterService>((
  ref,
) {
  return BluetoothPrinterService();
});
