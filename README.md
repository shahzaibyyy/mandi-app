# Mandi Receipts

Offline Android app for Pakistani mandi (market) fee collectors. Create entry-fee receipts, store them locally in Hive, and print on a paired Bluetooth ESC/POS thermal printer (58mm or 80mm). No backend, no cloud, no login.

## Setup

```bash
flutter pub get
dart run build_runner build
flutter run
```

Pair the thermal printer in Android Bluetooth settings first, then open **Printer** in the app and select it.

## Permissions

The app requests Bluetooth Connect/Scan and fine location. Location is used to stamp GPS on receipts and for Bluetooth scanning on older Android versions.

## Persistence

All markets, fee types, receipts, and settings live in on-device Hive boxes. Closing and reopening the app keeps the data.
