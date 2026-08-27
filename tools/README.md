# License tooling

## One-time production setup

1. Run locally:
   ```bash
   dart run tools/generate_keypair.dart
   ```
2. Commit the updated `lib/core/license/license_public_key.dart`.
3. In GitHub → Settings → Secrets → Actions, add:
   - `LICENSE_SIGNING_KEY` = the printed `PRIVATE_SEED_B64` value.

## Generate a client code (GitHub Actions)

1. Open **Actions → Generate License → Run workflow**.
2. Enter the customer's **Device ID** (shown on the activation screen).
3. Set **months** (default `1` = 30 days).
4. Copy `activation_code=...` from the job log and WhatsApp it to the client.

## Dev/test key (already in repo)

Until you run `generate_keypair.dart`, the app ships with RFC 8032 test vector #3.

GitHub secret for testing only:

```
LICENSE_SIGNING_KEY=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE=
```

Never use this test key in production.
