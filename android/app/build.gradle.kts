plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.notification_app"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.notification_app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    java {
        toolchain {
            languageVersion.set(JavaLanguageVersion.of(11))
        }
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.10")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}



flutter {
    source = "../.."
}
