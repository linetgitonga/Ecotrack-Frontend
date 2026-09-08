# EcoTrack — Local toolchain setup (Windows)

Supersedes §15 of `mobile-app-architecture-plan.md`. This is the real diagnosis after
investigating on 2026-09-08.

## What was wrong

| # | Problem | Status |
|---|---------|--------|
| 1 | **Two Flutter installs**, broken one first on PATH | Diagnosed |
| 2 | `C:\Program Files\flutter` (3.29.3) — git "dubious ownership" (dir owned by Administrators), cache not user-writable → every `flutter` call stalls | Needs admin to remove |
| 3 | `C:\Users\LINET\develop\flutter` (3.47.2 stable) — healthy, but tool snapshot wasn't built → first run looked like a hang (it wasn't; it needed ~2 min) | ✅ Fixed — built + verified |
| 4 | **C: drive full** (was 0.2 GB free) | ✅ You cleared it (22 GB free now) |
| 5 | **Kaspersky Endpoint Security 12.2.0** — real-time scanning throttles pub downloads to ~8 KB/s, stalls multi-file package extraction, blocks shell spawning under load, and **has quarantined `dart.exe`** from `C:\Users\LINET\develop\flutter\bin\cache\dart-sdk\bin\` (confirmed 2026-09-08 18:32). The Dart SDK is now non-functional. | **HARD BLOCKER — needs Kaspersky exclusions + file restore (admin / IT)** |
| 6 | Android SDK not installed | Needs install (see below) |
| 7 | Visual Studio Build Tools 2019 incomplete | Only matters for Windows desktop target — ignore for this project |

## What was already fixed (no action needed)

- `git config --global --add safe.directory` for both Flutter dirs.
- IDE (`Antigravity IDE\User\settings.json`): added
  `"dart.flutterSdkPath": "C:\\Users\\LINET\\develop\\flutter"` and
  `"dart.checkForSdkUpdates": false`. **Restart the IDE** so the Dart extension picks up the
  3.47.2 SDK and drops the 3 `dart.exe` processes still running from `C:\Program Files\flutter`.
- `C:\Users\LINET\develop\flutter\bin` appended to the **User** PATH.
- `flutter --version` and `flutter doctor -v` confirmed working via
  `C:\Users\LINET\develop\flutter\bin\flutter`.

---

## Action 1 — Kaspersky (the hard blocker)

**KES is actively removing the Dart toolchain.** It quarantined
`C:\Users\LINET\develop\flutter\bin\cache\dart-sdk\bin\dart.exe`. Nothing Flutter-related
works until this is resolved. Two parts:

### 1a. Restore the quarantined file

- **KES GUI:** open Kaspersky → **Backup** (or **Quarantine** / **Detected objects**) →
  find `dart.exe` → **Restore** and add to exclusions when prompted.
- **or CLI** (elevated, needs the KES password if policy-protected):
  ```
  "C:\Program Files (x86)\Kaspersky Lab\KES.12.2.0\avp.com" RESTORE dart.exe --password=<kes-password>
  ```
- **or** re-run `flutter doctor` after 1b — Flutter re-provisions a missing dart-sdk; with
  exclusions in place it will survive.

### 1b. Add exclusions (so it doesn't happen again)

`flutter pub get` also cannot complete while KES scans every file pub writes. Open **Kaspersky
Endpoint Security → Settings → Threats and Exclusions → Manage exclusions** (needs the KES
admin password / may be locked by corporate policy — then it's an IT request), and add
**trusted / scan-excluded** entries for:

```
C:\Users\LINET\develop\flutter\
C:\Users\LINET\AppData\Local\Pub\Cache\
C:\Users\LINET\AppData\Roaming\Pub\Cache\
D:\FLUTTER\ECOTRACK\ecotrack\
C:\Users\LINET\.gradle\        (once Android builds start)
C:\Users\LINET\AppData\Local\Android\   (once Android SDK is installed)
```

Also under **Trusted applications** add:
```
C:\Users\LINET\develop\flutter\bin\cache\dart-sdk\bin\dart.exe
C:\Users\LINET\develop\flutter\bin\cache\dart-sdk\bin\dartaotruntime.exe
```
with "Do not scan all traffic" + "Do not scan opened files" checked.

If you cannot change KES: as a **temporary** measure, pause protection
(`"C:\Program Files (x86)\Kaspersky Lab\KES.12.2.0\avp.com" PAUSE` from an elevated prompt,
or the tray icon), run `flutter pub get`, then resume. This only helps for one-off pulls; the
exclusions are the durable fix because every codegen build (`build_runner`, drift, freezed)
downloads packages.

Verify:
```
cd D:\FLUTTER\ECOTRACK\ecotrack
C:\Users\LINET\develop\flutter\bin\flutter pub get     # must exit 0
```

---

## Action 2 — remove the broken install (needs admin)

Run **PowerShell as Administrator**:

```powershell
# delete the old 3.29.3 install (frees ~2.7 GB)
Remove-Item -Recurse -Force "C:\Program Files\flutter"

# strip it from the Machine PATH so `flutter` in a terminal uses the good SDK
$m = [Environment]::GetEnvironmentVariable('Path','Machine')
$clean = ($m -split ';' | Where-Object { $_ -and $_ -notlike '*Program Files\flutter*' }) -join ';'
[Environment]::SetEnvironmentVariable('Path', $clean, 'Machine')
```

Then open a **new** terminal and confirm:
```
where.exe flutter      # → C:\Users\LINET\develop\flutter\bin\flutter  (only)
flutter --version      # → 3.47.2
```

Until this is done, always call Flutter by full path:
`C:\Users\LINET\develop\flutter\bin\flutter`.

---

## Action 3 — Android SDK (before any Android build; not needed for `flutter test` or web)

Fastest path without the full Android Studio GUI:

```powershell
winget install --id Google.AndroidStudio -e        # or just the command-line tools
```

Then in Android Studio → **SDK Manager**, install: SDK Platform 35 (or latest),
Platform-Tools, Build-Tools, and the **Android SDK Command-line Tools**. Finally:

```
flutter config --android-sdk "C:\Users\LINET\AppData\Local\Android\Sdk"
flutter doctor --android-licenses
flutter doctor -v      # Android toolchain should be [√]
```

iOS builds require macOS — handled by the GitHub Actions runner (`deploy.yml`), not this
machine.

---

## After the toolchain is green

```
cd D:\FLUTTER\ECOTRACK\ecotrack
flutter pub get
flutter create .  --org com.ecotrack --project-name ecotrack --platforms=android,ios,web
# then re-apply the flavor/signing blocks in android/app/build.gradle (they carry a header note),
# wire the iOS Xcode configs/schemes per docs/devops-setup.md,
# and: cp .env.example .env.dev  (and .env.staging, .env.prod)
flutter analyze
flutter test
```

That clears Phase 0 of the implementation plan.
