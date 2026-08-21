# Mandi Receipts

Offline Android app for Pakistani mandi (market) fee collectors. Create entry-fee receipts, store them locally in Hive, and print on a paired Bluetooth ESC/POS thermal printer (58mm or 80mm). No backend, no cloud, no login.

This project is set up so you **do not need Android Studio** on your laptop. Build the APK on [Codemagic](https://codemagic.io), download it, and install it on a phone to test printing.

## Build an APK on Codemagic

Codemagic’s visual **Workflow Editor** builds an **.aab** by default (and also picks up `.aar` / `mapping.txt`). That is not this project’s YAML. If a finished build shows `app-release.aab` and no `.apk`, the app is still on Workflow Editor.

1. Open the app in Codemagic → **Application settings**.
2. Set configuration to **I have a `codemagic.yaml`** (not Workflow Editor).
3. Start a new build and choose **Android debug APK** (Linux), not the default Flutter workflow on Mac mini M2.
4. Download `app-debug.apk` from artifacts.

YAML workflows:

| Workflow | Artifact | Use |
| --- | --- | --- |
| **Android debug APK** | `app-debug.apk` | Daily testing, including Bluetooth printers (auto on push to `main`) |
| **Android release APK** | `app-release.apk` | Sideload a release build |
| **Android Play Store AAB** | `app-release.aab` | Play Store only — start this workflow manually |

You do not need to run `flutter run` or install the Android SDK locally.

## Test Bluetooth printing on the phone

1. Pair the 58mm/80mm ESC/POS printer in **Android Settings → Bluetooth** (the app lists already-paired devices).
2. Open **Mandi Receipts → Printer**, tap **Scan paired devices**, select the printer, and set 58mm or 80mm.
3. Add a market and at least one fee type.
4. Create a receipt, save, and choose **Print**. You can reprint from receipt history.

Allow Bluetooth and location when Android asks. Location is used for the GPS stamp on the receipt and for Bluetooth scanning on older Android versions.

## Persistence

All markets, fee types, receipts, and settings live in on-device Hive boxes. Closing and reopening the app keeps the data.

## Local Dart-only checks (optional)

If Flutter is installed, you can run these without an Android SDK:

```bash
flutter pub get
flutter analyze
flutter test
```
