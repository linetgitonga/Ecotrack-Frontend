# EcoTrack — DevOps & Architecture Shell

This repo is the **infrastructure skeleton** for the EcoTrack Flutter app: flavors,
secure config, Fastlane delivery, and GitHub Actions CI/CD. No product features.

## 1. Identifiers

| Flavor  | Android applicationId       | iOS bundle id              | Store target            |
|---------|-----------------------------|----------------------------|-------------------------|
| dev     | `com.ecotrack.app.dev`      | `com.ecotrack.app.dev`     | local only              |
| staging | `com.ecotrack.app.staging`  | `com.ecotrack.app.staging` | internal QA             |
| prod    | `com.ecotrack.app`          | `com.ecotrack.app`         | Play Internal / TestFlight |

## 2. Flavors

### Entry points
`lib/main_<env>.dart` → one line each → `bootstrap(Environment.<env>)` in
[`lib/bootstrap.dart`](../lib/bootstrap.dart), which runs the identical sequence
for every flavor: bindings → load `.env.<env>` → build `EnvConfig` → install
error handlers → `runApp`. Config is read-only via `EnvConfig.instance`.

```
flutter run   --flavor dev     -t lib/main_dev.dart
flutter build appbundle --flavor prod -t lib/main_prod.dart --release
```

### Android
[`android/app/build.gradle.kts`](../android/app/build.gradle.kts) (Kotlin DSL — the
current `flutter create` default) defines `flavorDimensions += "environment"` + 3
`productFlavors`. `dev`/`staging` use `applicationIdSuffix` so all three install
side-by-side; launcher name comes from the per-flavor `resValue("string", "app_name")`
and `AndroidManifest.xml` uses `android:label="@string/app_name"` (already patched).
Release signing reads `android/key.properties`, falling back to debug signing when
absent.

### iOS (one-time Xcode setup — not scriptable)
1. **Build Configurations** (Project → Info): duplicate `Debug`/`Release`/`Profile`
   into `Debug-dev`, `Release-dev`, `Profile-dev`, and the same for `staging`,
   `prod` (9 total).
2. Point each config's `Runner` target at the matching xcconfig:
   `ios/Flutter/{dev,staging,prod}.xcconfig` (already in the repo; each sets
   `PRODUCT_BUNDLE_IDENTIFIER` + `APP_DISPLAY_NAME`).
3. Set `Info.plist`: `CFBundleDisplayName = $(APP_DISPLAY_NAME)`,
   `CFBundleIdentifier = $(PRODUCT_BUNDLE_IDENTIFIER)`.
4. **Schemes**: create `dev`, `staging`, `prod` schemes (shared). Map
   Run/Test → `Debug-<env>`, Profile → `Profile-<env>`, Archive → `Release-<env>`.
5. Commit `ios/Runner.xcodeproj/xcshareddata/xcschemes/*`.

## 3. Secrets & dotenv

- `flutter_dotenv` loads `.env.<flavor>` from bundled assets (declared in
  `pubspec.yaml`).
- Only [`.env.example`](../.env.example) is committed (keys, no values).
- Locally: `make env` copies the template to `.env.dev/.staging/.prod`.
- In CI: written from secrets `ENV_DEV` / `ENV_STAGING` / `ENV_PROD`.
- `.gitignore` blocks `.env.*` (except `.env.example`), all keystores,
  `key.properties`, `service_account.json`, `*.p8/*.p12/*.mobileprovision`,
  `ios/Pods/`, and Fastlane reports/artifacts.

## 4. Fastlane

```
android/                       ios/
├── Gemfile                    ├── Gemfile
└── fastlane/                  └── fastlane/
    ├── Appfile                    ├── Appfile
    ├── Fastfile                   ├── Fastfile
    └── Pluginfile                 ├── Matchfile
                                   └── Pluginfile
```

| Lane | Where | Does |
|------|-------|------|
| `deploy_to_internal`   | `android/` | `flutter build appbundle --flavor prod` → upload AAB to **Play Internal** (draft) via service-account JSON |
| `promote_to_production`| `android/` | promote Internal → Production at 10 % staged rollout |
| `deploy_to_testflight` | `ios/`     | ASC API key → `match` (readonly) → `flutter build ios --no-codesign` → `gym` → upload to **TestFlight** |

iOS signing = **match**: certs/profiles live encrypted in a **separate private
repo** (`MATCH_GIT_URL`), decrypted with `MATCH_PASSWORD`. CI is `readonly(true)`;
rotate certs by running `bundle exec fastlane match appstore` locally.

## 5. GitHub Actions

| Workflow | Trigger | Runner | Purpose |
|----------|---------|--------|---------|
| [`ci.yml`](../.github/workflows/ci.yml) | PR / push to master | ubuntu + macos matrix | format, analyze, test, debug build smoke |
| [`deploy.yml`](../.github/workflows/deploy.yml) | tag `v*.*.*` / manual | `macos-latest` | test → restore keystore/JSON/.env → Android lane → iOS lane |

### Required repository secrets

| Secret | Used for |
|--------|----------|
| `ENV_DEV`, `ENV_STAGING`, `ENV_PROD` | contents of each `.env.<flavor>` |
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` / `ANDROID_KEY_ALIAS` / `ANDROID_KEY_PASSWORD` | keystore creds |
| `PLAY_STORE_JSON_KEY_BASE64` | base64 of Play service-account JSON |
| `MATCH_GIT_URL` | private certificates repo URL |
| `MATCH_PASSWORD` | match encryption passphrase |
| `MATCH_GIT_BASIC_AUTHORIZATION` | `base64("<user>:<PAT>")` to clone that repo |
| `APP_STORE_CONNECT_KEY_ID` / `APP_STORE_CONNECT_ISSUER_ID` | ASC API key ids |
| `APP_STORE_CONNECT_P8_BASE64` | base64 of the `AuthKey_XXXX.p8` |
| `APPLE_DEVELOPER_TEAM_ID` / `APP_STORE_CONNECT_TEAM_ID` | Apple team ids |

## 6. Build status

`flutter create . --org com.ecotrack --project-name ecotrack --platforms=android,ios,web`
has been run — native runners for android / ios / web are scaffolded. Verified on
Flutter 3.47.2: `flutter pub get`, `flutter analyze` (clean), `flutter test` (pass),
and `flutter build web --target lib/main_dev.dart` (succeeds).

Still outstanding:
- **Android builds** need the Android SDK installed (`flutter doctor` — see
  `docs/toolchain-setup.md` Action 3). `flutter test` / web don't need it.
- **iOS Xcode wiring** (build configurations + schemes per §2) is manual and must be
  done on a Mac; CI (`deploy.yml`) runs on `macos-latest`.
- Local `.env.dev` / `.env.staging` / `.env.prod` exist on this machine (git-ignored);
  a fresh clone runs `cp .env.example .env.dev` ×3 or `make env`.
