import java.util.Properties
import java.io.FileInputStream

// EcoTrack — android/app/build.gradle.kts
//
// 3 flavors (dev / staging / prod) with distinct applicationIds, upload-key
// signing driven by an *injected* android/key.properties (never committed; CI
// recreates it from GitHub Secrets — see .github/workflows/deploy.yml), and R8
// for release. If `flutter create` regenerates this file, re-apply the
// flavorDimensions / productFlavors / signingConfigs / buildTypes blocks.

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// android/key.properties — absent locally by default (release then debug-signs so
// `flutter run --release` still works); present in CI and for local release builds.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // Internal package namespace — matches the scaffolded MainActivity.kt package
    // (com/ecotrack/ecotrack/). Not user-visible. The store-facing id is
    // `applicationId` below. Keep these decoupled; only applicationId matters to the stores.
    namespace = "com.ecotrack.ecotrack"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Base id; flavors append a suffix so all three install side by side.
        applicationId = "com.ecotrack.app"
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"          // com.ecotrack.app.dev
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "EcoTrack Dev")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"      // com.ecotrack.app.staging
            versionNameSuffix = "-staging"
            resValue("string", "app_name", "EcoTrack Staging")
        }
        create("prod") {
            dimension = "environment"             // com.ecotrack.app
            resValue("string", "app_name", "EcoTrack")
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// NOTE: AndroidManifest.xml must use android:label="@string/app_name" so the
// per-flavor resValue above controls the launcher name.
