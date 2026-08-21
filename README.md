# Mandi Receipts

Offline Android app for Pakistani mandi (market) fee collectors. Create entry-fee receipts, store them locally in Hive, and print on a paired Bluetooth ESC/POS thermal printer (58mm or 80mm). No backend, no cloud, no login.

This project is set up so you **do not need Android Studio** on your laptop. Build the APK on [Codemagic](https://codemagic.io), download it, and install it on a phone to test printing.

## Build an APK on Codemagic

`codemagic.yaml` at the repo root defines two workflows:

| Workflow | Artifact | Use |
| --- | --- | --- |
| **Android debug APK** | `app-debug.apk` | Daily testing, including Bluetooth printers |
| **Android release APK** | `app-release.apk` | Sideload a release build (currently signed with the debug key) |

1. Push this project to GitHub / GitLab / Bitbucket.
2. In Codemagic, add the repository and select **codemagic.yaml**.
3. Run **Android debug APK**.
4. Download `app-debug.apk` from the build artifacts.
5. Copy the APK to the phone and install it (allow “Install unknown apps” for your browser/files app).

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
